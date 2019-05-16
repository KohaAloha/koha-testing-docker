# koha-testing-docker

This project aims to provide a dockered solution for running the Koha ILS
tests inside Docker containers.

It is built on a packages install on Debian 9, with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

It requires:
- Docker
- Docker Compose

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

```
  $ docker-compose -p koha up
```

Some people find it handy to make some start, ssh into, and stop aliases in their user's .bash_aliases, as follows:
```
  alias ku="cd /home/user/koha-testing-docker/; docker-compose -f docker-compose.yml -f docker-compose.persistent.yml up -d --force-recreate"
  alias kd="cd /home/user/koha-testing-docker/; docker-compose down"
  alias koha_ssh="docker exec -it koha_koha_1 bash"
```
Which startup command used in the aliases is variable, depending on the use case. Use the one that works best for you based on this documentation. 

Alternatively, you can have it run all the tests and exit, like this:

```
  $ export RUN_TESTS_AND_EXIT="yes"
  # Optionally you can add COVERAGE=1 so the tests generate coverage data
  $ docker-compose -p koha up --abort-on-container-exit
```

#### Database persistence

If you need to keep the DB between your different uses of the containers, you can
run

```
  $ docker-compose -f docker-compose.yml -f docker-compose.persistent.yml -p koha up
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
  $ screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
  # login with root and no password
  $ sysctl -w vm.max_map_count=262144
```

