#!/bin/bash

TMP_DIR=/tmp/fgc
F_USER="FantasyGold"
FGC_VERSION="1.2.4"

if [[ ("$1" == "core") ]];
    then
        echo "User chose to compile the local fg-core bins...."
        #source ./uninstall.sh
        mkdir -p $TMP_DIR/fg-core
        cd $TMP_DIR/fg-core
        git clone https://github.com/FantasyGold/FantasyGold-Core.git
        cd FantasyGold-Core/
        ./autogen.sh
        ./configure
        make
        echo "fg-c build job finished at:" >> $TMP_DIR/run.log
        read -e -p "Does it appear FantasyGold-core finished building without errors? [y/N] : " FGC1_Q_R

        if [[ ("$FGC1_Q_R" == "y" || "$FGC1_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Build of FantasyGold-core failed."
                exit 1
        fi
        
        sudo make install

        read -e -p "Does it appear FantasyGold-core finished installing without errors? [y/N] : " FGC2_Q_R

        if [[ ("$FGC2_Q_R" == "y" || "$FGC2_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Install of FantasyGold-core failed."
                exit 1
        fi
        exit 0
fi
if [[ ("$1" == "db48-testing") ]];
    then
        ## db4.8
        clear
        echo "     "
        echo "============================================="
        echo "Installing db4.8 from src..."
        echo "============================================="
        echo "db4.8 build job started at:" >> $TMP_DIR/run.log
        mkdir -p $TMP_DIR/db4.8
        cd $TMP_DIR/db4.8
        wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
        tar xvzf db-4.8.30.NC.tar.gz
        cd db-4.8.30.NC/build_unix
        ../dist/configure --enable-cxx --prefix=/usr
        make -j8
        sudo make install
        echo "db4.8 build job finished at:" >> $TMP_DIR/run.log

        # echo "Quick pause for review and reflection..."
        # sleep 5
        read -e -p "Does it appear db4.8 finished building without errors? [y/N] : " DB48_Q_R

        if [[ ("$DB48_Q_R" == "y" || "$DB48_Q_R" == "Y") ]];
            then
                echo" Build of db4.8 complete."
                exit 0
            else
                echo "Build of db4.8 failed."
                exit 1
        fi
fi

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
 |    NOTE: YOU NEED 1GB+ OF SWAP OR BUILD        |::
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
        mkdir -p $TMP_DIR
        touch $TMP_DIR/run.log
        echo "Job started at:" >> $TMP_DIR/run.log
        date +%H%M%S >> $TMP_DIR/run.log
        clear
        echo "============================================="
        echo "Installing build and package dependancies"
        echo "============================================="
        sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr devscripts bc -y

        clear
        echo " "
        echo "============================================="
        echo "Installing keys for jessie-backports"
        echo "============================================="
        echo "deb-src http://httpredir.debian.org/debian jessie-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/jessie-backports.list
        echo "Done."
        echo " "
        echo "Importing keys..."
        # gpg --keyserver pgpkeys.mit.edu --recv-key 8B48AD6246925553
        # gpg -a --export 8B48AD6246925553 | sudo apt-key add -
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7638D0442B90D010
        # gpg -a --export 8B48AD6246925553 | sudo apt-key add -
        # gpg -a --export 7638D0442B90D010 | sudo apt-key add -
        echo "Refreshing repos..."
        sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt autoremove -y &&
        echo "jess-backports added at:" >> $TMP_DIR/run.log        
        
        ## openssl-1.0
        clear
        echo "     "
        echo "============================================="
        echo "Installing openssl-1.0.21-1-armhf from src"
        echo "============================================="
        echo "openssl-1.0 build job started at:" >> $TMP_DIR/run.log
        mkdir -p $TMP_DIR/openssl-1.0-arm
        cd $TMP_DIR/openssl-1.0-arm
        apt-get source openssl/jessie-backports
        cd openssl-1.0.2l/
        export DEB_BUILD_OPTIONS=nocheck; debuild -us -uc -aarmhf
        cd ..
        sudo dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
        sudo dpkg -i libssl-dev_1.0.2l-1~bpo8+1_armhf.deb
        sudo ldconfig ## I believe this fixes the issue where the build doesn't find openssl-1.0
        echo "openssl-1.0 build job finished at:" >> $TMP_DIR/run.log
        
        # echo "Quick pause for review and reflection..."
        # sleep 10
        
        read -e -p "Does it appear openssl finished building without errors? [y/N] : " OPENSSLINSTALL_Q_R

        if [[ ("$OPENSSLINSTALL_Q_R" == "y" || "$OPENSSLINSTALL_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Build of openssl-1.0 failed."
                exit 1
        fi


        ## db4.8
        clear
        echo "     "
        echo "============================================="
        echo "Installing db4.8 from src..."
        echo "============================================="
        echo "db4.8 build job started at:" >> $TMP_DIR/run.log
        mkdir -p $TMP_DIR/db4.8
        cd $TMP_DIR/db4.8
        wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
        tar xvzf db-4.8.30.NC.tar.gz
        cd db-4.8.30.NC/build_unix
        ../dist/configure --enable-cxx --prefix=/usr
        make -j8
        sudo make install
        echo "db4.8 build job finished at:" >> $TMP_DIR/run.log

        # echo "Quick pause for review and reflection..."
        # sleep 5
        read -e -p "Does it appear db4.8 finished building without errors? [y/N] : " DB48_Q_R

        if [[ ("$DB48_Q_R" == "y" || "$DB48_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Build of db4.8 failed."
                exit 1
        fi

        ## FCG-Core
        clear
        echo "     "
        echo "============================================="
        echo "Installing FantasyGold-Core from src..."
        echo "============================================="
        echo "fg-c build job started at:" >> $TMP_DIR/run.log

        mkdir -p $TMP_DIR/fg-core
        cd $TMP_DIR/fg-core
        git clone https://github.com/FantasyGold/FantasyGold-Core.git
        cd FantasyGold-Core/
        ./autogen.sh
        ./configure
        make
        echo "fg-c build job finished at:" >> $TMP_DIR/run.log
        read -e -p "Does it appear FantasyGold-core finished building without errors? [y/N] : " FGC1_Q_R

        if [[ ("$FGC1_Q_R" == "y" || "$FGC1_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Build of FantasyGold-core failed."
                exit 1
        fi
        
        sudo make install

        read -e -p "Does it appear FantasyGold-core finished installing without errors? [y/N] : " FGC2_Q_R

        if [[ ("$FGC1_Q_R" == "y" || "$FGC1_Q_R" == "Y") ]];
            then
                EXIT_STATUS=0
            else
                echo "Install of FantasyGold-core failed."
                exit 1
        fi


        clear
        echo "Job finished at:" >> $TMP_DIR/run.log
        date +%H%M%S >> $TMP_DIR/run.log
        echo "=============================" >> $TMP_DIR/run.log

        echo "The installation completed successfully."
        exit 0
    else
        echo "User aborted process."
        exit 1
fi
