module "vpn" {
  source = "../../modules/vpn"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  region                     = var.region
  env_name                   = var.env_name
  root_domain                = local.root_domain
  client_cidr_block          = module.cidr_lookup.vpn_cidr
  zone_id                    = aws_route53_zone.hosted_zone.zone_id
  subnet_to_associate_id     = element(module.infra.closed_subnet_ids, 0)
  cidrs_to_authorize_for_vpn = concat(module.control_plane.subnet_cidrs, module.infra.infrastructure_subnet_cidrs, module.infra.closed_subnet_cidrs)
  vpc_id                     = module.infra.vpc_id
  availability_zone          = element(var.availability_zones, 0)
  security_group_id          = module.infra.vms_security_group_id

  tags = local.actual_tags
}


/********************
* Resolver Endpoint *
********************/

resource "aws_route53_resolver_endpoint" "vpn_inbound" {
  name      = "${var.env_name}-inbound"
  direction = "INBOUND"

  security_group_ids = [module.infra.vms_security_group_id]

  ip_address {
    subnet_id = element(module.infra.infrastructure_subnet_ids, 0)
  }

  ip_address {
    subnet_id = element(module.infra.infrastructure_subnet_ids, 1)
  }

  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane"
    },
  )
}

/********************
* Egress Only - VPN *
********************/

output "egress_only_vpn_endpoint_id" {
  value = module.vpn.egress_only_vpn_endpoint_id
}

output "egress_only_vpn_dns" {
  value = module.vpn.egress_only_vpn_dns
}

output "egress_only_vpn_server_certificate_arn" {
  value = module.vpn.acm_server_certificate_arn
}

output "egress_only_vpn_client_certificate_arn" {
  value = module.vpn.acm_client_certificate_arn
}

output "cidrs_to_authorize_for_vpn" {
  value = module.vpn.cidrs_to_authorize_for_vpn
}

output "aws_route53_resolver_vpn_inbound_endpoint_ips" {
  value = aws_route53_resolver_endpoint.vpn_inbound.ip_address.*.ip
}

output "egress_only_vpn_client_cert" {
  value = module.vpn.egress_only_vpn_client_cert
}

output "egress_only_vpn_client_key" {
  value = module.vpn.egress_only_vpn_client_key
}

output "egress_only_vpn_client_config" {
  value = module.vpn.egress_only_vpn_client_config
}
