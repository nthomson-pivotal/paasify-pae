provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  version = "~> 2.17"
}

terraform {
  required_version = ">= 0.12"
}

provider "random" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.0"
}

locals {
  ops_man_subnet_id = element(module.infra.public_subnet_ids, 0)

  bucket_suffix = random_integer.bucket.result

  default_tags = {
    Application = "Control Plane"
  }

  actual_tags = merge(var.tags, local.default_tags)
  root_domain = format("%s.%s", var.env_name, var.dns_suffix)
}

resource "random_integer" "bucket" {
  min = 1
  max = 100000
}

module "infra" {
  source = "../../modules/infra"

  region             = var.region
  env_name           = var.env_name
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr

  tags = local.actual_tags
}

module "cidr_lookup" {
  source   = "../../modules/calculate_subnets"
  vpc_cidr = var.vpc_cidr
}

module "ops_manager_config" {
  source = "../../modules/ops_manager_config"

  env_name      = var.env_name
  region        = var.region
  instance_type = var.ops_manager_instance_type
  vpc_id        = module.infra.vpc_id
  vpc_cidr      = var.vpc_cidr

  bucket_suffix = local.bucket_suffix

  tags = local.actual_tags
}

module "control_plane" {
  source                  = "../../modules/control_plane"
  vpc_id                  = module.infra.vpc_id
  env_name                = var.env_name
  availability_zones      = var.availability_zones
  vpc_cidr                = var.vpc_cidr
  private_route_table_ids = module.infra.deployment_route_table_ids
  control_plane_cidr      = [module.cidr_lookup.control_plane_cidr]
  tags                    = local.actual_tags
}

module "uaa_lb" {
  source                = "../../modules/network_load_balancer"
  name                  = "${var.env_name}-uaa"
  vpc_id                = module.infra.vpc_id
  listener_port         = 443
  target_group_port     = 8443
  env_name              = var.env_name
  public_subnet_ids     = module.infra.public_subnet_ids
  health_check_path     = "/healthz"
  health_check_protocol = "HTTPS"
  health_check_port     = 8443
  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane-uaa"
    },
  )
}

module "credhub_lb" {
  source                = "../../modules/network_load_balancer"
  name                  = "${var.env_name}-credhub"
  vpc_id                = module.infra.vpc_id
  listener_port         = 443
  target_group_port     = 8844
  env_name              = var.env_name
  public_subnet_ids     = module.infra.public_subnet_ids
  health_check_path     = "/health"
  health_check_protocol = "HTTP"
  health_check_port     = 8845
  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane-credhub"
    },
  )
}

module "tsa_lb" {
  source                = "../../modules/network_load_balancer"
  name                  = "${var.env_name}-tsa"
  vpc_id                = module.infra.vpc_id
  listener_port         = 2222
  target_group_port     = 2222
  env_name              = var.env_name
  public_subnet_ids     = module.infra.public_subnet_ids
  health_check_path     = ""
  health_check_protocol = "TCP"
  health_check_port     = 2222
  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane-tsa"
    },
  )
}

module "plane_lb" {
  source                = "../../modules/network_load_balancer"
  name                  = "${var.env_name}-plane"
  vpc_id                = module.infra.vpc_id
  listener_port         = 443
  target_group_port     = 443
  env_name              = var.env_name
  public_subnet_ids     = module.infra.public_subnet_ids
  health_check_path     = ""
  health_check_protocol = "TCP"
  health_check_port     = 443
  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane"
    },
  )
}

module "dns" {
  source = "../../modules/route53"

  zone_id              = aws_route53_zone.hosted_zone.zone_id
  root_domain          = local.root_domain
  ops_manager_record   = [aws_eip.ops_manager.public_ip]
  control_plane_record = [module.plane_lb.dns_name]
  uaa_record           = [module.uaa_lb.dns_name]
  credhub_record       = [module.credhub_lb.dns_name]
}

resource "aws_instance" "ops_manager" {
  ami           = var.ops_manager_ami
  instance_type = var.ops_manager_instance_type
  key_name      = module.ops_manager_config.ssh_public_key_name
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_security_group_ids = [module.ops_manager_config.security_group_id]
  source_dest_check      = false
  subnet_id              = local.ops_man_subnet_id
  iam_instance_profile   = module.ops_manager_config.ops_manager_iam_instance_profile_name

  root_block_device {
    volume_type = "gp2"
    volume_size = 150
  }

  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane-ops-manager"
    },
  )
}

resource "aws_eip" "ops_manager" {
  instance = aws_instance.ops_manager.id
  vpc      = true

  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane-ops-manager"
    },
  )
}

resource "aws_route53_zone" "hosted_zone" {
  name = local.root_domain

  tags = merge(
    local.actual_tags,
    {
      "Name" = "${var.env_name}-control-plane"
    },
  )
}

resource "aws_route53_record" "name_servers" {
  zone_id = var.top_level_zone_id
  name    = local.root_domain

  type = "NS"
  ttl  = 60

  records = aws_route53_zone.hosted_zone.name_servers
}

