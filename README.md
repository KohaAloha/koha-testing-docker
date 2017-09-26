# koha-testing-docker

This project aims to provide a dockered solution for running the Koha ILS
tests inside Docker containers.

It is built on a packages install on Debian 8, with the needed tweaks (including koha-gitify)
in order to create such environment.

The *docker-compose.yml* file is self explanatory.

It requires:
- Docker
- Docker Compose

Note: I rushed to publish this to get more eyes on it earlier. The TODOs explains this.

**TODO:** Make it run the tests by default (it currently launches a bash shell for debugging purposes)
**TODO:** Write a better README.

## Usage

* First, fetch this project:

```
  $ mkdir ~/git ; cd ~/git
  $ git clone https://github.com/tomascohen/koha-testing-docker.git
  $ cd koha-testing-docker
```

* Build the app image(s):


```
  $ docker-compose build
```

* Run

*Requirement*: The SYNC_REPO variable needs to be defined and contain the full path
for a Koha's git repository clone.

By default it runs the whole test suite:


Run:


```
  $ docker-compose run koha
```

If you want to do something else inside of the _koha_ container, you can add the KOHA_DOCKER_DEBUG=1
environment variable and you will be left on a bash shell in which you can run anything you want:

```
  $ KOHA_DOCKER_DEBUG=1 docker-compose run koha
```

## Run tests

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

