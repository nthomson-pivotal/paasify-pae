variable "region" {
  type = "string"
}

variable "env_name" {}

variable "instance_type" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "additional_iam_roles_arn" {
  type    = "list"
  default = []
}

variable "bucket_suffix" {}

variable "tags" {
  type = "map"
}
