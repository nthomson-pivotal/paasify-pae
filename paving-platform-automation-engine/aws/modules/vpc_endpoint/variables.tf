variable "vpc_id" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "infrastructure_subnets_ids" {
  type = "list"
}

variable "security_group_id" {
  type = "string"
}

variable "availability_zones" {
  type = "list"
}
