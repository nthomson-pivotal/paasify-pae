variable "vpc_id" {
  type = "string"
}

variable "env_name" {
  type = "string"
}

variable "availability_zones" {
  type = "list"
}

variable "vpc_cidr" {
  type = "string"
}

variable "private_route_table_ids" {
  type = "list"
}

variable "tags" {
  type = "map"
}


variable "control_plane_cidr" {
  type = list(string)
}

module "cidr_lookup" {
  source   = "../calculate_subnets"
  vpc_cidr = var.vpc_cidr
}
