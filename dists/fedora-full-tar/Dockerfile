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
glibc-langpack-en \
hostname \
uuid \
uuid-devel \
mariadb-connector-c-devel \
GraphicsMagick-devel \
GraphicsMagick \
GraphicsMagick-perl


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

#RUN echo "LANG=en_US.utf8" > /etc/locale.conf \
# && echo "LC_ALL=en_US.UTF-8"  >> /etc/environment \
# && echo "LC_CTYPE=en_US.UTF-8" >> /etc/environment \
# && echo "LANGUAGE=en_US.UTF-8" >> /etc/environment

RUN cat /etc/environment
#RUN yum reinstall glibc-common -y
#    && localedef -c -f UTF-8 -i en_US en_US.UTF-8

#    && localedef -c \
#        -i en_US \
#        -f UTF-8 \

#ENV LANGUAGE en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8
#ENV LC_CTYPE en_US.UTF-8

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

#RUN wget -q http://deb3.kohaaloha.com/koha-20.11.04.tar.gz \
RUN wget -q  https://download.koha-community.org/koha-20.11-latest.tar.gz \
 && tar xfz koha-20.11-latest.tar.gz \
 && rm koha-20.11-latest.tar.gz \
 && mv koha-20.11* koha-20.11 \
 && cd koha-20.11 \
 && pwd \
 && ls


# --------------------------
RUN dnf list installed

#RUN cpanm -i --force -n \
#        File::FindLib \
#        REST::Client \
#        HTML::TableExtract \
#        Text::MultiMarkdown


# --------------------------
RUN cpanm -n -f JSON::Validator@3.25 \
    Mojolicious@8.12  \
    Mojolicious::Plugin::OpenAPI@2.16

RUN cpanm -n Data::Validate::Domain \
     Net::IDN::Encode \
     Data::Validate::IP \
     Text::Unidecode \
     Test::DBIx::Class  \
     AnyEvent::HTTP  \
     Net::LDAP::Filter  \
     CGI::Session::Driver::memcached  \
     Net::LDAP  \
     File::Copy  \
     Lingua::Ispell  \
     Test::MockTime  \
     Moo  \
     Net::Server  \
     HTTPD::Bench::ApacheBench  \
     Net::SFTP::Foreign  \
     Test::MockObject  \
     SMS::Send  \
     Archive::Extract  \
     File::Path  \
     Archive::Zip  \
     Text::CSV::Unicode  \
     Test::Strict  \
     Test::Deep  \
     Module::Load::Conditional  \
     XML::Writer  \
     Test::Exception  \
     Test::Warn  \
     Sys::CPU  \
     Test::WWW::Mechanize  \
     Time::Fake  \
     Net::OAuth2::AuthorizationServer  \
     File::Temp  \
     Module::Pluggable  \
     AnyEvent  \
     Parallel::ForkManager  \
     Module::Bundled::Files  \
     DBD::SQLite2  \
     Test::YAML::Valid  \
     PDF::FromHTML  \
     Locale::XGettext::TT2  \
     Selenium::Remote::Driver  \
     WebService::ILS  \
     Gravatar::URL  \
     UNIVERSAL::require  \
     Template::Plugin::Stash  \
     LWP::Protocol::https  \
     Crypt::Eksblowfish::Bcrypt  \
     Data::ICal  \
     Authen::CAS::Client  \
     XML::Dumper  \
     Digest::MD5  \
     Locale::Language  \
     DateTime::Event::ICal  \
     GD::Barcode::UPCE  \
     Class::Accessor  \
     Email::Sender  \
     PDF::Reuse  \
     Log::Log4perl  \
     DBI  \
     String::Random  \
     Test  \
     XML::RSS  \
     Number::Format  \
     DBIx::RunSQL  \
     List::MoreUtils  \
     Text::CSV  \
     Time::HiRes  \
     Email::Stuffer  \
     MIME::Base64  \
     Bytes::Random::Secure  \
     DBD::Mock  \
     IPC::Cmd  \
     Modern::Perl  \
     Test::MockModule  \
     Email::MessageID  \
     YAML::Syck  \
     PDF::Reuse::Barcode  \
     Storable  \
     GD  \
     Readonly  \
     MIME::QuotedPrint  \
     CGI  \
     Module::CPANfile  \
     URI::Escape  \
     Text::Bidi  \
     Cache::Memcached::Fast::Safe  \
     Date::Manip  \
     DateTime::Format::ICal  \
     Plack::Middleware::LogWarn  \
     DBD::mysql  \
     HTTP::Cookies  \
     MARC::Record::MiJ  \
     Unicode::Normalize  \
     UUID  \
     DateTime  \
     HTTP::Request::Common  \
     CPAN::Meta  \
     HTML::Scrubber  \
     Sereal::Encoder  \
     Net::CIDR  \
     LWP::UserAgent  \
     Schedule::At  \
     Time::localtime  \
     Text::PDF


