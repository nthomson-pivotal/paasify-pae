variable "iaas" {

}

variable "az_configuration" {
  
}

variable "singleton_az" {

}

variable "plane_endpoint" {

}

variable "credhub_endpoint" {

}

variable "uaa_endpoint" {

}

variable "tls_cert" {

}

variable "tls_private_key" {

}

variable "tls_ca_cert" {
    
}

variable "additional_config" {
  default = ""
}

variable "provisioner_host" {
  description = "The host of the paasify provisioner used to trigger the install the tile"
}

variable "provisioner_ssh_username" {
  description = "The host of the paasify provisioner used to trigger the install the tile"
}

variable "provisioner_ssh_private_key" {
  description = "The SSH private key of the paasify provisioner"
}

variable "blocker" {

}

variable "control_plane_username" {
  default = "admin"
}

variable "control_plane_password" {
  default = ""
}