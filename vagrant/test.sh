#! /bin/bash
# Dont believe the git commit @koelslaw wrote ALL of this, DON'T believe his lies XD . -@koelslaw
​
##################
# define variables
##################
​
CENTOS=""
WINDOWS=""
​
​
##################
# define functions
##################
​
banner_main() {
    echo "###########################################"
    echo "##        THREMULATION STATION           ##"
    echo "##                                       ##"
    echo "###########################################"
    echo ""
    echo "1. Deploy New Thremulation Range"
    echo "2. Show Status of Current Range"
    echo "3. Management of Current Range"
    echo "(E)xit Program"
}
​
banner_deploy() {
    echo "###########################################"
    echo "###  DEPLOY                             ###"
    echo "###########################################"
    echo ""
    echo "1. Quick Deployment -  Deploy everything"
    echo "2. Custom Deployment - Deploy with choice."
    echo "(B)ack to Main Menu"
}
​
banner_deployquick() {
    echo "###########################################"
    echo "###  DEPLOY QUICK                       ###"
    echo "###########################################"
    echo ""
    echo "(B)ack to Deploy Menu"
}
​
banner_deploycustom() {
    echo "###########################################"
    echo "###  DEPLOY CUSTOM                      ###"
    echo "###########################################"
    echo ""
    echo "(B)ack to Deploy Menu"
}
​
banner_check() {
    echo "###########################################"
    echo "###  RANGE STATUS                       ###"
    echo "###########################################"
    echo ""
}
​
banner_manage() {
    echo "###########################################"
    echo "###  MANAGE                             ###"
    echo "###########################################"
    echo ""
    echo "1. Update - update to latest version"
    echo "2. Reboot - restart local boxes (troubleshooting"
    echo "3. Clear data - delete data in all index "
    echo "4. Soft Reset - revert to original snapshot"
    echo "5. Hard Reset - remove and redeploy boxes, return to the build menu to redeploy"
    echo "6. Nuke and Pave - Burn it down and start over, return to the build menu to redeploy"
    echo "(B)ack to Main Menu"
}
​
### Main Menu
main() {
    while true; do
        clear
        banner_main
        echo ""
        read -p "Enter an action from the above options: " yn
        case $yn in
            [1]* ) deploy; break;;
            [2]* ) check; break;;
            [3]* ) manage; break;;
            [E/n]* ) echo "Exiting..."; sleep 1; clear; break;;
            * ) echo "Selection invalid, try again.";;
        esac
    done
}
​
# Main deployment screen, ask for quick or custom
deploy() {
    requirements
    while true; do
        clear
        banner_deploy
        echo ""
        read -p "Select what kind of deployment would you like: " yn
        case $yn in
            [1]* ) deploy_quick; break;;
            [2]* ) deploy_custom; break;;
            [Bb]* ) clear; main;break;;
            * ) echo "Selection invalid, try again.";;
        esac
    done
}
​
​
# Quick deploy is all the things
deploy_quick() {
    while true; do
        clear
        banner_deployquick   
        echo ""
        echo "------------------------------------------------------------------------"
        echo "You have chosen to Quick Deploy all nodes, which includes the following:"
        echo ""
        echo "    * elastomic -- control node used to EMULATE and DETECT activity"
        echo ""
        echo "    * windows10 -- primary windows client target"
        echo ""
        echo "    * centos7   -- target linux server"
        echo ""
        read -p "Would you like to proceed with this configuration? [Y/N]: " yn 
        case $yn in
            [Yy]* )
                clear
                banner_deployquick
                echo ""
                echo "Deploying all nodes with vagrant up!";
                vagrant up;
                sleep 5;
                echo "Capturing snapshot of clean environment...";
                snapshot;
                break;; 
            [Nn]* ) deploy; break;;
            [Bb]* ) clear; deploy;break;;
            * ) echo "Selection invalid, try again.";;
        esac
    done
}
​
​
# Custom deploy consists of elastomic box PLUS:
deploy_custom() {
    while true; do
        clear
        banner_deploycustom
        echo ""
        echo 'The "elastomic" box is the first and pivotal node.'
        echo "What TARGET nodes would you like to deploy?"
        echo ""
        read -p "Do you want deploy the Windows10 target node? [Y/N]: " yn
        case $yn in
            [Yy]* ) WINDOWS="windows10"; break;;
            [Nn]* ) WINDOWS=""; break;;
        esac
    done
    while true; do
        clear
        banner_deploycustom
        read -p "Do you deploy the Centos7 target node? [Y/N]: " yn
        case $yn in
            [Yy]* ) CENTOS="centos"; break;;
            [Nn]* ) CENTOS=""; break;;
            [Bb]* ) clear; deploy;break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    while true; do
        clear
        banner_deploycustom
        echo ""
        echo "You have chosen the following nodes configuration:"
        echo ""
        echo "elastomic - the control node (attacker & defender)"
        echo "  ${WINDOWS}"
        echo "  ${CENTOS}"
        echo ""
        read -p "Are you ready to proceed with the deployment? [Y/N]: " yn 
        case $yn in
            [Yy]* ) vagrant up elastomic ${CENTOS} ${WINDOWS}; sleep 20; snapshot; break;; 
            [Nn]* ) deploy; break;;
            [Bb]* ) clear; main; break;; # back to main menubreak;;
            * ) echo "Selection invalid, try again.";;
        esac
    done
}
