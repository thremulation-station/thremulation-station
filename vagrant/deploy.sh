#! /bin/bash
#set -eux

banner()
{
    echo "###########################################"
    echo "###  SHALL  WE  PLAY  A  GAME?   WOPR   ###"
    echo "###########################################"
    echo ""
}

# Install the Windows 10 host
while true; do
    clear
    banner
    read -p "Do you want deploy the Windows10 node (victim) [Y/N] ? " yn
    case $yn in
        [Yy]* ) WINDOWS="windows10"; break;;
        [Nn]* ) WINDOWS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install the Elastic Stack
while true; do
    clear
    banner
    read -p "Do you want deploy the Elastic Stack [Y/N] ? " yn
    case $yn in
        [Yy]* ) ELASTIC="elastic"; break;;
        [Nn]* ) ELASTIC=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install Atomic Red
while true; do
    clear
    banner
    read -p "Do you deploy the Atomic Red node (attacker) [Y/N] ? " yn
    case $yn in
        [Yy]* ) CENTOS="centos"; break;;
        [Nn]* ) CENTOS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

#
while true; do
    clear
    banner
    read -p "Do you want to just (D)ownload or Download & (I)nstall or (C)ancel ? " yn
    case $yn in
        [Ii]* ) vagrant up $ELASTIC $CENTOS $WINDOWS; break;;
        [Dd]* ) vagrant box update $ELASTIC $CENTOS $WINDOWS; break;;
        [Cc]* ) break;;
        * ) echo "Please answer (D)ownload, (I)nstall, or (C)ancel.";;
    esac
done

sleep 2
