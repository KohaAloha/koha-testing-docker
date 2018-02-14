#!/bin/bash

export BUILD_DIR=/kohadevbox
export TEMP=/tmp

# Handy variables
export KOHA_INTRANET_FQDN=${KOHA_INTRANET_PREFIX}${KOHA_INSTANCE}${KOHA_INTRANET_SUFFIX}${KOHA_DOMAIN}
export KOHA_INTRANET_URL=http://${KOHA_INTRANET_FQDN}:${KOHA_INTRANET_PORT}
export KOHA_OPAC_FQDN=${KOHA_OPAC_PREFIX}${KOHA_INSTANCE}${KOHA_OPAC_SUFFIX}${KOHA_DOMAIN}
export KOHA_OPAC_URL=http://${KOHA_OPAC_FQDN}:${KOHA_OPAC_PORT}

# Wait for the DB server startup
while ! nc -z db 3306; do sleep 1; done

# TODO: Have bugs pushed so all this is a koha-create parameter
echo "${KOHA_INSTANCE}:koha_${KOHA_INSTANCE}:${KOHA_DB_PASSWORD}:koha_${KOHA_INSTANCE}" > /etc/koha/passwd
# TODO: Get rid of this hack with the relevant bug
echo "[client]" > /etc/mysql/koha-common.cnf
echo "host = db" >> /etc/mysql/koha-common.cnf

# Get rid of Apache warnings
echo "ServerName kohadevdock"       >> /etc/apache2/apache2.conf
echo "Listen ${KOHA_INTRANET_PORT}" >> /etc/apache2/ports.conf
echo "Listen ${KOHA_OPAC_PORT}"     >> /etc/apache2/ports.conf

envsubst < ${BUILD_DIR}/templates/koha-conf-site.xml.in > /etc/koha/koha-conf-site.xml.in
envsubst < ${BUILD_DIR}/templates/koha-sites.conf       > /etc/koha/koha-sites.conf

koha-create --request-db ${KOHA_INSTANCE} --use-memcached --memcached-servers memcached:11211
# Fix UID
if [ ${LOCAL_USER_ID} ]; then
    usermod -u ${LOCAL_USER_ID} "${KOHA_INSTANCE}-koha"
    # Fix permissions due to UID change
    chown -R "${KOHA_INSTANCE}-koha" "/var/lib/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/lock/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/run/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/cache/koha/${KOHA_INSTANCE}"
fi

# gitify instance
cd ${BUILD_DIR}/gitify
./koha-gitify kohadev "/kohadevbox/koha"
cd ${BUILD_DIR}

koha-enable kohadev
a2ensite kohadev.conf

# Update /etc/hosts so the www tests can run
echo "127.0.0.1    ${KOHA_OPAC_FQDN} ${KOHA_INTRANET_FQDN}" >> /etc/hosts

envsubst < ${BUILD_DIR}/templates/instance_bashrc > /var/lib/koha/kohadev/.bashrc

koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/populate_db.pl \
                                                                     --opac-base-url ${KOHA_OPAC_URL} \
                                                                     --intranet-base-url ${KOHA_INTRANET_URL}"
koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/create_superlibrarian.pl"
koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/insert_data.pl"
perl ${BUILD_DIR}/misc4dev/cp_debian_files.pl --koha_dir=${BUILD_DIR}/koha --gitify_dir=${BUILD_DIR}/gitify

# Stop apache2
service apache2 stop
# Configure and start koha-plack
koha-plack --enable kohadev
koha-plack --start kohadev
# Start apache
service apache2 start
# Start Zebra and the Indexer
koha-start-zebra kohadev
koha-indexer --start kohadev

if [ ${KOHA_DOCKER_DEBUG} ]; then
    bash
else
    cd ${BUILD_DIR}/koha
    rm -rf /cover_db/*

    if [ ${COVERAGE} ]; then
        koha-shell kohadev -p -c "rm -rf cover_db;
                                  JUNIT_OUTPUT_FILE=junit_main.xml \
                                  PERL5OPT=-MDevel::Cover=-db,/cover_db \
                                  KOHA_NO_TABLE_LOCKS=1 \
                                  KOHA_INTRANET_URL=http://koha:8081 \
                                  KOHA_OPAC_URL=http://koha:8080 \
                                  KOHA_USER=${KOHA_USER} \
                                  KOHA_PASS=${KOHA_PASS} \
                                  SELENIUM_ADDR=localhost \
                                  SELENIUM_PORT=4444 \
                                  TEST_QA=1 \
                                  prove --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ \
                                  && touch testing.success; \
                                  mkdir cover_db; cp -r /cover_db/* cover_db;
                                  cover -report clover"
    else
        koha-shell kohadev -p -c "JUNIT_OUTPUT_FILE=junit_main.xml \
                                  KOHA_NO_TABLE_LOCKS=1 \
                                  KOHA_INTRANET_URL=http://koha:8081 \
                                  KOHA_OPAC_URL=http://koha:8080 \
                                  KOHA_USER=${KOHA_USER} \
                                  KOHA_PASS=${KOHA_PASS} \
                                  SELENIUM_ADDR=selenium \
                                  SELENIUM_PORT=4444 \
                                  TEST_QA=1 \
                                  prove --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ \
                                  && touch testing.success"
    fi
fi
