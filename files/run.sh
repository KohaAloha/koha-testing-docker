#!/bin/bash

export BUILD_DIR=/kohadevbox
export TEMP=/tmp

# Wait for the DB server startup
while ! nc -z db 3306; do sleep 1; done

# TODO: Have bugs pushed so all this is a koha-create parameter
echo "${KOHA_INSTANCE}:koha_${KOHA_INSTANCE}:${KOHA_DB_PASSWORD}:koha_${KOHA_INSTANCE}" > /etc/koha/passwd
# TODO: Get rid of this hack with the relevant bug
echo "[client]" > /etc/mysql/koha-common.cnf
echo "host = db" >> /etc/mysql/koha-common.cnf

# Get rid of Apache warnings
echo "ServerName kohadevdock" >> /etc/apache2/apache2.conf

cp ${BUILD_DIR}/koha-conf-site.xml.in /etc/koha/koha-conf-site.xml.in

koha-create --request-db ${KOHA_INSTANCE} --use-memcached --memcached-servers memcached:11211
# Fix UID
if [ ${LOCAL_USER_ID} ]; then
    usermod -u ${LOCAL_USER_ID} "${KOHA_INSTANCE}-koha"
    # Fix permissions due to UID change
    chown -R "${KOHA_INSTANCE}-koha" "/var/lib/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/lock/koha/${KOHA_INSTANCE}"
    chown -R "${KOHA_INSTANCE}-koha" "/var/run/koha/${KOHA_INSTANCE}"
fi

# gitify instance
cd ${BUILD_DIR}/gitify
./koha-gitify kohadev "/kohadevbox/koha"
cd ${BUILD_DIR}

koha-enable kohadev
a2ensite kohadev.conf

# Update /etc/hosts so the www tests can run
echo "127.0.0.1    kohadev.myDNSname.org kohadev-intra.myDNSname.org" >> /etc/hosts

cp ${BUILD_DIR}/instance_bashrc /var/lib/koha/kohadev/.bashrc

koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/populate_db.pl \
                                                                     --opac-base-url ${KOHA_OPAC_URL} \
                                                                     --intranet-base-url ${KOHA_INTRANET_URL}"
koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/create_superlibrarian.pl"
koha-shell ${KOHA_INSTANCE} -p -c "PERL5LIB=${BUILD_DIR}/koha perl ${BUILD_DIR}/misc4dev/insert_data.pl"

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
# Start Selenium
Xvfb :1 -screen 0 1024x768x24 > /dev/null 2>&1 &
DISPLAY=:1 java -jar selenium.jar 2> /dev/null &

if [ ${KOHA_DOCKER_DEBUG} ]; then
    bash
else
    cd ${BUILD_DIR}/koha
    rm -rf /cover_db/*
    koha-shell kohadev -p -c "rm -rf cover_db;
                              JUNIT_OUTPUT_FILE=junit_main.xml \
                              PERL5OPT=-MDevel::Cover=-db,/cover_db \
                              KOHA_NO_TABLE_LOCKS=1 \
                              KOHA_INTRANET_URL=${KOHA_INTRANET_URL} \
                              KOHA_OPAC_URL=${KOHA_OPAC_URL} \
                              KOHA_USER=${KOHA_USER} \
                              KOHA_PASS=${KOHA_PASS} \
                              SELENIUM_ADDR=localhost \
                              SELENIUM_PORT=4444 \
                              TEST_QA=1 \
                              prove --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ ; \
                              mkdir cover_db; cp -r /cover_db/* cover_db;
                              cover -report clover"
fi
