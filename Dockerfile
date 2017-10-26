# Base it on Debian 8
FROM debian:jessie

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
RUN echo "deb http://httpredir.debian.org/debian jessie main" > /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      apache2 \
      cpanminus \
      netcat \
      libgit-repository-perl \
      liblist-compare-perl \
      libmoo-perl \
      libperl-critic-perl \
      libtest-perl-critic-perl \
      libsmart-comments-perl \
      libdatetimex-easy-perl \
      libtest-differences-perl \
      libdbd-sqlite2-perl \
      codespell \
      libdbix-class-timestamp-perl \
      libmodule-install-perl \
      build-essential \
      wget \
      git \
      locales \
      libcatmandu-marc-perl \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*


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

# Add Koha repositories
RUN echo "deb http://debian.koha-community.org/koha 16.05 main" > /etc/apt/sources.list.d/koha.list

# Add repository key
RUN wget -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -
# Install koha-common
RUN apt-get -y update \
   && apt-get -y install \
         koha-common \
   && /etc/init.d/koha-common stop \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN mkdir /kohadevbox
WORKDIR /kohadevbox

RUN git clone https://github.com/mkfifo/koha-gitify.git gitify
RUN git clone https://github.com/joubu/koha-misc4dev.git misc4dev

# Install testing extras
RUN cpanm -i \
       DBD::SQLite \
       HTTPD::Bench::ApacheBench \
       MooseX::Attribute::ENV \
       Test::DBIx::Class \
       TAP::Harness::JUnit \
       Text::CSV::Unicode \
       Devel::Cover::Report::Clover \
       WebService::ILS \
       Catmandu::Store::ElasticSearch

# Patch Devel::Cover to skip exec
RUN wget -O Devel-Cover.tar.gz \
       http://search.cpan.org/CPAN/authors/id/P/PJ/PJCJ/Devel-Cover-1.26.tar.gz \
    && tar xvzf Devel-Cover.tar.gz \
    && sed -i 's/PL_ppaddr\[OP_EXEC\]      = dc_exec;//' Devel-Cover-1.26/Cover.xs \
    && cd Devel-Cover-1.26/ \
    && cpanm -i -n .

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/instance_bashrc /kohadevbox
COPY files/koha-conf-site.xml.in /kohadevbox/koha-conf-site.xml.in

CMD ["/bin/bash", "/kohadevbox/run.sh"]
