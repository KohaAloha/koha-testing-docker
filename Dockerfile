# Base it on Ubunt 18.04
FROM ubuntu:18.04

# File Author / Maintainer
LABEL maintainer="tomascohen@theke.io"

ENV REFRESHED_AT 2018-10-25-1

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Install apache2 and testing deps
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
      curl \
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

# Add Koha development repositories
RUN echo "deb http://debian.koha-community.org/koha 18.05 main" > /etc/apt/sources.list.d/koha.list

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

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
