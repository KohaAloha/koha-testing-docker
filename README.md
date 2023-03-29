# koha-testing-docker (a.k.a. KTD)

This project provides a dockered solution for running a Koha ILS development 
environment inside Docker containers.

It is built using the package install with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

## Requirements

### Software

This project is self contained and all you need is:

- A text editor to tweak configuration files
- Docker ([install instructions](https://docs.docker.com/engine/install/#server))
- Docker Compose v2 ([install instructions](https://docs.docker.com/compose/install/linux/#install-using-the-repository))

Notes:
* **Linux** users, only Docker engine (aka Docker server) is required to run `ktd`.
* **Windows** and **macOS** users use [Docker Desktop](https://docs.docker.com/compose/install/compose-desktop/) which already ships Docker Compose v2.

### Hardware

- At least 2.6 GiB of free RAM (not counting web browser)
- If you want to try Elastic, count at least 2 GiB more of free RAM.

## Setup

It is not a bad idea to organize your projects on a directory. For the purpose
of simplifying the instructions we will pick `~/git` as the place in which to
put all the repository clones:

```shell
mkdir -p ~/git
export PROJECTS_DIR=~/git
```

* Clone the `koha-testing-docker` project:

```shell
cd $PROJECTS_DIR
git clone https://gitlab.com/koha-community/koha-testing-docker.git koha-testing-docker
```

* Clone the `koha` project (skip and adjust the paths if you already have it):

```shell
cd $PROJECTS_DIR
# be patient, it's a >3GiB download
git clone https://git.koha-community.org/Koha-community/Koha.git koha
```

* Set some **mandatory** environment variables:

```shell
echo "export PROJECTS_DIR=$PROJECTS_DIR" >> ~/.bashrc
echo 'export SYNC_REPO=$PROJECTS_DIR/koha' >> ~/.bashrc
echo 'export KTD_HOME=$PROJECTS_DIR/koha-testing-docker' >> ~/.bashrc
echo 'export PATH=$PATH:$KTD_HOME/bin' >> ~/.bashrc
echo 'export LOCAL_USER_ID=$(id -u)' >> ~/.bashrc
```

**Note:** you will need to log out and log back in (or start a new terminal window) for this to take effect.

* Generate your personal _.env_ file:

```shell
cd $PROJECTS_DIR/koha-testing-docker
cp env/defaults.env .env
```

## Basic usage

In order to launch _KTD_, you can use the `ktd` wrapper command. It is a wrapper around the
`docker compose` command so it accepts its parameters:

* Starting:

```shell
ktd up
```

* Get into the Koha container shell (instance user)

```shell
ktd --shell
```

* Get into the Koha container shell (root user)

```shell
ktd --root --shell
```

* Watching the _koha_ container logs

```shell
ktd --logs
```

* Updating the used images:

```shell
ktd pull
```

* Shutting it down

```shell
ktd down
```

* Adding services to our stack

Several option switches are provided for more fine-grained control:

```shell
ktd --es7 up
ktd --selenium --os7 --plugin --sso up
```

Note: the `pull` command would also work if you add several option switches. So running:

```shell
ktd --es7 pull
```

will also download/update the Elasticsearch 7.x image to be used.

For a complete list of the option switches, run the command with the _--help_ option:

```shell
ktd --help
```

## Getting to the web interface

The IP address of the web server in your docker group will be variable. Once you are in with SSH, issuing a

```shell
ip a
```
should display the IP address of the webserver. At this point the web interface of Koha can be accessed by going to
http://<the displayed IP>:8080 for the OPAC
http://<the displayed IP>:8081 for the Staff interface.

## Available commands and aliases

The container comes with some helpful aliases to improve productivity, many of which are available 
from both the kohadev and root users.

In most cases you will want to access the container as the kohadev user using:

```shell
ktd --shell
```

Whilst logged in as this user, the following commands are available

### **kohadev only**
| Command            | Function                                                                                    |
|--------------------|---------------------------------------------------------------------------------------------|
| **qa**             | Run the QA scripts on the current branch. For example: *qa -c 2 -v 2*                       |
| **prove_debug**    | Run the *prove* command with all parameters needed for starting a remote debugging session. |

### **kohadev and root**
| Command               | Function                                                                    |
|-----------------------|-----------------------------------------------------------------------------|
| **koha-intra-err**    | tail the intranet error log                                                 |
| **koha-opac-err**     | tail the OPAC error log                                                     |
| **koha-plack-log**    | tail the Plack access log                                                   |
| **koha-plack-err**    | tail de Plack error log                                                     |
| **koha-user**         | get the db/admin username from koha-conf.xml                                |
| **koha-pass**         | get the db/admin password from koha-conf.xml                                |
| **dbic**              | recreate the schema files using a fresh DB. Accepts the *--force* parameter |
| **flush_memcached**   | flush all key/value stored on memcached                                     |
| **restart_all**       | restarts memcached, apache and plack                                        |
| **reset_all**         | drop and recreate the koha database [*]                                     |
| **reset_all_marc21**  | same as **reset_all**, but forcing MARC21                                   |               
| **reset_all_unimarc** | same as **reset_all**, but forcing UNIMARC                                  |
| **start_plack_debug** | start Plack in debug mode, trying to connect to a remote debugger if set.   |
| **updatedatabase**    | run the updatedatabase.pl script in the right context (instance user)       |

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

### **root only**
| Command            | Function                                                                                    |
|--------------------|---------------------------------------------------------------------------------------------|
| **kshell**:        | get into the instance user, on the kohaclone dir                                            |

## Running the right branch

By default the _KTD_ that will start up is configured to work for the master branch of Koha.  If you want to run an image
to test code against another koha branch you should use the `KOHA_IMAGE` environment variable before starting the image 
as above.

```shell
KOHA_IMAGE=21.05 ktd up
```

Please note that you can only use branches defined
[here](https://hub.docker.com/r/koha/koha-testing/tags). If you want to work on
a local feature branch in Koha, make sure that `SYNC_REPO` points to the
correct directory on your machine, and that you are in the correct branch
there. Please also note that the Koha sources are installed to
`/kohadevbox/koha` (via `koha-gitify`) and not `/usr/share/koha`!

## Advanced usage

### Docker parameters

With some exceptions (when using `--shell` or `--logs`) the `ktd` script is mostly a wrapper for
the `docker compose` tool. So all trailing options after the shipped option switches will be passed
to the underlying `docker compose` command.

For example, if you want to run _KTD_ in daemon mode, so it doesn't take over the terminal or die
if you close it, you can run it like this:

```shell
ktd <options> up -d
```

where `<options>` are the valid `ktd` option switches. If your usage requires more options you should
check `docker compose --help` or refer to the [Docker compose documentation](https://docs.docker.com/compose/).

### Developing plugins using ktd
ktd ships with some nice tools for working with plugins

Please see the [wiki](https://gitlab.com/koha-community/koha-testing-docker/-/wikis/Developing-plugins) for details

### Keycloak / SSO
ktd ships with a keycloak option so one may use it for testing and developing single sign on functionality.

Please see the [wiki](https://gitlab.com/koha-community/koha-testing-docker/-/wikis/Using-Keycloak/) for details

## Problems?

### If you see the following error on 'ku' after initial setup, try a reboot

```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

### If starting fails with "database not empty", try running `ktd down` or `kd`
It's likely that last start of KTD failed and needs cleanup. Or that it was shutdown without `ktd down` or `kd` that are necessary for a clean shutdown.

# Documentation

For more advanced options and more detailed explainations of how this project works please see the [wiki](https://gitlab.com/koha-community/koha-testing-docker/-/wikis/Koha-Testing-Docker)
