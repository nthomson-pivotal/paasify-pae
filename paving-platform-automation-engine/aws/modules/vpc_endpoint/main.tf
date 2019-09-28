locals {
  ec2_address    = "com.amazonaws.${var.region}.ec2"
  lb_api_address = "com.amazonaws.${var.region}.elasticloadbalancing"
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = local.ec2_address
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.infrastructure_subnets_ids
  private_dns_enabled = true
  security_group_ids  = [var.security_group_id]
}

resource "aws_vpc_endpoint" "lb" {
  vpc_id              = var.vpc_id
  service_name        = local.lb_api_address
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.infrastructure_subnets_ids
  private_dns_enabled = true
  security_group_ids  = [var.security_group_id]
}

data "aws_network_interface" "ec2_endpoints" {
  count = length(var.availability_zones)

  id = tolist(aws_vpc_endpoint.ec2.network_interface_ids)[count.index]
}

data "aws_network_interface" "lb_endpoints" {
  count = length(var.availability_zones)

  id = tolist(aws_vpc_endpoint.lb.network_interface_ids)[count.index]
}
