#!/bin/bash -x

set -e
set -x


figlet end

/bin/bash -c "trap : TERM INT; sleep infinity & wait"
