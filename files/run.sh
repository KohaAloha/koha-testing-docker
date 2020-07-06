#!/bin/bash

set -e

export BUILD_DIR=/kohadevbox
export TEMP=/tmp

# Handy variables
export KOHA_INTRANET_FQDN=${KOHA_INTRANET_PREFIX}${KOHA_INSTANCE}${KOHA_INTRANET_SUFFIX}${KOHA_DOMAIN}
export KOHA_INTRANET_URL=http://${KOHA_INTRANET_FQDN}:${KOHA_INTRANET_PORT}
export KOHA_OPAC_FQDN=${KOHA_OPAC_PREFIX}${KOHA_INSTANCE}${KOHA_OPAC_SUFFIX}${KOHA_DOMAIN}
export KOHA_OPAC_URL=http://${KOHA_OPAC_FQDN}:${KOHA_OPAC_PORT}

# Clone before calling cp_debian_files.pl
if [ "${DEBUG_GIT_REPO_MISC4DEV}" = "yes" ]; then
    rm -rf ${BUILD_DIR}/misc4dev
    git clone -b ${DEBUG_GIT_REPO_MISC4DEV_BRANCH} ${DEBUG_GIT_REPO_MISC4DEV_URL} ${BUILD_DIR}/misc4dev
fi

# Make sure we use the files from the git clone for creating the instance
perl ${BUILD_DIR}/misc4dev/cp_debian_files.pl \
            --instance          ${KOHA_INSTANCE} \
            --koha_dir          ${BUILD_DIR}/koha \
            --gitify_dir        ${BUILD_DIR}/gitify

# Wait for the DB server startup
while ! nc -z db 3306; do sleep 1; done

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

koha-create --request-db ${KOHA_INSTANCE} --memcached-servers memcached:11211
# Fix UID
if [ ${LOCAL_USER_ID} ]; then
    usermod -u ${LOCAL_USER_ID} "${KOHA_INSTANCE}-koha"
    # Fix permissions due to UID change
    chown -R "${KOHA_INSTANCE}-koha" "/var/cache/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/lib/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/lock/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/log/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/run/koha/${KOHA_INSTANCE}"
fi

# This needs to be done ONCE koha-create has run (i.e. kohadev-koha user exists)
envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/apache2_envvars > /etc/apache2/envvars

# gitify instance
cd ${BUILD_DIR}/gitify
./koha-gitify ${KOHA_INSTANCE} "/kohadevbox/koha"
cd ${BUILD_DIR}

koha-enable ${KOHA_INSTANCE} 
a2ensite ${KOHA_INSTANCE}.conf

# Update /etc/hosts so the www tests can run
echo "127.0.0.1    ${KOHA_OPAC_FQDN} ${KOHA_INTRANET_FQDN}" >> /etc/hosts

envsubst "$VARS_TO_SUB" < ${BUILD_DIR}/templates/instance_bashrc > /var/lib/koha/${KOHA_INSTANCE}/.bashrc

# Configure git-bz
cd /kohadevbox/koha
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
git config bz.default-tracker bugs.koha-community.org
git config bz.default-product Koha
git config --global bz-tracker.bugs.koha-community.org.path /bugzilla3
git config --global bz-tracker.bugs.koha-community.org.https true
git config --global core.whitespace trailing-space,space-before-tab
git config --global apply.whitespace fix
git config --global bz-tracker.bugs.koha-community.org.bz-user "${GIT_BZ_USER}"
git config --global bz-tracker.bugs.koha-community.org.bz-password "${GIT_BZ_PASSWORD}"

if [ "${DEBUG_GIT_REPO_QATESTTOOLS}" = "yes" ]; then
    rm -rf ${BUILD_DIR}/qa-test-tools
    git clone -b ${DEBUG_GIT_REPO_QATESTTOOLS_BRANCH} ${DEBUG_GIT_REPO_QATESTTOOLS_URL} ${BUILD_DIR}/qa-test-tools
