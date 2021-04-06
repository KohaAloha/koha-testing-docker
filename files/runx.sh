#!/bin/bash -x

set -e
set -x

pwd

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
    else if [ "LIGHT_TEST_SUITE" = "1" ]; then
        koha-shell ${KOHA_INSTANCE} -p -c "find t xt -name '*.t' \
                                    -not -path \"t/db_dependent/www/*\" \
                                    -not -path \"t/db_dependent/selenium/*\" \
                                    -not -path \"t/db_dependent/Koha/SearchEngine/Elasticsearch/*\" \
                                    -not -path \"t/db_dependent/Koha/SearchEngine/*\" \
                                | JUNIT_OUTPUT_FILE=junit_main.xml \
                                  KOHA_TESTING=1 \
                                  KOHA_NO_TABLE_LOCKS=1 \
                                  KOHA_INTRANET_URL=http://koha:8081 \
                                  KOHA_OPAC_URL=http://koha:8080 \
                                  KOHA_USER=${KOHA_USER} \
                                  KOHA_PASS=${KOHA_PASS} \
                                  TEST_QA=1 \
                                  xargs prove -j ${KOHA_PROVE_CPUS} \
                                  --rules='par=t/db_dependent/00-strict.t' \
                                  --rules='seq=t/db_dependent/**.t' --rules='par=**' \
                                  --timer --harness=TAP::Harness::JUnit -s \
                                  && touch testing.success"
    else
        koha-shell ${KOHA_INSTANCE} -p -c "pwd; \
                                 JUNIT_OUTPUT_FILE=junit_main.xml \
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
                                  --timer --harness=TAP::Harness::JUnit -r t/ xt/ \
                                  && touch testing.success"
    fi
else
  figlet end
  /bin/bash -c "trap : TERM INT; sleep infinity & wait"
fi
