## Raspberry Pi 3 B+ Installer for FantasyGold-Core v1.2.4


All of this is a work in progress where I’m tracking attempts along the way. This is not yet functional. Steps for manual install, usage of install-pi.sh and bugfixes will be outlined here. This code probably doesn't work yet. You've been warned.

## Prerequisites:
- Raspberry Pi Model 3 B+ (Older models will probably work but this is the latest iteration of the hardware and therefore the most capable. While this install process should function the same across all rPi’s, your performance results may vary. Official support and documentation will assume you have an rPi 3 B+).
SDCard containing the NOOBS install. (While a non-gui install is possible you’ll lose qt support and in turn no wallet will be locally available on the Pi. Official installation documentation and installer download is available here:
https://www.raspberrypi.org/downloads/noobs/)

- A firewall capable of properly perform NAT translations. (Otherwise known as a “port forward”)


## FantasyGold-Core (Easy) Installation (Recommended for most)
Enter the following command to download the install-pi.sh script and run it:
```
$ sudo bash <( curl URL_TO_FOLLOW )
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

## Install dependencies:
Repo-ready:
```
$ sudo apt-get install autoconf libtool libboost-all-dev libminiupnpc-dev miniupnpc qt5-default libevent-dev dirmngr devscripts bc -y
```
Note: I normally reboot here just for good measure, ton of packages will pull down however the installer script won't do this part for you. If you choose to run this command first you can then reboot and easily begin the rest of the scripted installation without fear of failures. If you encounter build failures and you did not reboot, reboot your system and try again.

## Add debian-backports then upgrade system (here for openssl1.0)
First add the add jessie-backports to the sources list: 
```
$ echo "deb-src http://httpredir.debian.org/debian jessie-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/jessie-backports.list
```
Import and add the keys:
```
$ gpg --keyserver pgpkeys.mit.edu --recv-key 8B48AD6246925553
```
```
$ gpg -a --export 8B48AD6246925553 | sudo apt-key add -
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
Start by cloning from src:
```
$ git clone git://git.openssl.org/openssl.git
```
cd into build directory:
```
$ cd openssl
```
Configure:
```
$ ./config --prefix=/usr
```
Make:
```
$ make
```
Make test (to verify a good build of openssl-1.0)
```
$ make test
```
Install:
```
$ sudo make install
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