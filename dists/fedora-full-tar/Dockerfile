# Base it on Debian 10
FROM fedora:latest

# File Author / Maintainer
#LABEL maintainer="tomascohen@theke.io"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
#RUN echo "deb http://httpredir.debian.org/debian buster main" > /etc/apt/sources.list
#RUN echo "deb http://security.debian.org/ buster/updates main" >> /etc/apt/sources.list

ENV REFRESHED_AT 2019-10-01-0

RUN mkdir /kohadevbox
RUN mkdir /kohadevbox/tar

WORKDIR /kohadevbox


# Install apache2 and testting deps
# netcat: used for checking the DB is up

#RUN dnf -y install apt
# ------------------------------------
# ------------------------------------
# ------------------------------------


RUN dnf -y update \
    && dnf -y install \
apache2 \
apt-transport-https \
at \
build-essential \
codespell \
cpanminus \
cron \
curl \
daemon \
debconf \
figlet \
fonts-dejavu \
gcc \
gettext-base \
git \
gnupg2 \
idzebra-2.0 \
libapache2-mpm-itk \
libcarp-always-perl \
libdata-printer-perl \
libemail-stuffer-perl \
libexpat1-dev \
libfile-chdir-perl \
libfribidi0 \
libfribidi-dev \
libgd3 \
libgd-dev \
libgit-repository-perl \
libgraphics-magick-perl \
libhtml-tableextract-perl \
libhtml-tidy-perl \
liblist-compare-perl \
libmariadb-dev-compat \
libmemcached-tools \
libmodule-install-perl \
libnet-z3950-simpleserver-perl \
libperl-critic-perl \
libplack-middleware-logwarn-perl \
libsmart-comments-perl \
libtest-differences-perl \
libtest-perl-critic-perl \
libtest-perl-critic-progressive-perl \
libtext-multimarkdown-perl \
libxml2 \
libxml2-dev \
libxml2-utils \
libxml-libxml-perl \
libxml-libxslt-perl \
libxslt1-dev \
libyaz-dev \
locales \
lynx \
make \
mariadb-server \
mlocate \
netcat \
nodejs \
perl \
perl-doc \
pkg-config \
pmtools \
procps \
pwgen \
python-gdbm \
rabbitmq-server \
starman \
sudo \
tig \
tmux \
tree \
ttf-dejavu \
unzip \
vim \
virtual-mysql-client \
virtual-mysql-server \
wget \
xmlstarlet \
xsltproc \
yarn \
yaz 



# ------------------------------------
# ------------------------------------
# ------------------------------------


#RUN while ! nc -z db 3306; do sleep 1; done

RUN dnf -y update \
    && dnf -y install \
        netcat \
        figlet \
        wget \
        gnupg2 \
        gettext-base \
        xsltproc \
        tree \
        libxml2-utils \
        libxml2 \
        libxml-libxml-perl \
        xmlstarlet \
        lynx \
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

RUN dnf -y update \
    && dnf -y install \
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
RUN dnf -y update \
    && dnf -y install \
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
RUN wget -q -O- https://debian.koha-community.org/koha/gpg.asc | apt-key add -
RUN echo "deb http://debian.koha-community.org/koha-staging stable main" >> /etc/apt/sources.list.d/koha.list

#RUN echo "deb [trusted=yes] http://deb.kohaaloha.com/kc/koha-staging dev main buster" >> /etc/apt/sources.list.d/koha.list

# Install koha deps
RUN dnf -y update \
   && dnf -y install \
         perl \
         koha-deps \
         make \
         cpanminus \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*
#   && /etc/init.d/koha-core stop \

# Install koha-common from tar

#RUN adduser koha_kohadev \

RUN adduser --uid 3000 koha \
 && update-locale LANG=en_US.UTF-8 \
 && locale

WORKDIR /kohadevbox/tar

RUN pwd

#RUN wget https://download.koha-community.org/koha-20.11.04.tar.gz \
RUN wget -q http://deb3.kohaaloha.com/koha-20.11.04.tar.gz \
 && tar xf koha-20.11.04.tar.gz \
 && cd koha-20.11.04 \
 && pwd \
 && ls

# --------------------------
RUN dpkg -l

# Install koha deps
RUN dnf -y update \
   && dnf -y install \
\
libgraphics-magick-perl \
 libhtml-tidy-perl \
 libnet-z3950-simpleserver-perl \
 libxml-libxslt-perl \
 libxslt1-dev \
 libxml2 \
 libxml2-dev \
 libxml2-utils \
 libfribidi0 \
 libfribidi-dev \
 libgd3 \
 libgd-dev \
 build-essential \
libmariadb-dev-compat \
libyaz-dev \
yaz \
gcc \
 pkg-config \
