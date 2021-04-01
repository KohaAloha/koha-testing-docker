# Base it on Debian 10
FROM debian:buster

# File Author / Maintainer
#LABEL maintainer="tomascohen@theke.io"

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
        mariadb-server

#RUN while ! nc -z db 3306; do sleep 1; done

RUN apt-get -y update \
    && apt-get -y install \
        netcat \
        procps

# make a db
#RUN ps -ef | grep mysql
#RUN /etc/init.d/mysql start


#RUN mysql -u root -e "SHOW DATABASES;"
#RUN mysql -u root -e "SHOW DATABASES;"


#RUN ps -ef | grep mysql
#RUN /etc/init.d/mysql status
#RUN mysqladmin password password \

#RUN which mysql
#RUN ls -l /usr/bin/mysql
#RUN dpkg -l | grep mysql
#RUN mysql -u root -h db  -ppassword  -e "SHOW DATABASES;"
#RUN mysql -u root -h db  -ppassword  -e "CREATE DATABASE koha_kohadev;" \
# && mysql -u root -h db  -ppassword  -e "CREATE user 'koha_kohadev'@'localhost' IDENTIFIED by 'password';" \
# && mysql -u root -h db  -ppassword  -e "GRANT ALL ON 'koha_kohadev.*' TO 'koha_kohadev'@'localhost' IDENTIFIED BY 'password';" \
# && mysql -u root -h db  -ppassword  -e "SHOW DATABASES;"
#
# ---------

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
      mariadb-server \
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
RUN echo "deb [trusted=yes] http://debian.koha-community.org/koha-staging stable main" >> /etc/apt/sources.list.d/koha.list
#RUN echo "deb [trusted=yes] http://deb.kohaaloha.com/kc/koha-staging dev main buster" >> /etc/apt/sources.list.d/koha.list

# Install koha deps
RUN apt-get -y update \
   && apt-get -y install \
         koha-deps \
         koha-perldeps \
         make \
         cpanminus \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*
#   && /etc/init.d/koha-core stop \

# Install koha-common from tar

RUN adduser koha \
 && update-locale LANG=en_US.UTF-8 \
 && locale 

# && cd /tmp \
RUN mkdir /tmp-koha
WORKDIR /tmp-koha

#RUN wget https://download.koha-community.org/koha-20.11.04.tar.gz \
RUN wget http://deb3.kohaaloha.com/koha-20.11.04.tar.gz \
 && tar xvf koha*tar.gz \
 && cd koha* \
 && pwd \
 && ls \
 && ./koha_perl_deps.pl -m -u

#RUN cpanm --self-upgrade
RUN cpanm -f -v \
    DBIx::Class::Schema::PopulateMore

RUN cpanm \
    Text::CSV::Unicode \
    HTTPD::Bench::ApacheBench \
    Test::DBIx::Class \
    Selenium::Remote::Driver \
    Locale::XGettext::TT2


#RUN export
#RUN export | wc -l

#ENV DB_HOST localhost
#ENV DB_NAME koha_kohadev
#ENV DB_PASS password
#ENV DB_PORT 3306
#ENV DB_TYPE mysql
#ENV DB_USER koha_kohadev
#ENV DB_USE_TLS no
#ENV FONT_DIR /usr/share/fonts/truetype/dejavu
#ENV INSTALL_BASE /usr/share/koha
#ENV INSTALL_MODE standard
#ENV INSTALL_PAZPAR2 no
#ENV INSTALL_SRU yes
#ENV KOHA_GROUP koha_kohadev
#ENV KOHA_INSTALLED_VERSION 20.11.04.000
#ENV KOHA_USER koha_kohadev
#ENV MEMCACHED_NAMESPACE KOHA
#ENV MEMCACHED_SERVERS 127.0.0.1:11211
#ENV PATH_TO_ZEBRA /usr/bin
#ENV RUN_DATABASE_TESTS no
#ENV SMTP_DEBUG 0
#ENV SMTP_HOST localhost
#ENV SMTP_PASSWORD password
#ENV SMTP_PORT 25
#ENV SMTP_SSL_MODE disabled
#ENV SMTP_TIMEOUT 120
#ENV SMTP_USER_NAME koha_kohadev
#ENV TEMPLATE_CACHE_DIR /var/cache/koha
#ENV USE_ELASTICSEARCH no
#ENV USE_MEMCACHED yes
#ENV ZEBRA_LANGUAGE en
#ENV ZEBRA_MARC_FORMAT marc21
#ENV ZEBRA_PASS password
#ENV ZEBRA_SRU_AUTHORITIES_PORT 9999
#ENV ZEBRA_SRU_BIBLIOS_PORT 9998
#ENV ZEBRA_SRU_HOST localhost
#ENV ZEBRA_TOKENIZER chr
#ENV ZEBRA_USER koha_kohadev
#
##RUN export
##RUN export | wc -l
#
#RUN perl ./Makefile.PL  \
#        --install_mode standard \
#        --db_type mysql \
#        --db_host localhost \
#        --install_base /usr/share/koha \
#        --koha_user koha_kohadev \
#        --koha_group koha_kohadev \
#        --db_port 3306 \
#        --db_name koha_kohadev \
#        --db_user koha_kohadev \
#        --db_pass password \
#        --zebra_marc_format marc21 \
#        --zebra_language en \
#        --zebra_tokenizer chr \
#        --zebra_user koha_kohadev \
#        --zebra_pass password \
#        --zebra_sru_host localhost \
#        --zebra_sru_biblios_port 9998 \
#        --zebra_sru_authorities_port 9999 \
#        --koha_user koha_kohadev \
#        --koha_group koha_kohadev \
#        --install_sru yes \
#        --install_pazpar2 no \
#        --use_memcached yes \
#        --font_dir /usr/share/fonts/truetype/dejavu \
#        --run_database_tests no \
#        --template-cache-dir /var/cache/koha 
#

RUN mkdir /kohadevbox
WORKDIR /kohadevbox

# Install testing extras, packages and cpan
RUN apt-get -y update \
   && apt-get -y install \
         libexpat1-dev \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*

RUN cpanm -i --force -n \
       DBD::SQLite \
       HTTPD::Bench::ApacheBench \
       MooseX::Attribute::ENV \
       Test::DBIx::Class \
       TAP::Harness::JUnit \
       Text::CSV::Unicode \
       Devel::Cover::Report::Clover \
       WebService::ILS \
       Selenium::Remote::Driver \
       Locale::XGettext::TT2

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
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/* \
    && cpanm -i --force -n \
        File::FindLib \
        REST::Client

# Remote debugger
 RUN cd /kohadevbox  \
    && wget -q -O dbgp.tar.gz http://cloud.theke.io/index.php/s/pEgS35T3MktNffk/download   \
    && tar xvzf dbgp.tar.gz  \
    && rm dbgp.tar.gz

VOLUME /kohadevbox/koha

COPY files/run.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run.sh"]

EXPOSE 8080 8081
