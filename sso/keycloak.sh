#!/bin/bash

set -e

function configure_keycloak(){

    # NOTE: Loop forever
    while true
    do
        # Attempt to login
        if /opt/jboss/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user ${KEYCLOAK_USER:-keycloak} --password ${KEYCLOAK_PASSWORD:-keycloak}; then
            # add a realm and the koha user
            /opt/jboss/keycloak/bin/kcadm.sh create realms -s realm=${KEYCLOAK_REALM:-koha} -s enabled=true
            /opt/jboss/keycloak/bin/kcadm.sh create users -r ${KEYCLOAK_REALM:-koha} -s username=koha -s enabled=true -s email=koha@koha-community.org -s firstName=koha -s lastName=koha
            /opt/jboss/keycloak/bin/kcadm.sh set-password -r ${KEYCLOAK_REALM:-koha} --username koha --new-password sso

            break;
        fi
        sleep 5
    done

    touch /tmp/keycloak_configured_for_koha
}

echo "Launching background process to configure Keycloak for Koha"
configure_keycloak & disown
echo "Launched background process to configure Keycloak for Koha"
