
## Setup
- `cp ./terraform/terraform.tfvars.tmpl ./terraform/terraform.tfvars`
- `vi terraform/terraform.tfvars`   #update values in terraform.tfvars
- `terraform -chdir=./terraform init`
- `git clone https://github.com/kubernetes-sigs/kubespray.git`
- `(cd kubespray; git checkout v2.21.0)`
- Review apb.sh and ensure SSH_KEY_FILE has the right value and that the file is owned by root

## Provision and deploy
- `terraform -chdir=./terraform apply`
- Setup you inventory (skip on subsequent runs if you're sure you're inventory is clean)
  - `sudo rm -rf ./tmp`
  - `mkdir -p tmp/inventory; cp -rfp ./kubespray/inventory/sample/* ./tmp/inventory`
- run ./apb.sh
- In the container:
  - `apt update && apt install python3-jmespath`
  - `ssh-keyscan ${BASTION_IP} >> ~/.ssh/known_hosts`
  - `ansible-playbook -b -i /inventory/inventory.ini --extra-vars "@/inventory/extra_vars.yml" cluster.yml`
  - `exit`
- export KUBECONFIG=$(pwd)/tmp/admin.conf
- `kubectl get nodes; kubectl get pods -A`

## Access dashboard
  - Setup dashboard ingress
    - ELB_IP = ip address for your elb  (nslokup $ELB_NAME)
    - DASHBOARD_HOST_FQDN = the host name you want to use to access the dashboard
    - edit your etc/hosts file and setup an entry for $ELB_IP and $DASHBOARD_HOST_FQDN
    - `export DASHBOARD_HOST_FQDN; cat dashboard-ingress.yml | envsubst | kubectl apply -f -`
  - Setup a user that can log in to the dashboard
    - `kubectl apply -f dashboard-user.yaml`
    - `kubectl -n kubernetes-dashboard create token admin-user`
  - goto https://$DASHBOARD_HOST_FQDN/ and login using token created above

## Testing Persistent Storage
  - `kubectl apply -f pvclaim.yml`
  - `kubectl apply -f pvtestpod.yml`
  - `kubectl get pvc`
  - `kubectl get pv`
  - observe persistent volume and pvc bound to pv
  - wait 15 - 20 seconds
  - `kubectl exec app -- cat /data/out.txt`
  - observe timesteamps in output
  - `kubectl delete pod app`
  - wait a minute or two and spin up new pod
  - `kubectl apply -f pvtestpod.yml`
  - wait 15 - 20 seconds
  - `kubectl exec app -- cat /data/out.txt`
  - observe timestamps and note gap when pod was deleted and then restarted
  - `kubectl delete pod app`
  - `kubectl delete pvc ebs-claim`
  - `kubectl get pvc`
  - `kubectl get pv`
  - observe no persistent volumes allocated
