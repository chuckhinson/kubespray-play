#!/bin/bash

set -euo pipefail

declare INVENTORY_DIR="$(pwd)/tmp/inventory"
declare INVENTORY_FILE="${INVENTORY_DIR}/inventory.ini"
declare INVENTORY_FILE_TEMPLATE="$(pwd)/inventory.ini.tmpl"
declare KUBESPRAY_DIR="$(pwd)/kubespray"
declare ANSIBLE_CFG="${KUBESPRAY_DIR}/ansible.cfg"
declare SSH_CONFIG_FILE="$(pwd)/ssh-config"
declare SSH_KEY_FILE="${HOME}/.ssh/k8schuck_rsa"

declare BASTION_IP
declare ALL_NODES
declare CONTROLLER_NODES
declare WORKER_NODES
declare ELB_NAME

function gatherClusterInfoFromTerraform () {
  ELB_NAME=$(terraform -chdir=./terraform output -json | jq -r '.elb_dns_name.value')
  BASTION_IP=$(terraform -chdir=./terraform output -json | jq -r '.jumpbox_public_ip.value')
  ALL_NODES=$(terraform -chdir=./terraform output -json | jq -r '.all_nodes.value')
  CONTROLLER_NODES=$(terraform -chdir=./terraform output -json | jq -r '.controller_nodes.value')
  WORKER_NODES=$(terraform -chdir=./terraform output -json | jq -r '.worker_nodes.value')
}

function prepareAnsibleInventoryFile () {
  ( export ALL_NODES CONTROLLER_NODES WORKER_NODES ELB_NAME; \
    cat ${INVENTORY_FILE_TEMPLATE} | envsubst > ${INVENTORY_FILE} )
}

function setupBastionSshConfig () {
  sudo sed -i "s/ProxyJump ubuntu.*/ProxyJump ubuntu@${BASTION_IP}/" "${SSH_CONFIG_FILE}"
  sudo chown 0:0 "${SSH_CONFIG_FILE}"
  sudo chmod og-w "${SSH_CONFIG_FILE}"
}

function runAnsibleContainer () {
  echo "Once connected to the container, run the following commands"
  echo "ssh-keyscan ${BASTION_IP} >> ~/.ssh/known_hosts"
  echo "apt update && apt install python3-jmespath"
  echo "ansible-playbook -b -i /inventory/inventory.ini cluster.yml"

  docker run --rm -it \
    -e BASTION_IP=${BASTION_IP} \
    --mount type=bind,source="${INVENTORY_DIR}",dst=/inventory \
    --mount type=bind,source="${ANSIBLE_CFG}",dst=/kubespray/ansible.cfg \
    --mount type=bind,source="${SSH_KEY_FILE}",dst=/root/.ssh/id_rsa \
    --mount type=bind,source="${SSH_CONFIG_FILE}",dst=/root/.ssh/config \
    quay.io/kubespray/kubespray:v2.21.0 bash
}

function setupKubeAdminConf () {
  SRC_ADMIN_CONF=$INVENTORY_DIR/artifacts/admin.conf
  ADMIN_CONF="$(pwd)/tmp/admin.conf"
  if sudo [ -f "$SRC_ADMIN_CONF" ] ; then
    sudo cp "$SRC_ADMIN_CONF" "$ADMIN_CONF"
    sudo chown "$(id -u):$(id -g)" "${ADMIN_CONF}"
    sed -i "s_server: https://.*_server: https://$ELB_NAME:6443_" "${ADMIN_CONF}"
    echo "For kubectl access, 'export KUBECONFIG=${ADMIN_CONF}'"
  fi
}

function main() {

  gatherClusterInfoFromTerraform
  prepareAnsibleInventoryFile
  setupBastionSshConfig
  runAnsibleContainer
  setupKubeAdminConf

}

main "$@"
