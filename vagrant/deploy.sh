#! /bin/bash 
#set -eux

banner()
{
    echo "###########################################"
    echo "###  SHALL  WE  PLAY  A  GAME?   WOPR   ###"
    echo "###########################################"
    echo ""
}


while true; do
    clear
    banner
    read -p "Do you want deploy the Windows10 node [Y/N] ? " yn
    case $yn in
        [Yy]* ) WINDOWS="windows10"; break;;
        [Nn]* ) WINDOWS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    clear
    banner
    read -p "Do you deploy the Centos7 node [Y/N] ? " yn
    case $yn in
        [Yy]* ) CENTOS="centos"; break;;
        [Nn]* ) CENTOS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    clear
    banner
    read -p "Do you want to (D)ownload / Download & (E)xecute / (C)ancel ? " yn
    case $yn in
        [Ee]* ) echo 'vagrant up elastic $CENTOS $WINDOWS'; break;;
        [Dd]* ) echo 'vagrant box update elastic $CENTOS $WINDOWS'; break;;
        [Cc]* ) break;;
        * ) echo "Please answer yes or no or cancel.";;
    esac
done

sleep 2
