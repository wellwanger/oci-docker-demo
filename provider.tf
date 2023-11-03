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
  region = "sa-saopaulo-1"
}