\
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/api/lists/*
#


# --------------------------
RUN cpanm -n Data::Validate::Domain \
    && cpanm -n Net::IDN::Encode \
    && cpanm -n Data::Validate::IP \
    && cpanm -n -f JSON::Validator@3.25 \
    && cpanm -n -f Mojolicious@8.12  \
    && cpanm -n -f Mojolicious::Plugin::OpenAPI@2.16

RUN cpanm -n  Text::Unidecode \
 &&  cpanm -n  Test::DBIx::Class  \
 &&  cpanm -n  AnyEvent::HTTP  \
 &&  cpanm -n  Net::LDAP::Filter  \
 &&  cpanm -n  CGI::Session::Driver::memcached  \
 &&  cpanm -n  Net::LDAP  \
 &&  cpanm -n  File::Copy  \
 &&  cpanm -n  Lingua::Ispell  \
 &&  cpanm -n  Test::MockTime  \
 &&  cpanm -n  Moo  \
 &&  cpanm -n  Net::Server  \
 &&  cpanm -n  HTTPD::Bench::ApacheBench  \
 &&  cpanm -n  Net::SFTP::Foreign  \
 &&  cpanm -n  Test::MockObject  \
 &&  cpanm -n  SMS::Send  \
 &&  cpanm -n  Archive::Extract  \
 &&  cpanm -n  File::Path  \
 &&  cpanm -n  Archive::Zip  \
 &&  cpanm -n  Text::CSV::Unicode  \
 &&  cpanm -n  Test::Strict  \
 &&  cpanm -n  Test::Deep  \
 &&  cpanm -n  Module::Load::Conditional  \
 &&  cpanm -n  XML::Writer  \
 &&  cpanm -n  Test::Exception  \
 &&  cpanm -n  Test::Warn  \
 &&  cpanm -n  Sys::CPU  \
 &&  cpanm -n  Test::WWW::Mechanize  \
 &&  cpanm -n  Time::Fake  \
 &&  cpanm -n  Net::OAuth2::AuthorizationServer  \
 &&  cpanm -n  File::Temp  \
 &&  cpanm -n  Module::Pluggable  \
 &&  cpanm -n  AnyEvent  \
 &&  cpanm -n  Parallel::ForkManager  \
 &&  cpanm -n  Module::Bundled::Files  \
 &&  cpanm -n  DBD::SQLite2  \
 &&  cpanm -n  Test::YAML::Valid  \
 &&  cpanm -n  PDF::FromHTML  \
 &&  cpanm -n  Locale::XGettext::TT2  \
 &&  cpanm -n  Devel::Cover  \
 &&  cpanm -n  Selenium::Remote::Driver  \
 &&  cpanm -n  WebService::ILS  \
 &&  cpanm -n  Gravatar::URL  \
 &&  cpanm -n  UNIVERSAL::require  \
 &&  cpanm -n  Template::Plugin::Stash  \
 &&  cpanm -n  LWP::Protocol::https  \
 &&  cpanm -n  Crypt::Eksblowfish::Bcrypt  \
 &&  cpanm -n  Data::ICal  \
 &&  cpanm -n  Authen::CAS::Client  \
 &&  cpanm -n  XML::Dumper  \
 &&  cpanm -n  Digest::MD5  \
 &&  cpanm -n  Locale::Language  \
 &&  cpanm -n  DateTime::Event::ICal  \
 &&  cpanm -n  GD::Barcode::UPCE  \
 &&  cpanm -n  Class::Accessor  \
 &&  cpanm -n  Email::Sender  \
 &&  cpanm -n  PDF::Reuse  \
 &&  cpanm -n  Log::Log4perl  \
 &&  cpanm -n  DBI  \
 &&  cpanm -n  String::Random  \
 &&  cpanm -n  Test  \
 &&  cpanm -n  XML::RSS  \
 &&  cpanm -n  Number::Format  \
 &&  cpanm -n  DBIx::RunSQL  \
 &&  cpanm -n  List::MoreUtils  \
 &&  cpanm -n  Text::CSV  \
 &&  cpanm -n  Time::HiRes  \
 &&  cpanm -n  Email::Stuffer  \
 &&  cpanm -n  MIME::Base64  \
 &&  cpanm -n  Bytes::Random::Secure  \
 &&  cpanm -n  DBD::Mock  \
 &&  cpanm -n  IPC::Cmd  \
 &&  cpanm -n  Modern::Perl  \
 &&  cpanm -n  Test::MockModule  \
 &&  cpanm -n  Email::MessageID  \
 &&  cpanm -n  YAML::Syck  \
 &&  cpanm -n  PDF::Reuse::Barcode  \
 &&  cpanm -n  Storable  \
 &&  cpanm -n  GD  \
 &&  cpanm -n  Readonly  \
 &&  cpanm -n  MIME::QuotedPrint  \
 &&  cpanm -n  CGI  \
 &&  cpanm -n  Module::CPANfile  \
 &&  cpanm -n  URI::Escape  \
 &&  cpanm -n  Text::Bidi  \
 &&  cpanm -n  Cache::Memcached::Fast::Safe  \
 &&  cpanm -n  Date::Manip  \
 &&  cpanm -n  DateTime::Format::ICal  \
 &&  cpanm -n  Plack::Middleware::LogWarn  \
 &&  cpanm -n  DBD::mysql  \
 &&  cpanm -n  HTTP::Cookies  \
 &&  cpanm -n  MARC::Record::MiJ  \
 &&  cpanm -n  Unicode::Normalize  \
 &&  cpanm -n  UUID  \
 &&  cpanm -n  DateTime  \
 &&  cpanm -n  HTTP::Request::Common  \
 &&  cpanm -n  CPAN::Meta  \
 &&  cpanm -n  HTML::Scrubber  \
 &&  cpanm -n  Sereal::Encoder  \
 &&  cpanm -n  Net::CIDR  \
 &&  cpanm -n  LWP::UserAgent  \
 &&  cpanm -n  Schedule::At  \
 &&  cpanm -n  Time::localtime  \
 &&  cpanm -n  Text::PDF  


RUN cpanm -n  Text::Iconv  \
&&  cpanm -n  Lingua::Stem::Snowball  \
&&  cpanm -n  YAML  \
&&  cpanm -n  MIME::Lite  \
&&  cpanm -n  HTTP::OAI  \
&&  cpanm -n  Locale::Messages  \
&&  cpanm -n  JSON  \
&&  cpanm -n  WWW::CSRF  \
&&  cpanm -n  MARC::Record  \
&&  cpanm -n  XML::SAX::ParserFactory  \
&&  cpanm -n  Business::ISBN  \
&&  cpanm -n  PDF::API2  \
&&  cpanm -n  Text::CSV::Encoded  \
&&  cpanm -n  DBIx::Class::Schema::Loader  \
&&  cpanm -n  HTML::FormatText  \
&&  cpanm -n  OpenOffice::OODoc  \
&&  cpanm -n  Search::Elasticsearch  \
&&  cpanm -n  Lingua::Stem  \
&&  cpanm -n  POSIX  \
&&  cpanm -n  UNIVERSAL::can  \
&&  cpanm -n  Sereal::Decoder  \
&&  cpanm -n  Getopt::Std  \
&&  cpanm -n  Biblio::EndnoteStyle  \
&&  cpanm -n  CGI::Session::Serialize::yaml  \
&&  cpanm -n  Email::Valid  \
&&  cpanm -n  Text::Wrap  \
&&  cpanm -n  XML::Simple  \
&&  cpanm -n  File::Slurp  \
&&  cpanm -n  MARC::Charset  \
&&  cpanm -n  Try::Tiny  \
&&  cpanm -n  XML::LibXML  \
&&  cpanm -n  Algorithm::CheckDigits  \
&&  cpanm -n  Font::TTF  \
&&  cpanm -n  CGI::Emulate::PSGI  \
&&  cpanm -n  Data::Dumper  \
&&  cpanm -n  DateTime::TimeZone  \
&&  cpanm -n  CGI::Compile  \
&&  cpanm -n  XML::SAX::Writer  \
&&  cpanm -n  LWP::Simple  \
&&  cpanm -n  Template  \
&&  cpanm -n  Business::ISSN  \
&&  cpanm -n  Text::CSV_XS  \
&&  cpanm -n  Class::Inspector  \
&&  cpanm -n  Exception::Class  \
&&  cpanm -n  Locale::Currency::Format  \
&&  cpanm -n  CGI::Carp  \
&&  cpanm -n  List::Util  \
&&  cpanm -n  Date::Calc  \
&&  cpanm -n  MARC::File::XML  \
&&  cpanm -n  Plack::Middleware::ReverseProxy  \
&&  cpanm -n  HTML::Entities  \
&&  cpanm -n  PDF::Table  \
&&  cpanm -n  Email::Date  \
&&  cpanm -n  Clone  \
&&  cpanm -n  Test::More  \
&&  cpanm -n  Net::Stomp  \
&&  cpanm -n  Template::Plugin::HtmlToText  \
&&  cpanm -n  Library::CallNumber::LC  \
&&  cpanm -n  Array::Utils  \
&&  cpanm -n  Term::ANSIColor  \
&&  cpanm -n  Test::Harness  \
&&  cpanm -n  Cache::Memcached  \
&&  cpanm -n  Template::Plugin::JSON::Escape  \
&&  cpanm -n  Net::Z3950::ZOOM  \
&&  cpanm -n  Digest::SHA  \
&&  cpanm -n  Getopt::Long  \
&&  cpanm -n  CGI::Session  \
&&  cpanm -n  Locale::PO  \
&&  cpanm -n  DateTime::Format::MySQL  \
&&  cpanm -n  Net::Netmask  \
&&  cpanm -n  Class::Factory::Util


# --------------------------
WORKDIR /kohadevbox/tar/koha-20.11.04
RUN pwd
RUN  ./koha_perl_deps.pl -a
RUN  ./koha_perl_deps.pl -m -u

#RUN cpanm --self-upgrade
RUN cpanm \
    DBD::SQLite \
    DBIx::Class::Schema::PopulateMore \
    Text::CSV::Unicode \
    HTTPD::Bench::ApacheBench \
    Test::DBIx::Class \
    Selenium::Remote::Driver \
    Locale::XGettext::TT2


WORKDIR /kohadevbox
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

# Install testing extras, packages and cpan
RUN dnf -y update \
   && dnf -y install \
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
RUN dnf update \
   && dnf -y install nodejs yarn \
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
    && dnf update \
    && dnf -y install \
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
