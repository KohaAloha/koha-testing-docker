# koha-testing-docker

This project aims to provide a dockered solution for running the Koha ILS
tests inside Docker containers.

It is built on a packages install on Debian 9, with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

## Requirements

- Docker
- Docker Compose
- If Docker is installed as root, you need to add your user to the docker group.

```
  $ sudo usermod -aG docker ${USER}
```

## Usage

* First, fetch this project:

```
  $ mkdir ~/git ; cd ~/git
  $ git clone https://gitlab.com/koha-community/koha-testing-docker.git
  $ cd koha-testing-docker
```

## Launch

*Requirement*: The SYNC_REPO variable needs to be defined and contain the full path
for a Koha's git repository clone.

This can be made permanent by adding the following to your user's .bashrc (using the correct path to your Koha clone):

```
  # ENV variables for kohadevbox
  export SYNC_REPO="/home/user/kohaclone"
  export LOCAL_USER_ID=$(id -u)
```
Note you will need to log out and log back in (or start a new terminal window) for this to take effect.

### Setup

Copy the _env/defaults.env_ file into the running directory:

```
  $ cp env/defaults.env .env
```

Some variables need to be set to run this:

```
  $ export SYNC_REPO=/path/to/kohaclone
  $ export LOCAL_USER_ID=$(id -u)
```

### Running

#### Aliases

This project includes some handy aliases for easy startup, opening a shell inside the Koha container and stopping everything:

| Alias   | Function                                                   |
|---------|------------------------------------------------------------|
| ku      | Start the whole thing                                      |
| ku-es5  | Start the whole thing, using ES5                           |
| ku-es6  | Start the whole thing, using ES6 (default)                 |
| ku-es7  | Start the whole thing, using ES7                           |
| ku-mdb  | Start the whole thing, using latest MariaDB with Debian 9  |
| ku-md9  | Start the whole thing, using MariaDB matched to Debian 9   |
| ku-md10 | Start the whole thing, using MariaDB matched to Debian 10  |
| ku-my8  | Start the whole thing, using latest MySQL with Debian 9    |
| kp      | Start the whole thing, with mysql persistence              |
| kup     | Start the env, plugin development set [^1] [^2]                |
| kk      | Start the whole thing, with kibana                         |
| kpk     | Start the whole thing, with mysql persistence and kibana   |
| kd      | Stop the whole thing                                       |
| kshell  | Opens a shell inside the Koha container                    |

In order to use this aliases you need to edit your _~/.bashrc_ file adding:

```
export KOHA_TESTING_DOCKER_HOME=/path/to/your/koha-testing-docker/clone
source ${KOHA_TESTING_DOCKER_HOME}/files/bash_aliases
```

[^1]: You need to export the _PLUGIN_REPO_ variable, with the full path to the plugin dir. It will
fail to load if you don't export the variable first.
[^2]: To force Koha to load plugins after import: perl -e 'use Koha::Plugins; my $plugin = Koha::Plugins->new(); $plugin->InstallPlugins;'

#### Manually

```
  $ docker-compose -p koha up
```

Alternatively, you can have it run all the tests and exit, like this:

```
  $ export RUN_TESTS_AND_EXIT="yes"
  # Optionally you can add COVERAGE=1 so the tests generate coverage data
  # Optionally you can add CPAN=1 to pull the latest versions of perl dependancies directly from cpan
  $ docker-compose -p koha up --abort-on-container-exit
```

#### Update images

```
  $ docker-compose -f docker-compose.yml pull
```

#### Database persistence

If you need to keep the DB between your different uses of the containers, you can
run

```
  $ docker-compose -f docker-compose.yml -f docker-compose.persistent.yml -p koha up
```

#### Kibana

If you would like to use Kibana for testing/interacting with ES directly you can include
an extra compose file

```
  $ docker-compose -f docker-compose.yml -f docker-compose.kibana.yml -p koha up
```

It is possible to combine this with persistence
```
  $ docker-compose -f docker-compose.yml -f docker-compose.persistent.yml -f docker-compose.kibana.yml -p koha up
```

## Getting into the container

Getting into the _koha_ container:

```
  $ docker exec -it koha_koha_1 bash
```

Note: the first _koha_ should match the _-p_ parameter used in _docker-compose up_


Once you are left on the shell, you can run Koha tests as you would on KohaDevBox:


```
  $ sudo koha-shell kohadev
  $ cd koha
  $ prove t/db_dependent/Search.t
```
## Getting to the web interface

The IP address of the web server in your docker group will be variable. Once you are in with SSH, issuing a
```
$ip a
```
should display the IP address of the webserver. At this point the web interface of Koha can be accessed by going to
http://<the displayed IP>:8080 for the OPAC
http://<the displayed IP>:8081 for the Staff interface.

## Available commands and aliases

The Koha container ships with some aliases to improve productivity. They are divided in two,
depending on the user in which the alias is defined.

Aliases for the *instance* user require that you start a shell with that user in
order to be used. This is done like this:

```
  $ kshell
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
```
  # Increase vm.max_map_count
  $ sudo sysctl -w vm.max_map_count=262144
  # Make it permanent
  $ sudo echo "vm.max_map_count=262144" >> /etc/sysctl.conf

```

* On MacOS:
```
  $ screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
  # login with root and no password
  $ sysctl -w vm.max_map_count=262144
```
If the screen command doesn't work try: find ~/Library/Containers/com.docker.docker/Data/ -name 'tty'
