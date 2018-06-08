#!/bin/bash

TMP_DIR=/tmp/fgc
F_USER="fantasygold"
FGC_VERSION="1.2.4"

#====Individual Options for Testing====#
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
if [[ ("$1" == "deps") ]];
    then
        echo "User chose to install deps available in repos...."
        mkdir -p $TMP_DIR
        touch $TMP_DIR/run.log
        echo "Job started at:" >> $TMP_DIR/run.log
        date +%H%M%S >> $TMP_DIR/run.log
        clear
        echo "============================================="
        echo "Installing build and package dependancies"
        echo "============================================="
        sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr dnsutils qt-sdk libprotobuf-dev libzmq-dev devscripts bc libprotoc-dev libczmq4 libczmq-dev protobuf-compiler -y

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
        exit        
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

if [[ ("$1" == "adopt") ]];
    then
        clear
        echo "User chose to adpot a new remote node...."
        mkdir -p $TMP_DIR
        # sudo adduser -M -r $F_USER
        sudo adduser $F_USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null
        RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
        RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
        INTERNAL_IP=$(hostname -I)

        read -e -p "Masternode Private Key [none]: " KEY

        read -e -p "Choose tcp port for node [57810] : " NODEPORT_Q_R

        if [[ ( -z "$NODEPORT_Q_R" ) ]];
            then
                NODEPORT="57810"
            else
                NODEPORT=$NODEPORT_Q_R
        fi
cat > $TMP_DIR/fantasygoldd.service << EOL
[Unit]
Description=fantasygoldd
After=network.target
[Service]
Type=forking
User=$F_USER
WorkingDirectory=/home/FantasyGold
ExecStart=/usr/local/bin/fantasygoldd -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold
ExecStop=/usr/local/bin/fantasygold-cli -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL



        # cat > $TMP_DIR/fantasygoldd.service << EOL
        # [Unit]
        # Description=fantasygoldd
        # After=network.target
        # [Service]
        # Type=forking
        # User=$F_USER
        # WorkingDirectory=/home/FantasyGold
        # ExecStart=/usr/local/bin/fantasygoldd -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold
        # ExecStop=/usr/local/bin/fantasygold-cli -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold stop
        # Restart=on-abort
        # [Install]
        # WantedBy=multi-user.target
        # EOL


        touch $TMP_DIR/fantasygold.conf
cat > $TMP_DIR/fantasygold.conf << EOL
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip=$PUBLIC_IP
bind=$INTERNAL_IP:$NODEPORT
masternodeaddr=$PUBLIC_IP
masternodeprivkey=$KEY
masternode=1
EOL

        sudo mkdir -p /home/$F_USER/.fantasygold
        sudo chown -R $F_USER:$F_USER /home/$F_USER
        sudo mv $TMP_DIR/fantasygold.conf /home/$F_USER/.fantasygold/fantasygold.conf
        sudo chown -R $F_USER:$F_USER /home/$F_USER/.fantasygold
        sudo chmod 600 /home/$F_USER/.fantasygold/fantasygold.conf
        
        sudo mv $TMP_DIR/fantasygoldd.service /etc/systemd/system/fantasygoldd.service
        sudo chown root:root /etc/systemd/system/fantasygoldd.service
        sudo systemctl daemon-reload
        sudo systemctl enable fantasygoldd && sudo systemctl start fantasygoldd
        sudo systemctl status fantasygoldd
        echo "User process is complete."
        echo "Use `sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' fantasygold` to check progress."
        exit 0
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
        sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr dnsutils qt-sdk libprotobuf-dev libzmq-dev devscripts bc libprotoc-dev libczmq4 libczmq-dev protobuf-compiler -y

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
        # exit 0
    else
        echo "User aborted process."
        exit 1
fi

echo "At this stage we're ready to begin configuring your new master node."
echo "If you only wanted to install and build for the qt5 wallet, this is where you'll quit [Simply select N]"
read -e -p "Would you like to continue creating the user account and configuring the masternode? [y/N] : " NEWUSER_Q_R

