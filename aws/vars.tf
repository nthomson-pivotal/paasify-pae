variable "env_name" {

}

variable "vpc_cidr" {
  default = "10.0.0.0/20"
}

variable "region" {

}

variable "dns_suffix" {

}

variable "availability_zones" {
  description = "Optional list of availability zones, will be chosen automatically otherwise"
  type        = list(string)
  default     = []
}

variable "pivnet_token" {
  
}

variable "control_plane_username" {
  default = "admin"
}

variable "control_plane_password" {
  default = ""
}

variable "git_private_key" {
  default = ""
}

variable "ops_manager_instance_type" {
  default = "r4.large"
}