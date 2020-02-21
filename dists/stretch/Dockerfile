# Base it on Debian 9
FROM debian:stretch

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
RUN echo "deb http://httpredir.debian.org/debian stretch main" > /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list

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
RUN echo "deb http://debian.koha-community.org/koha unstable main" > /etc/apt/sources.list.d/koha.list
RUN echo "deb [trusted=yes] http://apt.abunchofthings.net/koha-nightly unstable main" >> /etc/apt/sources.list.d/koha.list
# Add repository key
RUN wget -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -
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

# Install testing extras
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
RUN echo "deb http://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/node.list
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

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
