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

* Edit the *docker-compose.yml* file making the volume match your own git clone
of the Koha project's repository.
**TODO:** Make this more easily configurable.

Run:


```
  $ docker-compose run koha
```

You should be left on a bash shell in which you can check everything went ok.

## Run tests

Once you are left on the shell, you can run Koha tests as you would on KohaDevBox:


```
  $ sudo koha-shell kohadev
  $ cd koha
  $ prove t/db_dependent/Search.t
```

