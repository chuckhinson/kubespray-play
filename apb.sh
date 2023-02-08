#!/bin/bash

set -euo pipefail

INVENTORY_DIR="$(pwd)"/tmp/inventory
ANSIBLE_CFG="$(pwd)"/kubespray/ansible.cfg
SSH_KEY_FILE="${HOME}"/.ssh/k8splay_rsa
SSH_CONFIG_FILE="$(pwd)"/ssh-config

set -euo pipefail

echo "Once connected to the container, run the following commands"
echo "apt update && apt install python3-jmespath"
echo "ssh 10.2.2.10   #Ctl-C once you've accepted the host key"
echo "ansible-playbook -b -i /inventory/inventory.ini cluster.yml"

docker run --rm -it \
  --mount type=bind,source="${INVENTORY_DIR}",dst=/inventory \
  --mount type=bind,source="${ANSIBLE_CFG}",dst=/kubespray/ansible.cfg \
  --mount type=bind,source="${SSH_KEY_FILE}",dst=/root/.ssh/id_rsa \
  --mount type=bind,source="${SSH_CONFIG_FILE}",dst=/root/.ssh/config \
  quay.io/kubespray/kubespray:v2.21.0 bash


SRC_ADMIN_CONF=$INVENTORY_DIR/artifacts/admin.conf
ADMIN_CONF="$(pwd)/tmp/admin.conf"
if sudo [ -f "$SRC_ADMIN_CONF" ] ; then 
  sudo cp "$SRC_ADMIN_CONF" "$ADMIN_CONF"
  sudo chown "$(id -u):$(id -g)" "${ADMIN_CONF}"
  echo "For kubectl access, 'export KUBECONFIG=${ADMIN_CONF}'"
fi
