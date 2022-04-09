# Base it on Debian 10
#FROM debian:buster
#FROM i386/debian:buster
#FROM kohaaloha/raspbian:buster-slim
#FROM arm64v8/debian:buster
FROM arm64v8/debian:unstable-slim
#FROM arm64v8/debian:latest
#FROM arm64v8/debian:latest-slim

# File Author / Maintainer
LABEL maintainer="mtj@kohaaloha.com"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
    && apt-get -y install \
    idzebra* \
    libidzebra* \
    ca-certificates \
    wget \
    gnupg2 \
    libnet-stomp-perl \
    rabbitmq-server \
    libapache2-mpm-itk \
    sudo

# Set suitable debian sources
#RUN echo "deb http://httpredir.debian.org/debian buster main" > /etc/apt/sources.list
#RUN echo "deb http://security.debian.org/ buster/updates main" >> /etc/apt/sources.list

##RUN echo "deb [trusted=yes] http://archive.raspbian.org/raspbian buster  main contrib non-free rpi" >>  /etc/apt/sources.list

ENV REFRESHED_AT 2019-10-01-0
RUN wget -q -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -

# Add Koha development repositories
#RUN echo "deb http://debian.koha-community.org/koha-staging dev main buster" >> /etc/apt/sources.list.d/koha.list
#RUN echo "deb http://debian.koha-community.org/koha 21.05 main" >> /etc/apt/sources.list.d/koha.list

RUN echo "deb http://debian.koha-community.org/koha-staging stable main" >> /etc/apt/sources.list.d/koha.list
RUN echo "deb http://deb3.kohaaloha.com/ka/koha-deps stable main buster" >> /etc/apt/sources.list.d/koha.list

# Temporary dependencies
RUN apt-get -y update \
    && apt-get -y install koha-core \
      libplack-middleware-logwarn-perl \
      libemail-stuffer-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*


# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      rabbitmq-server \
      apache2 \
      libapache2-mpm-itk \
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
      netcat-openbsd \
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
            cgi

RUN mkdir /kohadevbox
WORKDIR /kohadevbox

# Install testing extras
RUN cpanm -i --force -n \
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
RUN echo "deb http://deb.nodesource.com/node_12.x buster main" > /etc/apt/sources.list.d/node.list
# Add yarn repo
RUN wget -q -O- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
# Install Node.js and Yarn
RUN apt-get update \
   && apt-get -y install nodejs yarn \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

# Install gulp
RUN npm install gulp-cli -g

# Add git-bz
RUN cd /usr/local/share \
    && git clone --depth 1 --branch apply_on_cascade https://gitlab.com/koha-community/git-bz git-bz \
    && ln -s /usr/local/share/git-bz/git-bz /usr/bin/git-bz

# Clone helper repositories
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/koha-misc4dev.git misc4dev \
    && git clone https://gitlab.com/koha-community/koha-gitify.git gitify \
    && git clone https://gitlab.com/koha-community/qa-test-tools.git

# release-tools
RUN cd /kohadevbox \
    && git clone https://gitlab.com/koha-community/release-tools.git \
    && apt-get update \
    && apt-get -y install \
        libhtml-tableextract-perl \
        libtext-multimarkdown-perl \
        md5sum \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/* \
    && cpanm -i --force -n \
        File::FindLib \
        REST::Client

## Remote debugger
RUN cd /kohadevbox \
    && ls -l \
    && wget -O run.sh https://gitlab.com/mjames/koha-testing-docker/-/raw/ka-arm64-master/files/run-core.sh \
    && cat run.sh \    
    && md5sum run.sh \    
    && ls -l

VOLUME /kohadevbox/koha

#COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
