#!/bin/sh

cd /tmp/electrumx-grs-installer/

if [ -e "./test/preinstall/$IMAGE" ]; then
    "./test/preinstall/$IMAGE"
fi
./install.sh
electrumx_server
