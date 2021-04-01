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

# Set a fixed hostname
echo "kohadevbox" > /etc/hostname
echo "127.0.0.1 kohadevbox" >> /etc/hosts
hostname kohadevbox

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
echo "[client]"                   > /etc/mysql/koha-common.cnf
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
export MEMCACHED_SERVERS='127.0.0.1:11211'
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

perl ./Makefile.PL  \
        --install_mode standard \
        --db_type mysql \
        --db_host localhost \
        --install_base /usr/share/koha \
        --koha_user koha_kohadev \
        --koha_group koha_kohadev \
        --db_port 3306 \
        --db_name koha_kohadev \
        --db_user koha_kohadev \
        --db_pass password \
        --zebra_marc_format marc21 \
        --zebra_language en \
        --zebra_tokenizer chr \
        --zebra_user koha_kohadev \
        --zebra_pass password \
        --zebra_sru_host localhost \
        --zebra_sru_biblios_port 9998 \
        --zebra_sru_authorities_port 9999 \
        --koha_user koha_kohadev \
        --koha_group koha_kohadev \
        --install_sru yes \
        --install_pazpar2 no \
        --use_memcached yes \
        --font_dir /usr/share/fonts/truetype/dejavu \
        --run_database_tests no \
        --template-cache-dir /var/cache/koha


figlet 333

cd /kohadevbox/tar/koha-20.11.04
pwd

figlet 444
make
make test
make install

cp /kohadevbox/tar/koha-20.11.04/debian/scripts/koha-functions.sh /usr/share/koha/bin/koha-functions.sh
figlet 555



# -----------------------------------
# Get rid of Apache warnings
echo "ServerName kohadevdock"       >> /etc/apache2/apache2.conf
echo "Listen ${KOHA_INTRANET_PORT}" >> /etc/apache2/ports.conf
echo "Listen ${KOHA_OPAC_PORT}"     >> /etc/apache2/ports.conf

# Pull the names of the environment variables to substitute from defaults.env and convert them to a string of the format "$VAR1:$VAR2:$VAR3", etc.
VARS_TO_SUB=`cut -d '=' -f1 ${BUILD_DIR}/templates/defaults.env  | tr '\n' ':' | sed -e 's/:/:$/g' | awk '{print "$"$1}' | sed -e 's/:\$$//'`
# Add additional vars to sub from this script that are not in defaults.env
VARS_TO_SUB="\$BUILD_DIR:$VARS_TO_SUB";

envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/root_bashrc           > /root/.bashrc
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/vimrc                 > /root/.vimrc
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/bash_aliases          > /root/.bash_aliases
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/gitconfig             > /root/.gitconfig
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/koha-conf-site.xml.in > /etc/koha/koha-conf-site.xml.in
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/koha-sites.conf       > /etc/koha/koha-sites.conf

# bin
mkdir -p ${BUILD_DIR}/bin
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/bin/dbic > ${BUILD_DIR}/bin/dbic
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/bin/flush_memcached > ${BUILD_DIR}/bin/flush_memcached


# Make sure things are executable on /bin.
chmod +x ${BUILD_DIR}/bin/*

figlet koha-create

koha-create --request-db ${KOHA_INSTANCE} --memcached-servers memcached:11211

koha-list


/bin/bash -c "trap : TERM INT; sleep infinity & wait"