if [[ ("$NEWUSER_Q_R" == "y" || "$NEWUSER_Q_R" == "Y") ]];
    then
        clear
        echo "User chose continue creating the user account...."
        mkdir -p $TMP_DIR
        # sudo adduser -M -r $F_USER
        sudo adduser $F_USER --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password > /dev/null
        RPCUSER="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1"
        RPCPASSWORD="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1"
        PUBLIC_IP="dig +short myip.opendns.com @resolver1.opendns.com"
        INTERNAL_IP="hostname -I"

        read -e -p "Masternode Private Key [none]: " KEY

        read -e -p "Choose tcp port for node [57810] : " NODEPORT_Q_R

        if [[ ( -z "$NODEPORT_Q_R" ) ]];
            then
                NODEPORT="57810"
            else
                NODEPORT=$NODEPORT_Q_R
        fi
cat > $TMP_DIR/fantasygoldd.service << EOL
[Unit]
Description=fantasygoldd
After=network.target
[Service]
Type=forking
User=$F_USER
WorkingDirectory=/home/FantasyGold
ExecStart=/usr/local/bin/fantasygoldd -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold
ExecStop=/usr/local/bin/fantasygold-cli -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL



        # cat > $TMP_DIR/fantasygoldd.service << EOL
        # [Unit]
        # Description=fantasygoldd
        # After=network.target
        # [Service]
        # Type=forking
        # User=$F_USER
        # WorkingDirectory=/home/FantasyGold
        # ExecStart=/usr/local/bin/fantasygoldd -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold
        # ExecStop=/usr/local/bin/fantasygold-cli -conf=/home/$F_USER/.fantasygold/fantasygold.conf -datadir=/home/FantasyGold/.fantasygold stop
        # Restart=on-abort
        # [Install]
        # WantedBy=multi-user.target
        # EOL


        touch $TMP_DIR/fantasygold.conf
cat > $TMP_DIR/fantasygold.conf << EOL
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip=$PUBLIC_IP
bind=$INTERNAL_IP:$NODEPORT
masternodeaddr=$PUBLIC_IP
masternodeprivkey=$KEY
masternode=1
EOL

        sudo mkdir -p /home/$F_USER/.fantasygold
        sudo chown -R $F_USER:$F_USER /home/$F_USER
        sudo mv $TMP_DIR/fantasygold.conf /home/$F_USER/.fantasygold/fantasygold.conf
        sudo chown -R $F_USER:$F_USER /home/$F_USER/.fantasygold
        sudo chmod 600 /home/$F_USER/.fantasygold/fantasygold.conf

        sudo mv $TMP_DIR/fantasygoldd.service /etc/systemd/system/fantasygoldd.service
        sudo chown root:root /etc/systemd/system/fantasygoldd.service
        sudo systemctl daemon-reload
        sudo systemctl enable fantasygoldd && sudo systemctl start fantasygoldd
        sudo systemctl status fantasygoldd
        echo "User process is complete."
        sleep 1

        cat << EOL
Now, you need to start your masternode. Please go to your desktop wallet and
select your masternode and click the start buttom.
EOL

read -p "Press any key to continue after you've done that. " -n1 -s

#clear

echo "Your masternode is syncing. Please wait for this process to finish."
echo "CTRL+C to exit the masternode sync once you see the MN ENABLED in your local wallet." && echo ""

# until su -c "fantasygold-cli startmasternode local false 2>/dev/null | grep 'successfully started' > /dev/null" $USER; do
#   for (( i=0; i<${#CHARS}; i++ )); do
#     sleep 2
#     echo -en "${CHARS:$i:1}" "\r"
#   done
# done

sleep 1
su -c "/usr/local/bin/fantasygold-cli startmasternode local false" $USER
sleep 1
clear
su -c "/usr/local/bin/fantasygold-cli masternode status" $USER
sleep 5

echo "" && echo "Masternode setup completed." && echo ""

        
        echo "Use `sudo su -c '/usr/local/bin/fantasygold-cli startmasternode local false' fantasygold` to check progress."
    else
        echo "User has chosen to skip the new user process."
        exit 1
fi