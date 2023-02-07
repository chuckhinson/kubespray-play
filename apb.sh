#!/bin/bash

set -euo pipefail

docker run --rm -it \
  --mount type=bind,source="$(pwd)"/kubespray/inventory/mycluster,dst=/inventory \
  --mount type=bind,source="$(pwd)"/kubespray/ansible.cfg,dst=/kubespray/ansible.cfg \
  --mount type=bind,source="${HOME}"/.ssh/k8splay_rsa,dst=/root/.ssh/id_rsa \
  --mount type=bind,source="$(pwd)"/ssh-config,dst=/root/.ssh/config \
  quay.io/kubespray/kubespray:v2.21.0 bash


# Inside the container you may now run the kubespray playbooks:
#ansible-playbook -b -i /inventory/inventory.ini cluster.yml
