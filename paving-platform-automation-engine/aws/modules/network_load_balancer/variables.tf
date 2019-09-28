variable "name" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "vpc_id" {
  type = "string"
}

variable "internal" {
  default = false
  type    = bool
}

variable "target_group_port" {
  type = "string"
}

variable "listener_port" {
  type = "string"
}

variable "env_name" {
  type = "string"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "health_check_path" {
  type = "string"
}

variable "health_check_protocol" {
  type = "string"
}

variable "health_check_port" {
  type = "string"
}