RUN cpanm -n  Text::Iconv  \
    Lingua::Stem::Snowball  \
    YAML  \
    MIME::Lite  \
    HTTP::OAI  \
    Locale::Messages  \
    JSON  \
    WWW::CSRF  \
    MARC::Record  \
    XML::SAX::ParserFactory  \
    Business::ISBN  \
    PDF::API2  \
    Text::CSV::Encoded  \
    DBIx::Class::Schema::Loader  \
    HTML::FormatText  \
    OpenOffice::OODoc  \
    Search::Elasticsearch  \
    Lingua::Stem  \
    POSIX  \
    UNIVERSAL::can  \
    Sereal::Decoder  \
    Getopt::Std  \
    Biblio::EndnoteStyle  \
    CGI::Session::Serialize::yaml  \
    Email::Valid  \
    Text::Wrap  \
    XML::Simple  \
    File::Slurp  \
    MARC::Charset  \
    Try::Tiny  \
    XML::LibXML  \
    Algorithm::CheckDigits  \
    Font::TTF  \
    CGI::Emulate::PSGI  \
    Data::Dumper  \
    DateTime::TimeZone  \
    CGI::Compile  \
    XML::SAX::Writer  \
    LWP::Simple  \
    Template  \
    Business::ISSN  \
    Text::CSV_XS  \
    Class::Inspector  \
    Exception::Class  \
    Locale::Currency::Format  \
    CGI::Carp  \
    List::Util  \
    Date::Calc  \
    MARC::File::XML  \
    Plack::Middleware::ReverseProxy  \
    HTML::Entities  \
    PDF::Table  \
    Email::Date  \
    Clone  \
    Test::More  \
    Net::Stomp  \
    Template::Plugin::HtmlToText  \
    Library::CallNumber::LC  \
    Array::Utils  \
    Term::ANSIColor  \
    Test::Harness  \
    Cache::Memcached  \
    Template::Plugin::JSON::Escape  \
    Net::Z3950::ZOOM  \
    Digest::SHA  \
    Getopt::Long  \
    CGI::Session  \
    Locale::PO  \
    DateTime::Format::MySQL  \
    Net::Netmask  \
    Class::Factory::Util \
    XML::LibXSLT \
    Net::Z3950::SimpleServer

# --------------------------
WORKDIR /kohadevbox/tar/koha-20.11
RUN pwd
RUN  ./koha_perl_deps.pl -a
RUN  ./koha_perl_deps.pl -m -u

#RUN cpanm --self-upgrade
RUN cpanm -n \
    DBD::SQLite \
    DBIx::Class::Schema::PopulateMore \
    Text::CSV::Unicode \
    HTTPD::Bench::ApacheBench \
    Test::DBIx::Class \
    Selenium::Remote::Driver \
    CGI::Session::Serialize::yaml \
    Email::Valid \
    YAML::Syck \
    Locale::XGettext::TT2 \
    Devel::Cover::Report::Clover \
    MooseX::Attribute::ENV \
    TAP::Harness::JUnit \
    WebService::ILS

WORKDIR /kohadevbox
RUN export


# Patch Devel::Cover to skip exec
#RUN wget -O Devel-Cover.tar.gz \
#       http://search.cpan.org/CPAN/authors/id/P/PJ/PJCJ/Devel-Cover-1.26.tar.gz \
#    && tar xvzf Devel-Cover.tar.gz \
#    && sed -i 's/PL_ppaddr\[OP_EXEC\]      = dc_exec;//' Devel-Cover-1.26/Cover.xs \
#    && cd Devel-Cover-1.26/ \
#    && cpanm -i -n .

# Install Node.js and Yarn
RUN dnf -y install nodejs yarnpkg perl-Devel-Cover

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
    && wget -q -O dbgp.tar.gz https://gitlab.com/mjames/dbgp/-/raw/master/dbgp.tar.gz \
    && tar xvzf dbgp.tar.gz  \
    && rm dbgp.tar.gz

RUN mkdir -p /etc/mysql

VOLUME /kohadevbox/koha

COPY files/run-fed.sh /kohadevbox
COPY files/run-fed1.sh /kohadevbox
COPY files/run-fed2.sh /kohadevbox
COPY files/templates /kohadevbox/templates
COPY env/defaults.env /kohadevbox/templates/defaults.env

CMD ["/bin/bash", "/kohadevbox/run-fed1.sh"]

EXPOSE 8080 8081
