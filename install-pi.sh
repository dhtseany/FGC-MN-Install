#!/bin/bash

TMP_DIR=/tmp/fgc
F_USER="FantasyGold"
FGC_VERSION="1.2.4"


clear
echo "
    ___T_
   | o o |
   |__-__|
   /| []|\\
 ()/|___|\()
    |_|_|
    /_|_\  ----- MASTERNODE CONFIGURATOR v1 ------+
 |                                                |
 |           Fantasy Gold Coin $FGC_VERSION for          |::
 |               Raspberry Pi 3 B+                |::
 |                                                |::
 |    This process will install the latest        |::
 |    Fantasy Gold Coin Core and the QT5          |::
 |    wallet, which is optional.                  |::
 |                                                |::
 |    Do you want to continue installing?         |::
 |                                                |::
 |    NOTE: YOU NEED 2GB+ OF SWAP OR BUILD        |::
 |    WILL HANG AND CRASH DUE TO LACK OF MEMORY!  |::
 |                                                |::
 |    [y] Yes                                     |::
 |    [N] No                                      |::
 |                                                |::
 +------------------------------------------------+::
   ::::::::::::::::::::::::::::::::::::::::::::::::::
"

read -e -p "Begin? [y/N] : " BEGIN_Q_R

if [[ ("$BEGIN_Q_R" == "y" || "$BEGIN_Q_R" == "Y") ]];
    then
        ## Create a better swap file warning:
        
        clear
        echo "============================================="
        echo "Installing keys for jessie-backports"
        echo "============================================="
        sudo apt-get install devscripts bc
        echo "deb-src http://httpredir.debian.org/debian jessie-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/jessie-backports.list
        gpg --keyserver pgpkeys.mit.edu --recv-key 8B48AD6246925553
        gpg -a --export 8B48AD6246925553 | sudo apt-key add -
        sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt autoremove -y &&
        
        ## openssl-1.0
        echo "     "
        echo "============================================="
        echo "Installing openssl-1.0.21-1-armhf from src..."
        echo "============================================="
        mkdir -p $TMP_DIR/openssl-1.0-arm
        cd $TMP_DIR/openssl-1.0-arm
        apt-get source openssl/jessie-backports
        cd openssl-1.0.2l/
        export DEB_BUILD_OPTIONS=nocheck; debuild -us -uc -aarmhf
        sudo dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
        sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr -y
        
        ## db4.8
        echo "     "
        echo "============================================="
        echo "Installing db4.8 from src..."
        echo "============================================="
        mkdir -p $TMP_DIR/db4.8
        cd $TMP_DIR/db4.8
        wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
        tar xvzf db-4.8.30.NC.tar.gz
        cd db-4.8.30.NC/build_unix
        ../dist/configure --enable-cxx --prefix=/usr
        make -j8
        sudo make install

        ## FCG-Core
        echo "     "
        echo "============================================="
        echo "Installing FantasyGold-Core from src..."
        echo "============================================="
        mkdir -p $TMP_DIR/fcg-core
        cd $TMP_DIR/fgc-core
        git clone https://github.com/FantasyGold/FantasyGold-Core.git
        cd FGC-MN-Core/
        ./autogen.sh
        ./configure
        make
        sudo make install

        clear
        echo "The installation completed successfully."
        exit 0
    else
        exit 1
fi
