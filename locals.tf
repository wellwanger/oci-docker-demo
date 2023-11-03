locals {

  # Format date
  formatted_date = formatdate("YYYYMMDDhhmm", timestamp())

  # Add new ports to be allowed on inbound security list rules.
  allowed_tcp_inboud_ports = [
    { port = "22", description = "Allow SSH from anywhere" },
    { port = "80", description = "Web" },
    { port = "443", description = "Secure Web" },
    { port = "8080", description = "Random Web" },
  ]

  # Instance shape.
  shape = "VM.Standard.E2.1"

}
