variable "env_name" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "availability_zones" {
  type = "list"
}

variable "vpc_cidr" {
  type = "string"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources"
}

module "cidr_lookup" {
  source   = "../calculate_subnets"
  vpc_cidr = var.vpc_cidr
}

locals {
  infrastructure_cidr = module.cidr_lookup.infrastructure_cidr
  public_cidr         = module.cidr_lookup.public_cidr
  closed_cidr         = module.cidr_lookup.closed_cidr
}
