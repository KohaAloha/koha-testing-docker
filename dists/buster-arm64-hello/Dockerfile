# Base it on Debian 10
#FROM debian:buster
#FROM i386/debian:buster
#FROM kohaaloha/raspbian:buster-slim
FROM arm64v8/debian:buster

# File Author / Maintainer
LABEL maintainer="mtj@kohaaloha.com"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
##RUN echo "deb [trusted=yes] http://archive.raspbian.org/raspbian buster  main contrib non-free rpi" >>  /etc/apt/sources.list

ENV REFRESHED_AT 2019-10-01-0

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      rabbitmq-server \
      apache2 \
      build-essential \
      codespell \
      cpanminus \
      git \
      tig \
      libcarp-always-perl \
      libgit-repository-perl \
      liblist-compare-perl \
      libmemcached-tools \
      libmodule-install-perl \
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
        memcached \
 mariadb-client \
 mariadb-server \
    wget  \
    gnupg \
    npm \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*

# Set locales
RUN    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Prepare apache configuration
RUN a2dismod mpm_event
RUN a2dissite 000-default
RUN a2enmod rewrite \
            headers \
            proxy_http \
            cgi

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

#CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
