#!/bin/bash

set -euo pipefail


function main () {

    installCommonPackages
    installDocker

}

function installCommonPackages() {

    # Install some common packages
    sudo apt install -y \
       net-tools \
       curl 

}

function installDocker () {

    # Install Docker
    curl -fSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	
    sudo apt update -q

    sudo apt install -y docker-ce docker-ce-cli containerd.io
	
    # Let user run docker without sudo
    sudo usermod -aG docker "$USER"


}

main "$@"