#! /bin/bash

if [ -z $1 ]
  then
    echo "No compartment argument supplied."
  else
    export TF_VAR_network_compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --name $1| jq --raw-output -c '.data[]["id"]')
    terraform init
    terraform plan --out plan.tf
fi