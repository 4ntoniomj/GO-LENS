#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# ctrl + c
trap ctrl_c INT
function ctrl_c(){
    echo -e "${redColour}Exiting...${endColour}"
    exit 1
}

# Finish
function on_exit(){
    echo -e "${blueColour}[+]We are finished${endColour}"
}
trap on_exit EXIT

# Root?
if [ $UID -ne 0 ]; then
    echo -e "${redColour}[!] No root${endColour}"
    ctrl_c
fi

# Helpanel
function helpanel(){
    clear
    echo -e "${yellowColour}If your system is:\nUbuntu (./script 1)\nDebian (2)\nRHEL (3)\nFedora (4)\nRaspberry Pi OS 32-bit (5)\nCentOS (6)\nSELS s390x (7)${endColour}"
}
# Installing docker
if [ "$#" -ne 1 ]; then
    helpanel
fi

    # Unistall apt
function unistall_debian(){
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    apt-get remove $pkg -y
    done
    apt-get update
    apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
}

function install_debian(){
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

    # Unistall dnf
function remove_dnf(){
    dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc -y
    dnf -y install dnf-plugins-core
}

function install_dnf(){
    dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl enable --now docker
}

case "$1" in
    1) # Ubuntu
        unistall_debian
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        install_debian
        ;;
    2) # Debian
        unistall_debian
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        install_debian
        ;;
    3) # RHEL
        remove_dnf
        dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
        install_dnf
        ;;
    4) # Fedora
        remove_dnf
        dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        install_dnf
        ;;
    5) # Raspberry Pi OS
        unistall_debian
        curl -fsSL https://download.docker.com/linux/raspbian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/raspbian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        install_debian
        ;;
    6) # CentOS
        remove_dnf
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        install_dnf
        ;;
    7) # SLES
        opensuse_repo="https://download.opensuse.org/repositories/security:/SELinux/openSUSE_Factory/security:SELinux.repo"
        zypper addrepo $opensuse_repo
        zypper remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine runc -y
        zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
        zypper install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        systemctl enable --now docker
        ;;
    *)
        helpanel
        ctrl_c
        ;;
esac