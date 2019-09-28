resource "aws_route53_record" "ops_manager" {
  name    = "pcf.${var.root_domain}"
  zone_id = var.zone_id
  type    = "A"
  ttl     = 300

  records = var.ops_manager_record
}

resource "aws_route53_record" "control_plane" {
  zone_id = var.zone_id
  name    = "plane.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300

  records = var.control_plane_record
}

resource "aws_route53_record" "uaa" {
  zone_id = var.zone_id
  name    = "uaa.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300

  records = var.uaa_record
}

resource "aws_route53_record" "credhub" {
  zone_id = var.zone_id
  name    = "credhub.${var.root_domain}"
  type    = "CNAME"
  ttl     = 300

  records = var.credhub_record
}
