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

- A generic x86_64 system or arm64v8 system (Apple M1/M2, AWS EC2 Graviton)
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
git clone --branch master --single-branch https://git.koha-community.org/Koha-community/Koha.git koha
```

**Note:** this will do a shallow clone only fetching the master branch to speed up the process. Alternatively, you could do a full clone with

```shell
git clone https://git.koha-community.org/Koha-community/Koha.git koha
# be patient, it's a >1.4GiB download (2023-05)
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

* Add your user to the docker group

```shell
sudo usermod -aG docker ${USER}
```

Then reboot or restart your session.

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
ktd --selenium --os1 --plugin --sso up
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

### Hot-reload Plack / automatic reload after code changes

Adding hot-reload to `koha-plack` is not feasable. Here is a slightly hackish way to enable it anyway:

1. Start ktd
2. In a second terminal, start a second shell: `ktd --shell`
3. In that shell, first stop plack: `koha-plack --stop kohadev`
4. Then start Koha directly via `plackup`:

```
DEV_INSTALL=1 KOHA_HOME=/kohadevbox/koha \
  /usr/bin/plackup -M FindBin --workers 2 --user=kohadev-koha --group=kohadev-koha  -E deployment --socket /var/run/koha/kohadev/plack.sock -s Starman \
  -R /kohadevbox/koha \
  /etc/koha/plack.psgi
```

Using `-R /kohadevbox/koha` makes `plackup` watch everything in `/kohadevbox/koha` and will restart Plack on changes to any file in that directory. Depending on what you are doing, it make more sense to use eg `-R /kohadevbox/koha/Koha -R /kohadevbox/koha/C4`.

You can also add `DEV_INSTALL` and `KOHA_HOME` to your `.env` file so you don't have to specify them here.

## Translation files

Translation files (.po files) have been removed from [the docker container](https://gitlab.com/koha-community/koha-testing-docker/-/issues/386) and [the Koha codebase](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174).

When ktd container starts up, it will deal with the .po files if needed, depending on the state of misc/translator/po
 1. If empty [koha-l10n](https://gitlab.com/koha-community/koha-l10n) will be cloned
 2. If exists and is a git repository, koha-l10n will be pulled and the corresponding branch will be checked out (if there is no changes!)
 3. If exists and is not a git repository, nothing is done (we are on a branch prior to the removal)

Note that ktd will not automatically remove changes that have been made to the .po files.

### Update the files

#### Fetch new translations
To manually fetch new translations from koha-l10n (and so Weblate) you can fetch the git repository.

For master:
```shell
cd misc/translator/po
git fetch origin
git reset --hard origin/master
```

#### With new strings

If you want to update the .po files with new strings you have in your Koha codebase (when testing a patch for instance):
```shell
# in a koha-shell
gulp po:update --lang $LANG
```

To generate new templates using those new .po files
```
# in a root shell
koha-translate --update $LANG --dev kohadev
```

(Yes, this is confusing)

### Common problems
#### Detached HEAD
If you get 'You are not currently on a branch' it means that you are not on a branch. This has been by a previous bug in ktd. You should pull a newest koha-testing-docker docker image 

#### Incorrect permissions
If misc/translator/po does not have the correct permissions (not owned by kohadev-koha), the gulp command will fail with something similar to
```
msgmerge: cannot create output file "misc/translator/po/es-ES-pref.po": Permission denied
```
You need to adjust the permissions with
```shell
chown -R kohadev-koha:kohadev-koha misc/translator/po
```

#### Error: ENOENT: no such file or directory, open '/tmp/.../Koha-xxx.pot'

koha-l10n is not up-to-date. You can update with with:
```
cd misc/translator/po
git fetch origin
git reset --hard origin/master
```

#### Error: ENOENT: no such file or directory, stat '[...]how-to.pl'

See Koha [bug 34915](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34915) and [issue #401](https://gitlab.com/koha-community/koha-testing-docker/-/issues/401).

### Another problems?

If you are getting another problem you should locate the "Fetching koha-l10n" line in ktd startup and see if you have an error right after.
This is the kind of output you will have when ktd starts up after a gulp po:update session
```
koha-koha-1       | Install Koha-how-to
koha-koha-1       | Fetching koha-l10n
koha-koha-1       | From https://gitlab.com/koha-community/koha-l10n
koha-koha-1       |    37ed79d3..c4cc4e86  master      -> origin/master
koha-koha-1       |    23095e8c..0470ed29  21.11       -> origin/21.11
koha-koha-1       |    23aab8b2..154a1a8c  22.05       -> origin/22.05
koha-koha-1       |    7b797c63..8d4a7671  22.11       -> origin/22.11
koha-koha-1       |    7fe82983..e80f8014  23.05       -> origin/23.05
koha-koha-1       |    0f739e99..fbcab13e  terminology -> origin/terminology
koha-koha-1       | error: Your local changes to the following files would be overwritten by checkout:
koha-koha-1       |     es-ES-staff-prog.po
koha-koha-1       | Please commit your changes or stash them before you switch branches.
koha-koha-1       | Aborting
koha-koha-1       | Chowing po files
```

## Problems?

### If you see the following error on 'ku' after initial setup, try a reboot

```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

### If starting fails with "database not empty", try running `ktd down` or `kd`
It's likely that last start of KTD failed and needs cleanup. Or that it was shutdown without `ktd down` or `kd` that are necessary for a clean shutdown.

# Documentation

For more advanced options and more detailed explainations of how this project works please see the [wiki](https://gitlab.com/koha-community/koha-testing-docker/-/wikis/Koha-Testing-Docker)
