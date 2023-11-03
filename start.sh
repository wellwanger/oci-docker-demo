#! /bin/bash

if [ -z $1 ]
  then
    echo "No compartment argument supplied."
  else
    export TF_VAR_network_compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --name $1| jq --raw-output -c '.data[]["id"]')
    terraform init -input=false
    terraform validate
    if [ $? -eq 0 ]; then
        terraform apply --auto-approve
        sleep 1
    else
        echo "Terraform validation failed"
    fi

  VM_PUBLIC_IP=$(terraform state show  module.instance.oci_core_public_ip.public_ip[0] | grep ip_address | cut -d "=" -f 2 | tr -d '"')

  while ! nc -z $VM_PUBLIC_IP 22; do
  sleep 0.1
  done
  fi

  echo "Connect to your lab environment using ssh -i id_rsa opc@$VM_PUBLIC_IP"