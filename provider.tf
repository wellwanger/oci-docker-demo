terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.102.0"
    }
  }
  required_version = ">= 1.2.6"
}

provider "oci" {
  auth                = "SecurityToken"
  region              = "sa-saopaulo-1"
  config_file_profile = "wellnesslad"
}
