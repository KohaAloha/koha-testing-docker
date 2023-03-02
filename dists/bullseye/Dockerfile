# Base it on Debian 10
FROM debian:bullseye

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
#RUN echo "deb http://httpredir.debian.org/debian bullseye main" > /etc/apt/sources.list

ENV REFRESHED_AT 2021-06-17

#RUN apt-get -y update

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install \
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
      iproute2 \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*


# -------------------------

RUN wget -q -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -

# Add Koha development repositories
RUN echo "deb http://debian.koha-community.org/koha-staging dev main" >> /etc/apt/sources.list.d/koha.list
RUN echo "deb http://deb3.kohaaloha.com/ka/koha-deps stable main bullseye" >> /etc/apt/sources.list.d/koha.list

#RUN echo "deb http://debian.koha-community.org/koha-deps exp main" >> /etc/apt/sources.list.d/koha.list


RUN apt-get -y update \
    && apt-get -y upgrade


RUN apt-get -y install libdata-uuid-perl
RUN apt-get -y install devscripts
RUN apt-get -y install libsoap-lite-perl
RUN apt-get -y install libdata-uuid-perl

RUN dpkg -l


# -------------------------

RUN echo 'deb-src http://deb.debian.org/debian bullseye main' >> /etc/apt/sources.list \
    && apt-get -y update \
    && rm -rf ~/tmp2 \
    && mkdir ~/tmp2 \
    && cd ~/tmp2 \
    && apt-get -y install  libaprutil1-dbd-sqlite3 libaprutil1-ldap libprocps8 mailcap mime-support procps psmisc devscripts nano \
    && apt-get -y install dpkg-dev debhelper libaprutil1-dev libapr1-dev libpcre3-dev autotools-dev libjansson-dev \
    && apt-get -y install jdupes liblua5.3-dev libnghttp2-dev libcurl4-openssl-dev \
    && apt-get -y install bison libbrotli-dev libssl-dev libxml2-dev lsb-release zlib1g-dev \
    && apt-get source apache2 \
    && cd `ls -d apa*/` \
    && EMAIL=mason@deb11 dch 'build local' -l +koha \
    && EMAIL=mason@deb11 dch -r "" \
    && export DEB_CFLAGS_SET="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -DBIG_SECURITY_HOLE" \
    && dpkg-buildpackage -b --no-sign \
    && cd .. \
    && rm ./apache*dbgsym* \
    && dpkg -i apache2-util*.deb \
    && dpkg -i apache2-bin*.deb \
    && dpkg -i apache2-data*.deb \
    && dpkg -i apache2_2.4*.deb \
    && dpkg -l | grep apache2 \
    && rm -rf  ~/tmp2

# -------------------------



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


COPY files/run.sh /kohadevbox
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
