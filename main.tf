resource "random_string" "random" {
  keepers = {
    static = true
  }
  length    = 8
  special   = false
  numeric   = false
  lower     = true
  min_lower = 8
}

#######################################################################################
# VCN
#######################################################################################

variable "network_compartment_id" {
  description = "Network compartment OCID"
  type        = string
}

module "vcn" {
  source                  = "oracle-terraform-modules/vcn/oci"
  version                 = "3.5.4"
  compartment_id          = var.network_compartment_id
  vcn_name                = "VCN-DEMO-${random_string.random.result}"
  vcn_dns_label           = "webapp"
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = false
  vcn_cidrs               = ["10.0.0.0/16"]
}

#######################################################################################
# SECURITY LIST
#######################################################################################

# PUBLIC SUBNET
resource "oci_core_security_list" "public" {
  compartment_id = var.network_compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "SL-PUBLIC-SUBNET"

  dynamic "ingress_security_rules" {
    for_each = local.allowed_tcp_inboud_ports
    content {

      description = lower(ingress_security_rules.value["description"])
      source      = "0.0.0.0/0"
      protocol    = 6
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        min = ingress_security_rules.value["port"]
        max = ingress_security_rules.value["port"]
      }

    }
  }

  ingress_security_rules {
    description = "Path Discovery."
    source      = "0.0.0.0/0"
    protocol    = 1
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }

  egress_security_rules {
    description      = "Allow all egress traffic"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  egress_security_rules {
    description      = "Path Discovery."
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = 1

    icmp_options {
      code = 4
      type = 3
    }
    stateless = false
  }

}

# PRIVATE SUBNET
resource "oci_core_security_list" "private" {
  compartment_id = var.network_compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "SL-PRIVATE-SUBNET"

  ingress_security_rules {
    description = "Allow SSH from VCN"
    source      = module.vcn.vcn_all_attributes.cidr_block
    protocol    = 6
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Allow http port from VCN"
    source      = module.vcn.vcn_all_attributes.cidr_block
    protocol    = 6
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 8081
      max = 8081
    }
  }

  ingress_security_rules {
    description = "Path Discovery within VCN."
    source      = module.vcn.vcn_all_attributes.cidr_block
    protocol    = 1
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }

  egress_security_rules {
    description      = "Allow all egress traffic"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  egress_security_rules {
    description      = "Path Discovery."
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = 1

    icmp_options {
      code = 4
      type = 3
    }
    stateless = false
  }

}


#######################################################################################
# SUBNETS
#######################################################################################
# PUBLIC SUBNET
resource "oci_core_subnet" "public" {
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = var.network_compartment_id
  vcn_id                     = module.vcn.vcn_id
  display_name               = "PUBLIC-SUBNET"
  dns_label                  = "pub"
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
  route_table_id             = module.vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.public.id]
}

# PRIVATE SUBNET
resource "oci_core_subnet" "private" {
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = var.network_compartment_id
  vcn_id                     = module.vcn.vcn_id
  display_name               = "PRIVATE-SUBNET"
  dns_label                  = "prv"
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private.id]
}



