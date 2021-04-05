# Base it on Debian 10
#FROM fedora:latest
FROM fedora:33

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
httpd \
at \
codespell \
cpanminus \
cronie \
curl \
libdaemon \
figlet \
dejavu-fonts-all \
gcc \
gettext \
git \
gnupg2 \
idzebra \
libidzebra \
expat \
expat-devel \
fribidi \
fribidi-devel \
gd \
gd-devel \
mariadb-server \
mariadb-devel \
libmemcached \
libtidy \
libtidy-devel \
libtidyp \
libtidyp-devel \
libxml2 \
libxml2-devel \
libxslt \
libxslt-devel \
libyaz-devel \
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
rabbitmq-server \
perl-Starman \
sudo \
tig \
tmux \
tree \
unzip \
vim \
mariadb-server \
wget \
xmlstarlet \
yarnpkg \
yaz \
\
hostname \
uuid \
uuid-devel \
mariadb-connector-c-devel


# ------------------------------------
# ------------------------------------
# ------------------------------------


#RUN while ! nc -z db 3306; do sleep 1; done

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


# Set locales
#RUN localectl set-locale LANG=en_US.utf8
# localedef -f UTF-8 -i fi_FI fi_FI.UTF-8
RUN export
RUN locale \
    && locale -a

RUN echo "LANG=en_US.utf8" > /etc/locale.conf \
 && echo "LC_ALL=en_US.UTF-8"  >> /etc/environment \
 && echo "LC_CTYPE=en_US.UTF-8" >> /etc/environment \
 && echo "LANGUAGE=en_US.UTF-8" >> /etc/environment

RUN cat /etc/environment
RUN yum reinstall glibc-common -y
#    && localedef -c -f UTF-8 -i en_US en_US.UTF-8

#    && localedef -c \
#        -i en_US \
#        -f UTF-8 \

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

RUN export
RUN locale \
    && locale -a


# Prepare apache configuration
#RUN a2dismod mpm_event
#RUN a2dissite 000-default
#RUN a2enmod rewrite \
#            headers \
#            proxy_http \
#            cgi


# Add Koha development repositories
#RUN wget -q -O- https://debian.koha-community.org/koha/gpg.asc | apt-key add -
#RUN echo "deb http://debian.koha-community.org/koha-staging stable main" >> /etc/apt/sources.list.d/koha.list

#RUN echo "deb [trusted=yes] http://deb.kohaaloha.com/kc/koha-staging dev main buster" >> /etc/apt/sources.list.d/koha.list


# Install koha-common from tar

#RUN adduser koha_kohadev \

RUN adduser --uid 3000 koha 

WORKDIR /kohadevbox/tar

RUN pwd

#RUN wget https://download.koha-community.org/koha-20.11.04.tar.gz \
RUN wget -q http://deb3.kohaaloha.com/koha-20.11.04.tar.gz \
 && tar xf koha-20.11.04.tar.gz \
 && cd koha-20.11.04 \
 && pwd \
 && ls

# --------------------------
RUN dnf list installed

RUN cpanm -i --force -n \
        File::FindLib \
        REST::Client \
        HTML::TableExtract \
        Text::MultiMarkdown


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
RUN export

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

# Install Node.js and Yarn
RUN dnf -y install nodejs yarnpkg

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
    && cpanm -i --force -n \
        File::FindLib \
        REST::Client \
        HTML::TableExtract \
        Text::MultiMarkdown

# Remote debugger
RUN cd /kohadevbox  \
    && wget -q -O dbgp.tar.gz http://cloud.theke.io/index.php/s/pEgS35T3MktNffk/download   \
    && tar xvzf dbgp.tar.gz  \
    && rm dbgp.tar.gz

VOLUME /kohadevbox/koha

COPY files/run-fed.sh /kohadevbox
COPY files/run-fed2.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run-fed.sh"]

EXPOSE 8080 8081
