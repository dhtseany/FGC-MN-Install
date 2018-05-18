## Raspberry Pi 3 B+ Installer for FantasyGold-Core v1.2.4


## Notes:
All of this is a work in progress where I’m tracking attempts along the way. This is not yet functional. Steps for manual install, usage of install-pi.sh and bugfixes will be outlined here. This code probably doesn't work yet. You've been warned.

You'll probably notice the absence of "sudo" with the Raspberry Pi's installation command (or using install-pi.sh yourself), unlike the traditional easy installation for x86_x64 (install.sh). This is intentional, as we're building multiple packages from 3rd party upstream code providers. It is considered bad practice to build from source using a privileged user account and therefore this script has been designed to run as your normal user account. It will prompt for your credentials and invoke sudo on it's own when needed for installation tasks requiring privilege escalation.

## To-do:
1. Finish qt5 support
2. Finish creating mn deployment scripts if user chooses to do so

## Prerequisites:
- Raspberry Pi Model 3 B+ (Older models will probably work but this is the latest iteration of the hardware and therefore the most capable. While this install process should function the same across all rPi’s, your performance results may vary. Official support and documentation will assume you have an rPi 3 B+).
SDCard containing the NOOBS install. At the end of the day the more RAM the better. (While a non-gui install is possible you’ll lose qt support and in turn no wallet will be locally available on the Pi. Official installation documentation and installer download is available here:
https://www.raspberrypi.org/downloads/noobs/)

- A firewall capable of properly performing NAT translations. (Otherwise known as a “port forwards”)

- At least 1GB of Swap enabled during build otherwise script will fail during FantasyGold-core build

## FantasyGold-Core (Easy) Installation (Recommended for most)
Enter the following command to download the install-pi.sh script and run it:
```
$ bash <( curl URL_TO_FOLLOW )
```

## Manual Installation (Advanced Users Only!)

## Prep Work:
(Optional) Enable SSH:
```
$ sudo systemctl enable ssh && sudo systemctl start ssh
```

## Enable networking components for correct DNS resolution
```
$ sudo systemctl enable systemd-networkd
```
```
$ sudo systemctl enable systemd-resolved
```
```
$ sudo reboot
```

## Create a 1GB swap file
Note: I switch over to using root while performing these commands using sudo su
1. Use DD to create the swapfile filled with zeros:
```
# dd bs=8M count=128 if=/dev/zero of=/swapfile status=progress
```
2. chmod /swapfile with 600 for security:
```
# chmod 600 /swapfile
```
3. Format /swapfile as swap:
```
# mkswap /swapfile
```
4. nano /etc/fstab and copy/paste the second box, ctrl+o to save and ctrl+x to exit
```
# nano /etc/fstab
```
```
# swapfile
/swapfile none swap defaults 0 0
```
5. Reboot. While you could use swapon /swapfile to avoid the reboot, I like to reboot here to ensure no issues with your /etc/fstab edits later on at a less convenient time.
```
# reboot
```

## Install dependencies:
Repo-ready:
```
$ sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr devscripts bc -y
```
Note: I normally reboot here as well just for good measure, ton of packages will pull down however the installer script won't do this part for you. If you choose to run this command first you can then reboot and easily begin the rest of the scripted installation without fear of failures. If you encounter build failures and you did not reboot, reboot your system and try again.

## Add debian-backports then upgrade system (here for openssl1.0)
First add the add jessie-backports to the sources list: 
```
$ echo "deb-src http://httpredir.debian.org/debian jessie-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/jessie-backports.list
```
Import and add the keys:
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7638D0442B90D010
```
```
gpg -a --export 8B48AD6246925553 | sudo apt-key add -
gpg -a --export 7638D0442B90D010 | sudo apt-key add -
```

## Install openssl-1.0
First pull in the src code:
```
$ apt-get source openssl/jessie-backports
```
Next cd in the src directory:
```
$ cd openssl-1.0.2l/
```
Build it:
```
export DEB_BUILD_OPTIONS=nocheck; debuild -us -uc -aarmhf
```
Install it:
```
$ sudo dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
```
```
$ sudo dpkg -i libssl-dev_1.0.2l-1~bpo8+1_armhf.deb
```
Update ldconfig
```
$ sudo ldconfig
```

## Install db4.8 from src:
Download it from Oracle:
```$ 
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
```
Untar it:
```
$ tar xvzf db-4.8.30.NC.tar.gz
```
cd into the build_unix directory:
```
$ cd db-4.8.30.NC/build_unix
```
```
Configure:
$ ../dist/configure --enable-cxx --prefix=/usr
```
Make: (Not sure if j8 is cool normally but it seemed to reduce the build time per the advice of some forum threads)
```
$ make -j8
```
Install:
```
$ sudo make install
```

## Install openssl from src for 1.0 support:
First download src from jessie-backports:
```
apt-get source openssl/jessie-backports
```
cd into the newly created directory:
```
cd openssl-1.0.2l/
```
Build and create .deb files:
```
export DEB_BUILD_OPTIONS=nocheck; debuild -us -uc -aarmhf
```
Install deb:
```
sudo dpkg -i libssl1.0.0_1.0.2l-1~bpo8+1_armhf.deb
```
Install deb
```
sudo dpkg -i libssl-dev_1.0.2l-1~bpo8+1_armhf.deb
```

## FantasyGold-Core Installation from src:
Download the src from mainline:
```
$ git clone https://github.com/FantasyGold/FantasyGold-Core.git
```
cd into the directory and build:
```
$ cd FGC-MN-Core/
```
Run the autogen:
```
$ ./autogen.sh
```
Configure:
```
$ ./configure
```
Make:
```
$ make
```
Install:
```
$ sudo make install
```