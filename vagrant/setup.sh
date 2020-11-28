#! /bin/bash
echo "###############################"
echo "# Shall we play a game? -WOPR #"
echo "###############################"
while true; do
    read -p "Do you want install the Windows 10 [Y/N]?" yn
    case $yn in
        [Yy]* ) WINDOWS="windows10"; break;;
        [Nn]* ) WINDOWS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you install Centos [Y/N]" yn
    case $yn in
        [Yy]* ) CENTOS="centos"; break;;
        [Nn]* ) CENTOS=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Download (D) or Download and Execute (E) or Cancel (C)? [D\E\C]" yn
    case $yn in
        [Ee]* ) vagrant up elastic $CENTOS $WINDOWS; break;;
        [Dd]* ) vagrant box update elastic $CENTOS $WINDOWS; break;;
        [Cc]* ) break;;
        * ) echo "Please answer yes or no or cancel.";;
    esac
done
sleep 15
