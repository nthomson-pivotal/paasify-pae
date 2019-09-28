variable "env_name" {
  description = <<-EOL
  This value is used to namespace all the resources created.
  It is always prepended.
  For example, "env" would create a network named "env-network".

  It is recommended to keep the name short, but identifiable, as some resource have name length limitations.
  EOL
}

variable "dns_suffix" {
  description = <<-EOL
  This value is appended to each DNS entry created in Route 53.
  For example, "example.com" will create an entry "pcf.example.com".
  EOL
}

variable "access_key" {
  description = "The access key for the account that has access to create these resources"
}

variable "secret_key" {
  description = "The secret key for the account that has access to create these resources"
}

variable "region" {
  description = "The AWS region that the resources will be created in"
}

variable "availability_zones" {
  description = <<-EOL
  For each AZ provided, a subnet will be created in each one.
  This is useful to have resources (ie BOSH VMs and OpsManager) created for high availability.
  EOL

  type = "list"
}

variable "vpc_cidr" {
  type = "string"
  default = "10.0.0.0/20"

  description = <<-EOL
  This cidr will be used to calculate the subnets for your deployment.
  The two supported cidrs are:
  - 10.0.0.0/16
  - 10.0.0.0/20
  EOL
}

variable "top_level_zone_id" {
  type = "string"

  description = <<-EOL
  Top level hosted zone that we are going to wire NS records
  This allows a zone to be delegated to, so the top level zone doesn't get polluted with more route entries.
  EOL
}

/**************
* Ops Manager *
***************/
variable "ops_manager_ami" {
  type = "string"

  description = <<-EOL
  AMI to use when creating the Ops Manager VM.
  This can be pulled from Pivotal Network, via the YAML/PDF of the OpsManager version to be installed.
  EOL
}

variable "ops_manager_instance_type" {
  type        = "string"
  default     = "r4.large"
  description = "Size of the instance that will be your Ops Manager. Currently defaulted to an r4.large"
}

/******
* RDS *
*******/
variable "rds_db_username" {
  default     = "administrator"
  description = "The username for your Postgres administrator"
}

variable "rds_instance_class" {
  default     = "db.m4.large"
  description = "Size of the RDS instance that will be created for your Postgres"
}

variable "rds_atc_db_name" {
  default     = "atc"
  description = "Database to create for Concourse"
}

variable "rds_credhub_db_name" {
  default     = "credhub"
  description = "Database to create for Credhub"
}

variable "rds_uaa_db_name" {
  default     = "uaa"
  description = "Database to create for UAA"
}

/********
* Tags  *
*********/
variable "tags" {
  type        = "map"
  default     = {}
  description = "Key/value tags to assign to all AWS resources that support tags"
}
