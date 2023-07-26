# Base it on Ubuntu 18.04
FROM ubuntu:18.04

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

ENV REFRESHED_AT 2021-06-17

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install \
      apache2 \
      build-essential \
      codespell \
      cpanminus \
      git \
      tig \
      libcarp-always-perl \
      libgit-repository-perl \
      libmemcached-tools \
      libmodule-install-perl \
      libperl-critic-perl \
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

# Set locales
RUN    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
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

# Add Koha development repositories
#RUN echo "deb http://debian.koha-community.org/koha-staging exp main" >> /etc/apt/sources.list.d/koha.list
RUN echo "deb http://debian.koha-community.org/koha-staging dev main bionic" >> /etc/apt/sources.list.d/koha.list
RUN echo "deb http://deb3.kohaaloha.com/ka/koha-deps stable main bionic" >> /etc/apt/sources.list.d/koha.list
RUN wget -q -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -

# Install koha-common
RUN apt-get -y update \
   && apt-get -y install \
         koha-common \
   && /etc/init.d/koha-common stop \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN mkdir /kohadevbox
WORKDIR /kohadevbox

# Install testing extras, packages and cpan
RUN apt-get -y update \
   && apt-get -y install \
         libexpat1-dev \
         libtemplate-plugin-gettext-perl \
         libdevel-cover-perl \
\
         libhttpd-bench-apachebench-perl \
         libmoosex-attribute-env-perl \
         libtest-dbix-class-perl \
         libtap-harness-junit-perl \
         libtext-csv-unicode-perl \
         libdevel-cover-report-clover-perl \
         libwebservice-ils-perl \
         libselenium-remote-driver-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN apt-get -y update \
   && apt-get -y install \
         libdevel-cover-perl

# Install temporary package
RUN apt-get -y update \
   && apt-get -y install \
         libemail-address-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

# Add Node.js
RUN wget -O- -q https://deb.nodesource.com/setup_18.x | bash -
# Pin Node.js v14
COPY files/nodejs.pin /etc/apt/preferences.d/nodejs

# Add yarn repo
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
   && wget -O- -q https://dl.yarnpkg.com/debian/pubkey.gpg \
      | gpg --dearmor \
      | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
   && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install Node.js (includes npm) and Yarn
RUN apt-get update \
   && apt-get -y install nodejs yarn \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

# Install some tool
RUN npm install -g \
            gulp-cli \
            swagger-cli

# Embed /kohadevbox/node_modules
RUN cd /kohadevbox \
    && wget -q https://gitlab.com/koha-community/Koha/-/raw/master/package.json?inline=false -O package.json \
    && wget -q https://gitlab.com/koha-community/Koha/-/raw/master/yarn.lock?inline=false -O yarn.lock \
    && yarn install --modules-folder /kohadevbox/node_modules \
    && mv /root/.cache/Cypress /kohadevbox && chown -R 1000 /kohadevbox/Cypress \
    && rm -f package.json yarn.lock

# Add git-bz
RUN cd /usr/local/share \
    && git clone --depth 1 --branch apply_on_cascade https://gitlab.com/koha-community/git-bz git-bz \
    && ln -s /usr/local/share/git-bz/git-bz /usr/bin/git-bz

# Clone helper repositories
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/koha-misc4dev.git misc4dev \
    && git clone https://gitlab.com/koha-community/koha-gitify.git gitify \
    && git clone https://gitlab.com/koha-community/qa-test-tools.git

# release-tools and koha-howto
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/release-tools.git \
    && git clone https://gitlab.com/koha-community/koha-howto.git howto \
    && apt-get update \
    && apt-get -y install \
        libhtml-tableextract-perl \
        libtext-multimarkdown-perl \
        bugz \
        libfile-findlib-perl \
        librest-client-perl \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/*

# cypress tests
RUN apt-get update \
    && apt-get -y install \
        libgtk2.0-0\
        libgtk-3-0\
        libgbm-dev\
        libnotify-dev\
        libgconf-2-4\
        libnss3\
        libxss1\
        libasound2\
        libxtst6\
        xauth\
        xvfb \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/*

# Remote debugger
RUN cd /kohadevbox \
    && wget -q -O dbgp.tar.gz https://gitlab.com/mjames/dbgp/-/raw/master/dbgp.tar.gz \
    && tar xvzf dbgp.tar.gz \
    && rm dbgp.tar.gz

# download koha-reload-starman
RUN cd /kohadevbox \
    && wget https://gitlab.com/mjames/koha-reload-starman/-/raw/master/koha-reload-starman \
    && chmod 755 koha-reload-starman \
    && apt-get update \
    && apt-get -y install inotify-tools \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/*

# Install temporary packages
RUN apt-get update \
   && apt-get -y install \
       libmojolicious-plugin-oauth2-perl \
       libmojolicious-plugin-renderfile-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env
COPY files/git_hooks /kohadevbox/git_hooks

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
