
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
  - `ansible-playbook -b -i /inventory/inventory.ini --extra-vars "@/inventory/extra_vars.yml" cluster.yml`
  - `exit`

## Access dashboard
  - Setup dashboard ingress
    - ELB_IP = ip address for your elb  (nslokup $ELB_NAME)
    - DASHBOARD_HOST_FQDN = the host name you want to use to access the dashboard
    - edit your etc/hosts file and setup an entry for $ELB_IP and $DASHBOARD_HOST_FQDN
    - edit dashboard-ingress.yml and replace $DASHBOARD_HOST_FQDN with correct value
    - `kubectl apply -f dashboard-ingress.yml`
  - Setup a user that can log in to the dashboard
    - `kubectl apply -f dashboard-user.yaml`
    - `kubectl -n kubernetes-dashboard create token admin-user`
  - goto https://$DASHBOARD_HOST_FQDN/ and login using token created above
