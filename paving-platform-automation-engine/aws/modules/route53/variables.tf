variable "zone_id" {
  type        = "string"
  description = "ID of the zone where the Route 53 records will be created"
}

variable "root_domain" {
  type        = "string"
  description = "The domain to append to each Route 53 record"
}

variable "ops_manager_record" {
  type        = list(string)
  description = "Record to use for Ops Manager A record"
}

variable "control_plane_record" {
  type        = list(string)
  description = "Record to use for Control Plane A record"
}

variable "credhub_record" {
  type        = list(string)
  description = "Record to use for Credhub CNAME record"
}

variable "uaa_record" {
  type        = list(string)
  description = "Record to use for UAA CNAME record"
}
