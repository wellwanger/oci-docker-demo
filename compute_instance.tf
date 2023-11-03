#######################################################################################
# COMPUTE INSTANCE
#######################################################################################

# Generate a new SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.ssh.private_key_pem}' > mykey.pem
      chmod 400 mykey.pem
    EOT
  }
}

resource "local_file" "pem" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = 400
}

module "instance" {
  source                     = "oracle-terraform-modules/compute-instance/oci"
  version                    = "2.4.1"
  instance_count             = 1
  ad_number                  = 1
  compartment_ocid           = var.network_compartment_id
  instance_display_name      = "instance-${local.formatted_date}-${random_string.random.result}"
  source_ocid                = data.oci_core_images.search.images[0].id
  subnet_ocids               = [oci_core_subnet.public.id]
  public_ip                  = "EPHEMERAL"
  ssh_public_keys            = tls_private_key.ssh.public_key_openssh
  block_storage_sizes_in_gbs = [50]
  shape                      = local.shape
  instance_state             = "RUNNING"
  boot_volume_backup_policy  = "disabled"
  extended_metadata = {
    user_data = "${base64encode(data.template_file.cloud-config.rendered)}"
  }
}