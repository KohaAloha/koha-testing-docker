# Base it on Debian 10
FROM debian:buster

# File Author / Maintainer
LABEL maintainer="mason@kohaaloha.com"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
RUN echo "deb http://httpredir.debian.org/debian buster main" > /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ buster/updates main" >> /etc/apt/sources.list

ENV REFRESHED_AT 2019-10-01-0

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      apache2 \
      build-essential \
      codespell \
      cpanminus \
      git \
      tig \
      libcarp-always-perl \
      libdatetimex-easy-perl \
      libdbd-sqlite2-perl \
      libdbix-class-timestamp-perl \
      libgit-repository-perl \
      liblist-compare-perl \
      libmemcached-tools \
      libmodule-install-perl \
      libmoo-perl \
      libperl-critic-perl \
      libsmart-comments-perl \
      libtest-differences-perl \
      libtest-perl-critic-perl \
      libtest-perl-critic-progressive-perl \
      libfile-chdir-perl \
      libdata-printer-perl \
      pmtools \
      locales \
      netcat \
      python-gdbm \
      vim \
      tmux \
      wget \
      curl \
      apt-transport-https \
      mlocate \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*

VOLUME /kohadevbox/koha

COPY env/defaults.env /kohadevbox/templates/defaults.env

#CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 9080 9081