fi

perl ${BUILD_DIR}/misc4dev/do_all_you_can_do.pl \
            --instance          ${KOHA_INSTANCE} \
            --userid            ${KOHA_USER} \
            --password          ${KOHA_PASS} \
            --marcflavour       ${KOHA_MARC_FLAVOUR} \
            --koha_dir          ${BUILD_DIR}/koha \
            --opac-base-url     ${KOHA_OPAC_URL} \
            --intranet-base-url ${KOHA_INTRANET_URL} \
            --gitify_dir        ${BUILD_DIR}/gitify

# Latest Depends
if [ ${CPAN} ]; then
    echo "Installing latest versions of dependancies from cpan"
    apt install cpanoutdated
    cpan-outdated --exclude-core -p | cpanm
fi

# Stop apache2
service apache2 stop

chown -R "${KOHA_INSTANCE}-koha:${KOHA_INSTANCE}-koha" "/var/log/koha/${KOHA_INSTANCE}"

# Configure and start koha-plack
koha-plack --enable ${KOHA_INSTANCE} 
koha-plack --start ${KOHA_INSTANCE} 
# Start Zebra and the Indexer
koha-zebra --start ${KOHA_INSTANCE} 
koha-indexer --start ${KOHA_INSTANCE}

# Start apache
service apache2 start

# if KOHA_PROVE_CPUS is not set, then use nproc
if [ -z ${KOHA_PROVE_CPUS} ]; then
    KOHA_PROVE_CPUS=`nproc`
fi

if [ "$RUN_TESTS_AND_EXIT" = "yes" ]; then
    cd ${BUILD_DIR}/koha
    rm -rf /cover_db/*

    if [ ${COVERAGE} ]; then
        koha-shell ${KOHA_INSTANCE} -p -c "rm -rf cover_db;
                                  JUNIT_OUTPUT_FILE=junit_main.xml \
                                  PERL5OPT=-MDevel::Cover=-db,/cover_db \
                                  KOHA_TESTING=1 \
                                  KOHA_NO_TABLE_LOCKS=1 \
                                  KOHA_INTRANET_URL=http://koha:8081 \
                                  KOHA_OPAC_URL=http://koha:8080 \
                                  KOHA_USER=${KOHA_USER} \
                                  KOHA_PASS=${KOHA_PASS} \
                                  SELENIUM_ADDR=selenium \
                                  SELENIUM_PORT=4444 \
                                  TEST_QA=1 \
                                  prove -j ${KOHA_PROVE_CPUS} \
                                  --rules='par=t/db_dependent/00-strict.t' \
                                  --rules='seq=t/db_dependent/**.t' --rules='par=**' \
                                  --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ \
                                  && touch testing.success; \
                                  mkdir cover_db; cp -r /cover_db/* cover_db;
                                  cover -report clover"
    else
        koha-shell ${KOHA_INSTANCE} -p -c "JUNIT_OUTPUT_FILE=junit_main.xml \
                                  KOHA_TESTING=1 \
                                  KOHA_NO_TABLE_LOCKS=1 \
                                  KOHA_INTRANET_URL=http://koha:8081 \
                                  KOHA_OPAC_URL=http://koha:8080 \
                                  KOHA_USER=${KOHA_USER} \
                                  KOHA_PASS=${KOHA_PASS} \
                                  SELENIUM_ADDR=selenium \
                                  SELENIUM_PORT=4444 \
                                  TEST_QA=1 \
                                  prove -j ${KOHA_PROVE_CPUS} \
                                  --rules='par=t/db_dependent/00-strict.t' \
                                  --rules='seq=t/db_dependent/**.t' --rules='par=**' \
                                  --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ \
                                  && touch testing.success"
    fi
else
    # TODO: We could use supervise as the main loop
    /bin/bash -c "trap : TERM INT; sleep infinity & wait"
fi
