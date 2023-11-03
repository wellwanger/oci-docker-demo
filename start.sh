#! /bin/bash
echo "######### Provide your compartment's name ##########";
read COMPARTMENT

if [ -z $COMPARTMENT ]
  then
    echo "No compartment supplied."
  else
    export TF_VAR_network_compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --name $COMPARTMENT| jq --raw-output -c '.data[]["id"]')
    terraform init -input=false
    terraform validate
    if [ $? -eq 0 ]; then
        terraform apply --auto-approve
        sleep 1
        VM_PUBLIC_IP=$(terraform state show  module.instance.oci_core_public_ip.public_ip[0] | grep ip_address | cut -d "=" -f 2 | tr -d '"' | sed 's/ //g' )

        while ! nc -z $VM_PUBLIC_IP 22; do
        sleep 0.1
        done

        while | systemctl --all --type service | grep -i "docker.service"; do
        sleep 0.1
        done
        echo "Connect to your lab environment using ssh -i id_rsa opc@$VM_PUBLIC_IP"

    else
        echo "Terraform validation failed"
    fi
fi

