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
#RUN echo "deb http://httpredir.debian.org/debian buster main" > /etc/apt/sources.list
#RUN echo "deb http://security.debian.org/ buster/updates main" >> /etc/apt/sources.list

##RUN echo "deb [trusted=yes] http://archive.raspbian.org/raspbian buster  main contrib non-free rpi" >>  /etc/apt/sources.list

ENV REFRESHED_AT 2019-10-01-0

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      apache2 \
      cpanminus \
      git \
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

# Temporary dependencies
RUN apt-get -y update \
    && apt-get -y install \
      libplack-middleware-logwarn-perl \
      libemail-stuffer-perl \
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

RUN wget -q -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -

# Add Koha development repositories
#RUN echo "deb http://debian.koha-community.org/koha-staging dev main buster" >> /etc/apt/sources.list.d/koha.list
RUN echo "deb http://debian.koha-community.org/koha 21.05 main" >> /etc/apt/sources.list.d/koha.list

# Install koha-common
RUN apt-get -y update \
   && apt-get -y install \
         koha-full \
   && /etc/init.d/koha-core stop \
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
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/* \
    && cpanm -i --force -n \
        File::FindLib \
        REST::Client

## Remote debugger
#RUN cd /kohadevbox \
#    && wget -q -O dbgp.tar.gz https://theke-space-one.nyc3.digitaloceanspaces.com/dbgp.tar.gz \
#    && tar xvzf dbgp.tar.gz \
#    && rm dbgp.tar.gz

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
