#!/bin/bash
if [ -d ~/.electrumx-grs-installer ]; then
    echo "~/.electrumx-grs-installer already exists."
    echo "Either delete the directory or run ~/.electrumx-grs-installer/install.sh directly."
    exit 1
fi
if which git > /dev/null 2>&1; then
    git clone https://github.com/Groestlcoin/electrumx-grs-installer ~/.electrumx-grs-installer
    cd ~/.electrumx-grs-installer/
else
    which wget > /dev/null 2>&1 && which unzip > /dev/null 2>&1 || { echo "Please install git or wget and unzip" && exit 1 ; }
    wget https://github.com/Groestlcoin/electrumx-grs-installer/archive/master.zip -O /tmp/electrumx-grs-master.zip
    unzip /tmp/electrumx-grs-master.zip -d ~/.electrumx-grs-installer
    rm /tmp/electrumx-grs-master.zip
    cd ~/.electrumx-grs-installer/electrumx-grs-installer-master/
fi
if [[ $EUID -ne 0 ]]; then
    which sudo > /dev/null 2>&1 || { echo "You need to run this script as root" && exit 1 ; }
    sudo -H ./install.sh "$@"
else
    ./install.sh "$@"
fi
