#! /bin/bash

if [ -z $1 ]
  then
    echo "No compartment argument supplied."
  else
    read COMPARTMENT
    export TF_VAR_network_compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --name $COMPARTMENT | jq --raw-output -c '.data[]["id"]')
    terraform init
    terraform plan --input-false --out plan.tf
fi