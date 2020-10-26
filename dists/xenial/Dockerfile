# Base it on Ubuntu 16.04
FROM ubuntu:16.04

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

ENV REFRESHED_AT 2019-05-24-1

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
RUN echo "deb [trusted=yes] http://debian.koha-community.org/koha-staging dev main xenial" >> /etc/apt/sources.list.d/koha.list

# Temporary dependencies
RUN apt-get -y update \
    && apt-get -y install \
      libplack-middleware-logwarn-perl \
      libemail-stuffer-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*

# Install koha-common
RUN apt-get -y update \
   && apt-get -y install \
         koha-common \
         libnet-oauth2-authorizationserver-perl \
         libcatmandu-marc-perl \
         libcatmandu-store-elasticsearch-perl \
         libwww-youtube-download-perl \
         libtest-mocktime-perl \
         libintl-perl \
         libppi-perl \
         libnet-z3950-simpleserver-perl \
         libnet-netmask-perl \
         libarray-utils-perl \
         libcache-memcached-fast-safe-perl \
         libcpan-meta-perl \
         libemail-messageid-perl \
   && /etc/init.d/koha-common stop \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN mkdir /kohadevbox
WORKDIR /kohadevbox

# Install testing extras, packages and cpan
RUN apt-get -y update \
   && apt-get -y install \
         libexpat1-dev \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN cpanm -i --force \
       DBD::SQLite \
       HTTPD::Bench::ApacheBench \
       MooseX::Attribute::ENV \
       Test::DBIx::Class \
       TAP::Harness::JUnit \
       Text::CSV::Unicode \
       Devel::Cover::Report::Clover \
       WebService::ILS \
       Selenium::Remote::Driver

# Patch Devel::Cover to skip exec
RUN wget -O Devel-Cover.tar.gz \
       http://search.cpan.org/CPAN/authors/id/P/PJ/PJCJ/Devel-Cover-1.26.tar.gz \
    && tar xvzf Devel-Cover.tar.gz \
    && sed -i 's/PL_ppaddr\[OP_EXEC\]      = dc_exec;//' Devel-Cover-1.26/Cover.xs \
    && cd Devel-Cover-1.26/ \
    && cpanm -i -n .

## Add Yarn
# Add node repo
RUN wget -q -O- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb http://deb.nodesource.com/node_12.x xenial main" > /etc/apt/sources.list.d/node.list
# Add yarn repo
RUN wget -q -O- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
# Install Node.js and Yarn
RUN apt-get update \
   && apt-get -y install nodejs yarn \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

# Add git-bz
RUN cd /usr/local/share \
    && git clone --depth 1 --branch apply_on_cascade https://gitlab.com/koha-community/git-bz git-bz \
    && ln -s /usr/local/share/git-bz/git-bz /usr/bin/git-bz

# Clone helper repositories
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/koha-misc4dev.git misc4dev \
    && git clone https://github.com/mkfifo/koha-gitify.git gitify \
    && git clone https://gitlab.com/koha-community/qa-test-tools.git

# release-tools
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/release-tools.git \
    && apt-get update \
    && apt-get -y install \
        libhtml-tableextract-perl \
        libtext-multimarkdown-perl \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/* \
    && cpanm -i --force \
        File::FindLib \
        REST::Client

# Remote debugger
RUN cd /kohadevbox \
    && wget -q -O dbgp.tar.gz https://theke-space-one.nyc3.digitaloceanspaces.com/dbgp.tar.gz \
    && tar xvzf dbgp.tar.gz \
    && rm dbgp.tar.gz

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
RUN  sed -i "s|/usr/share/doc/koha-common|/kohadevbox/koha/docs|g" /kohadevbox/templates/koha-conf-site.xml.in
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
