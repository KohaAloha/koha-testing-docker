# koha-testing-docker

This project aims to provide a dockered solution for running the Koha ILS
tests inside Docker containers.

It is built on a packages install on Debian 8, with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

It requires:
- Docker
- Docker Compose

## Usage

* First, fetch this project:

```
  $ mkdir ~/git ; cd ~/git
  $ git clone https://github.com/tomascohen/koha-testing-docker.git
  $ cd koha-testing-docker
```

## Launch

*Requirement*: The SYNC_REPO variable needs to be defined and contain the full path
for a Koha's git repository clone.

### Setup

Some variables need to be set to run this:

```
  $ export SYNC_REPO=/path/to/kohaclone
  $ export LOCAL_USER_ID=$(id -u)
```

### Running

```
  $ docker-compose -p koha up
```

Alternatively, you can have it run all the tests and exit, like this:

```
  $ export RUN_TESTS_AND_EXIT="yes"
  $ docker-compose -p koha up --abort-on-container-exit
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

