#!/bin/bash -x

set -e
set -x

export BUILD_DIR=/kohadevbox
export TEMP=/tmp

# Handy variables
export KOHA_INTRANET_FQDN=${KOHA_INTRANET_PREFIX}${KOHA_INSTANCE}${KOHA_INTRANET_SUFFIX}${KOHA_DOMAIN}
export KOHA_INTRANET_URL=http://${KOHA_INTRANET_FQDN}:${KOHA_INTRANET_PORT}
export KOHA_OPAC_FQDN=${KOHA_OPAC_PREFIX}${KOHA_INSTANCE}${KOHA_OPAC_SUFFIX}${KOHA_DOMAIN}
export KOHA_OPAC_URL=http://${KOHA_OPAC_FQDN}:${KOHA_OPAC_PORT}

figlet xml
##cat /etc/perl/XML/SAX/ParserDetails.ini

#export KOHA_CONF=/etc/koha/koha-conf.xml
#export PERL5LIB=/usr/share/koha/lib

# Set a fixed hostname
echo "kohadevbox" > /etc/hostname
echo "127.0.0.1 kohadevbox" >> /etc/hosts
#hostname kohadevbox

# Clone before calling cp_debian_files.pl
if [ "${DEBUG_GIT_REPO_MISC4DEV}" = "yes" ]; then
    rm -rf ${BUILD_DIR}/misc4dev
    git clone -b ${DEBUG_GIT_REPO_MISC4DEV_BRANCH} ${DEBUG_GIT_REPO_MISC4DEV_URL} ${BUILD_DIR}/misc4dev
fi

figlet 000

#ls -l /etc/koha
#mkdir /etc/koha
mkdir -p  /etc/koha/sites

figlet 111

# Make sure we use the files from the git clone for creating the instance
perl ${BUILD_DIR}/misc4dev/cp_debian_files.pl \
            --instance          ${KOHA_INSTANCE} \
            --koha_dir          ${BUILD_DIR}/koha \
            --gitify_dir        ${BUILD_DIR}/gitify

# Wait for the DB server startup

echo '----------------------------------'
echo '----------------------------------'
echo '----------------------------------'

# TODO: Have bugs pushed so all this is a koha-create parameter
echo "${KOHA_INSTANCE}:koha_${KOHA_INSTANCE}:${KOHA_DB_PASSWORD}:koha_${KOHA_INSTANCE}" > /etc/koha/passwd
# TODO: Get rid of this hack with the relevant bug
echo "[client]"                  >> /etc/mysql/koha-common.cnf
echo "host     = ${DB_HOSTNAME}" >> /etc/mysql/koha-common.cnf
echo "user     = root"           >> /etc/mysql/koha-common.cnf
echo "password = password"       >> /etc/mysql/koha-common.cnf


echo "[client]"                          > /etc/mysql/koha_${KOHA_INSTANCE}.cnf
echo "host     = ${DB_HOSTNAME}"        >> /etc/mysql/koha_${KOHA_INSTANCE}.cnf
echo "user     = koha_${KOHA_INSTANCE}" >> /etc/mysql/koha_${KOHA_INSTANCE}.cnf
echo "password = ${KOHA_DB_PASSWORD}"   >> /etc/mysql/koha_${KOHA_INSTANCE}.cnf

# -----------------------------------


figlet 222

export DB_HOST='localhost'
export DB_NAME='koha'
export DB_PASS='password'
export DB_PORT='3306'
export DB_TYPE='mysql'
export DB_USER='koha'
export DB_USE_TLS='no'
export FONT_DIR='/usr/share/fonts/truetype/dejavu'
export INSTALL_BASE='/usr/share/koha'
export INSTALL_MODE='standard'
export INSTALL_PAZPAR2='no'
export INSTALL_SRU='yes'
export KOHA_GROUP='koha'
export KOHA_INSTALLED_VERSION='20.11.04.000'
export KOHA_USER='koha'
export MEMCACHED_NAMESPACE='KOHA'
export MEMCACHED_SERVERS='memcached:11211'
export PATH_TO_ZEBRA='/usr/bin'
export RUN_DATABASE_TESTS='no'
export SMTP_DEBUG='0'
export SMTP_HOST='localhost'
export SMTP_PASSWORD='password'
export SMTP_PORT='25'
export SMTP_SSL_MODE='disabled'
export SMTP_TIMEOUT='120'
export SMTP_USER_NAME='koha'
export TEMPLATE_CACHE_DIR='/var/cache/koha'
export USE_ELASTICSEARCH='no'
export USE_MEMCACHED='yes'
export ZEBRA_LANGUAGE='en'
export ZEBRA_MARC_FORMAT='marc21'
export ZEBRA_PASS='password'
export ZEBRA_SRU_AUTHORITIES_PORT='9999'
export ZEBRA_SRU_BIBLIOS_PORT='9998'
export ZEBRA_SRU_HOST='localhost'
export ZEBRA_TOKENIZER='chr'
export ZEBRA_USER='koha'

ls -l /
ls -l  /kohadevbox
cd /kohadevbox/tar/koha-20.11.04
pwd
ls

figlet perl ./Makefile.PL

#perl ./Makefile.PL > /tmp/make-perl.log
perl ./Makefile.PL

#        --install_mode standard \
#        --db_type mysql \
#        --db_host db \
#        --install_base /usr/share/koha \
#        --koha_user koha \
#        --koha_group koha \
#        --db_port 3306 \
#        --db_name koha \
#        --db_user koha \
#        --db_pass password \
#        --zebra_marc_format marc21 \
#        --zebra_language en \
#        --zebra_tokenizer chr \
#        --zebra_user koha \
#        --zebra_pass password \
#        --zebra_sru_host localhost \
#        --zebra_sru_biblios_port 9998 \
#        --zebra_sru_authorities_port 9999 \
#        --koha_user koha \
#        --koha_group koha \
#        --install_sru yes \
#        --install_pazpar2 no \
#        --use_memcached yes \
#        --font_dir /usr/share/fonts/truetype/dejavu \
#        --run_database_tests no \
#        --template-cache-dir /var/cache/koha

figlet 333

cd /kohadevbox/tar/koha-20.11.04
pwd

figlet make
#time make > /tmp/make.log
time make
#make test

export
figlet make install
#time make install > /tmp/make-install.log
time make install


#tree -f /usr/share/koha
figlet tree
#tree -f /usr/share/koha/lib


figlet 555

#mkdir -p /usr/share/koha/lib/t/lib
cp /kohadevbox/tar/koha-20.11.04/debian/scripts/koha-functions.sh /usr/share/koha/bin/koha-functions.sh

mkdir -p /usr/share/koha/lib/C4/SIP/t
cp /kohadevbox/tar/koha-20.11.04/C4/SIP/t/SIPtest.pm  /usr/share/koha/lib/C4/SIP/t/SIPtest.pm
cp -a /kohadevbox/tar/koha-20.11.04/t  /usr/share/koha/lib

#tree -f /usr/share/koha
figlet tree2
#tree -f /usr/share/koha/lib


# if KOHA_PROVE_CPUS is not set, then use nproc
if [ -z ${KOHA_PROVE_CPUS} ]; then
    KOHA_PROVE_CPUS=`nproc`
fi

pwd










figlet end
pwd
/bin/bash -c "trap : TERM INT; sleep infinity & wait"

