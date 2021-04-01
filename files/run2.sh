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

# -------------------------------
# -------------------------------
# -------------------------------
figlet run2
export

figlet chown

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

if [ -n "$KOHA_ELASTICSEARCH" ]; then
    ES_FLAG="--elasticsearch"
fi

figlet do_all

perl ${BUILD_DIR}/misc4dev/do_all_you_can_do.pl \
            --instance          ${KOHA_INSTANCE} ${ES_FLAG} \
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

# Enable and start koha-plack and koha-z3950-responder
koha-plack           --enable ${KOHA_INSTANCE}
koha-z3950-responder --enable ${KOHA_INSTANCE}
service koha-common start

# Start apache and rabbitmq-server
service apache2 start
service rabbitmq-server start

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
                                  prove -j ${KOHA_PROVE_CPUS} -v \
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
                                  prove -j ${KOHA_PROVE_CPUS} -v \
                                  --rules='par=t/db_dependent/00-strict.t' \
                                  --rules='seq=t/db_dependent/**.t' --rules='par=**' \
                                  --timer --harness=TAP::Harness::JUnit -s -r t/ xt/ \
                                  && touch testing.success"
    fi
else
    # TODO: We could use supervise as the main loop
#    /bin/bash -c "trap : TERM INT; sleep infinity & wait"
fi
