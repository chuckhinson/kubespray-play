
## Initial run
- `cp ./terraform/terraform.tfvars.tmpl ./terraform/terraform.tfvars`
- `vi terraform/terraform.tfvars`   #update values in terraform.tfvars
- `terraform -chdir=./terraform init`
- `terraform -chdir=./terraform apply`
- `git clone https://github.com/kubernetes-sigs/kubespray.git`
- `(cd kubespray; git checkout v2.21.0)`
- `mkdir -p tmp/inventory; cp -rfp ./kubespray/inventory/sample/* ./tmp/inventory`
- Review apb.sh and ensure SSH_KEY_FILE has the right value and that the file is owned by root
- run ./apb.sh
- in container:
  - `apt update && apt install python3-jmespath`
  - `ssh-keyscan ${BASTION_IP} >> ~/.ssh/known_hosts`
  - `ansible-playbook -b -i /inventory/inventory.ini cluster.yml`
  - `exit`
- export KUBECONFIG=$(pwd)/tmp/admin.conf
- `kubectl get nodes; kubectl get pods -A`

## Subsquent runs
- `terraform -chdir=./terraform apply`
- If you're not sure that your kubespray inventory is clean
  - `sudo rm -rf ./tmp`
  - `mkdir -p tmp/inventory; cp -rfp ./kubespray/inventory/sample/* ./tmp/inventory`
- run ./apb.sh
- In the container:
  - `apt update && apt install python3-jmespath`
  - `ssh-keyscan ${BASTION_IP} >> ~/.ssh/known_hosts`
  - `ansible-playbook -b -i /inventory/inventory.ini cluster.yml`
  - `exit`
