# koha-testing-docker

This project provides a dockered solution for running a Koha ILS development 
environment inside Docker containers.

It is built using the package install with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

## Requirements

### Software

This project is self contained and all you need is:

- A text editor to tweak configuration files
- Docker ([install instructions](https://docs.docker.com/engine/install/))
- Docker Compose ([install instructions](https://docs.docker.com/compose/install/#install-compose-on-linux-systems))

You can choose to use [Docker Compose V2](https://docs.docker.com/compose/cli-command/#install-on-linux).
In that case, follow the version-specific instructions we put in place (specially the _shell aliases_) and notice that every
command that involves calling `docker-compose` should have it replaced by `docker compose`.

Note: **Windows** and **macOS** users get _Docker Compose V2_.

### Hardware

- At least 2.6 GiB of free RAM (not counting web browser)
- If you want to try Elastic, count at least 2 GiB more of free RAM.

## Usage

* First, fetch this project:

```shell
mkdir ~/git ; cd ~/git
git clone https://gitlab.com/koha-community/koha-testing-docker.git
cd koha-testing-docker
```

## Launch

*Requirement*: The SYNC_REPO variable needs to be defined and contain the full path
for a Koha's git repository clone.

This can be made permanent by adding the following to your user's .bashrc (using the correct path to your Koha clone):

```shell
# ENV variables for kohadevbox
export SYNC_REPO="/home/user/kohaclone"
export LOCAL_USER_ID=$(id -u)
```
Note you will need to log out and log back in (or start a new terminal window) for this to take effect.

### Setup

Copy the _env/defaults.env_ file into the running directory:

```shell
cp env/defaults.env .env
```

Some variables need to be set to run this:

```shell
export SYNC_REPO=/path/to/kohaclone
export LOCAL_USER_ID=$(id -u)
```

### Running

#### Aliases

This project includes some handy aliases for easy startup, opening a shell inside the Koha container and stopping everything:

| Alias   | Function                                                   |
|---------|------------------------------------------------------------|
| ku      | Start the whole thing, using MariaDB 10.1 with Debian 9    |
| ku-es5  | As above, plus ES5                                         |
| ku-es6  | As above, replacing ES5 with ES6                           |
| ku-es7  | As above, replacing ES6 with ES7                           |
| ku-mdb  | Start the whole thing, using latest MariaDB with Debian 9  |
| ku-md9  | Start the whole thing, using MariaDB matched to Debian 9   |
| ku-md10 | Start the whole thing, using MariaDB matched to Debian 10  |
| ku-my8  | Start the whole thing, using latest MySQL with Debian 9    |
| kp      | Start the whole thing, with mysql persistence              |
| kup     | Start the env, plugin development set [^1] [^2]            |
| kk      | Start the whole thing, with kibana                         |
| kpk     | Start the whole thing, with mysql persistence and kibana   |
| kd      | Stop the whole thing                                       |
| kshell  | Opens a shell inside the Koha container                    |

In order to use this aliases you need to edit your _~/.bashrc_ ( or _~/.profile_ if using Git for Windows ) file adding:

```shell
export KOHA_TESTING_DOCKER_HOME=/path/to/your/koha-testing-docker/clone
source ${KOHA_TESTING_DOCKER_HOME}/files/bash_aliases
```

**Note**: If you are using [Docker Compose V2](https://docs.docker.com/compose/cli-command/#install-on-linux) use this
command instead:

```shell
export KOHA_TESTING_DOCKER_HOME=/path/to/your/koha-testing-docker/clone
source ${KOHA_TESTING_DOCKER_HOME}/files/bash_aliases_v2
```

[^1]: You need to export the _PLUGIN_REPO_ variable, with the full path to the plugin dir. It will fail to load if you don't export the variable first.
[^2]: Once started, you need to edit the kohadev koha-conf commenting the pluginsdir default and uncommenting the kohadev lines and then load the plugin using kshell ./misc/devel/install_plugins.pl

#### Manually

```shell
docker-compose -p koha up
```

Alternatively, you can have it run all the tests and exit, like this:

```shell
export RUN_TESTS_AND_EXIT="yes"
# Optionally you can add COVERAGE=1 so the tests generate coverage data
# Optionally you can add CPAN=1 to pull the latest versions of perl dependancies directly from cpan
docker-compose -p koha up --abort-on-container-exit
```

#### Update images

```shell
docker-compose -f docker-compose.yml pull
```

#### Database persistence

If you need to keep the DB between your different uses of the containers, you can
run

```shell
docker-compose -f docker-compose.yml -f docker-compose.persistent.yml -p koha up
```

**Alias**: `kp`

#### Kibana

If you would like to use Kibana for testing/interacting with ES directly you can include
an extra compose file

```shell
docker-compose -f docker-compose.yml -f docker-compose.kibana.yml -p koha up
```

**Alias**: `kk`

It is possible to combine this with persistence

```shell
docker-compose -f docker-compose.yml -f docker-compose.persistent.yml -f docker-compose.kibana.yml -p koha up
```

**Alias**: `kpk`

## Getting into the container

**Alias**: `kshell`

Once you are left on the shell, you can run Koha tests as you would on KohaDevBox:

```shell
kshell
cd koha
prove t/db_dependent/Search.t
```

### Explaining kshell, useful for other containers as well

Getting into the _koha_ container implies:

```shell
docker exec -it koha_koha_1 bash
```

(In _Docker Compose V2_ it would be `docker exec -it koha-koha-1 bash`).

Note: the first _koha_ should match the _-p_ parameter used in _docker-compose up_

## Getting to the web interface

The IP address of the web server in your docker group will be variable. Once you are in with SSH, issuing a

```shell
ip a
```
should display the IP address of the webserver. At this point the web interface of Koha can be accessed by going to
http://<the displayed IP>:8080 for the OPAC
http://<the displayed IP>:8081 for the Staff interface.

## Available commands and aliases

The Koha container ships with some aliases to improve productivity. They are divided in two,
depending on the user in which the alias is defined.

Aliases for the *instance* user require that you start a shell with that user in
order to be used. This is done like this:

```shell
kshell
```

### **root** user
* **koha-intra-err**:    tail the intranet error log
* **koha-opac-err**:     tail the OPAC error log
* **koha-plack-log**:    tail the Plack access log
* **koha-plack-err**:    tail de Plack error log
* **kshell**:            get into the instance user, on the kohaclone dir
* **koha-user**:         get the db/admin username from koha-conf.xml
* **koha-pass**:         get the db/admin password from koha-conf.xml
* **dbic**:              recreate the schema files using a fresh DB
* **flush_memcached**:   Flush all key/value stored on memcached
* **restart_all**:       restarts memcached, apache and plack
* **reset_all**:         Drop and recreate the koha database [*]
* **reset_all_marc21**:  Same as **reset_all**, but forcing MARC21
* **reset_all_unimarc**: Same as **reset_all**, but forcing UNIMARC
* **start_plack_debug**: Start Plack in debug mode, trying to connect to a remote debugger if set.
* **updatedatabase**:    Run the updatedatabase.pl script in the right context (instance user)

Note: it is recommended to run __start_plack_debug__ on a separate terminal
because it doesn't free the prompt until the process is stopped.

[*] **reset_all** actually:
* Drops the instance's database, and creates an empty one.
* Calls the misc4dev/do_all_you_can_do.pl script.
* Populates the DB with the sample data, using the configured MARC flavour.
* Create a superlibrarian user.
* Updates the debian files in the VM (overwrites the ones shipped by the koha-common package).
* Updates the plack configuration file for the instance.
* Calls **restart_all**

### **kohadev** user
* **qa**:          Run the QA scripts on the current branch. For example: *qa -c 2 -v 2*
* **prove_debug**: Run the *prove* command with all parameters needed for starting a remote debugging session.

## Having Elasticsearch run

In order for Elasticsearch to run, changes to the host OS need to be made. Please read
[the official docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

### TL;DR
Increase *vm.max_map_count* kernel setting to at least 262144:

* On Linux:

```shell
# Increase vm.max_map_count
sudo sysctl -w vm.max_map_count=262144
# Make it permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

* On MacOS:
  
```shell
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
# login with root and no password
sysctl -w vm.max_map_count=262144
```

If the screen command doesn't work try: find ~/Library/Containers/com.docker.docker/Data/ -name 'tty'

## Problems?

If you see the following error on 'ku' after initial setup, try a reboot

```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```
