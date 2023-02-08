#!/bin/bash

set -euo pipefail

INVENTORY_DIR="$(pwd)/tmp/inventory"
INVENTORY_FILE="$(pwd)/inventory.ini"
KUBESPRAY_DIR="$(pwd)/kubespray"
ANSIBLE_CFG="${KUBESPRAY_DIR}/ansible.cfg"
SSH_CONFIG_FILE="$(pwd)/ssh-config"
SSH_KEY_FILE="${HOME}/.ssh/k8splay_rsa"

ELB_NAME=$(terraform -chdir=./terraform output -json | jq -r '.elb_dns_name.value')
sed -i "/^apiserver_loadbalancer_domain_name=/c\apiserver_loadbalancer_domain_name=\"$ELB_NAME\"" "${INVENTORY_FILE}"

BASTION_IP=$(terraform -chdir=./terraform output -json | jq -r '.jumpbox_public_ip.value')
sudo sed -i "s/ProxyJump ubuntu.*/ProxyJump ubuntu@${BASTION_IP}/" "${SSH_CONFIG_FILE}"
sudo chown 0:0 "${SSH_CONFIG_FILE}"
sudo chmod og-w "${SSH_CONFIG_FILE}"

echo "Once connected to the container, run the following commands"
echo "ssh 10.2.2.10   #Ctl-C once you've accepted the host key"
echo "apt update && apt install python3-jmespath"
echo "ansible-playbook -b -i /inventory/inventory.ini cluster.yml"

docker run --rm -it \
  --mount type=bind,source="${INVENTORY_DIR}",dst=/inventory \
  --mount type=bind,source="${INVENTORY_FILE}",dst=/inventory/inventory.ini \
  --mount type=bind,source="${ANSIBLE_CFG}",dst=/kubespray/ansible.cfg \
  --mount type=bind,source="${SSH_KEY_FILE}",dst=/root/.ssh/id_rsa \
  --mount type=bind,source="${SSH_CONFIG_FILE}",dst=/root/.ssh/config \
  quay.io/kubespray/kubespray:v2.21.0 bash


SRC_ADMIN_CONF=$INVENTORY_DIR/artifacts/admin.conf
ADMIN_CONF="$(pwd)/tmp/admin.conf"
if sudo [ -f "$SRC_ADMIN_CONF" ] ; then 
  sudo cp "$SRC_ADMIN_CONF" "$ADMIN_CONF"
  sudo chown "$(id -u):$(id -g)" "${ADMIN_CONF}"
  sed -i "s_server: https://.*_server: https://$ELB_NAME:6443_" "${ADMIN_CONF}"
  echo "For kubectl access, 'export KUBECONFIG=${ADMIN_CONF}'"
fi
