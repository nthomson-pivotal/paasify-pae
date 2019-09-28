variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "env_name" {
  type = "string"
}

variable "root_domain" {
  type = "string"
}

variable "client_cidr_block" {
  type = "string"
}

variable "zone_id" {
  type = "string"
}

variable "subnet_to_associate_id" {
  type = "string"
}

variable "security_group_id" {
  type = "string"
}

variable "cidrs_to_authorize_for_vpn" {
  type = "list"
}

variable "availability_zone" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources"
}
