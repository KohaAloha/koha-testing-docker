#!/bin/bash

#set -e
set -x

export BUILD_DIR=/kohadevbox
export TEMP=/tmp

# Set a fixed hostname
echo "kohadevbox" > /etc/hostname
echo "127.0.0.1 kohadevbox" >> /etc/hosts
hostname kohadevbox

figlet 2222

wget https://gitlab.com/mjames/koha-testing-docker/-/raw/1b8c3159d4f96e718895818ef470294eb646c0b3/files/run-figlet.sh

bash -x ./run-figlet.sh

