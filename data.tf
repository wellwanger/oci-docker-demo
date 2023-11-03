data "oci_core_images" "search" {
  compartment_id           = var.network_compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = local.shape
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "template_file" "cloud-config" {
  template = <<YAML
#cloud-config
runcmd:
 - dnf install -y dnf-utils zip unzip
 - dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
 - dnf remove -y runc
 - dnf install -y docker-ce --nobest
 - systemctl enable docker.service
 - systemctl start docker.service
 - usermod -aG docker opc
 - firewall-cmd --permanent --zone=public --add-service=http
 - firewall-cmd --permanent --zone=public --add-service=https
 - firewall-cmd --permanent --add-port=8080/tcp
 - firewall-cmd --zone=public --add-masquerade --permanent
 - firewall-cmd --permanent --zone=trusted --add-interface=docker0
 - firewall-cmd --permanent --zone=public --add-interface=ens3
 - firewall-cmd --reload
YAML
}
