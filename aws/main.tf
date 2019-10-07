provider "aws" {
  region = var.region
}

module "opsman_image" {
  source = "github.com/nthomson-pivotal/paasify-core//opsmanager-image/aws"

  om_version = "2.7.0"
  om_build   = "165"
}

data "aws_route53_zone" "selected" {
  name = "${var.dns_suffix}."
}

module "infra" {
  source = "../paving-platform-automation-engine/aws/examples/open-network"

  env_name           = var.env_name

  dns_suffix         = var.dns_suffix

  access_key         = ""
  secret_key         = ""

  region             = var.region
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
  top_level_zone_id  = data.aws_route53_zone.selected.zone_id

  ops_manager_ami           = module.opsman_image.ami_id
  ops_manager_instance_type = var.ops_manager_instance_type
}

resource "null_resource" "infra_blocker" {
  depends_on = [module.infra]
}

locals {
  plane_endpoint   = "plane.${module.infra.control_plane_root_domain}"
  credhub_endpoint = "credhub.${module.infra.control_plane_root_domain}"
  uaa_endpoint     = "uaa.${module.infra.control_plane_root_domain}"
}

module "build_network_config" {
  source = "github.com/nthomson-pivotal/paasify-core//build-network-config/aws"

  vpc_cidr      = var.vpc_cidr
  subnet_ids    = module.infra.control_plane_subnet_ids
  subnet_cidrs  = module.infra.control_plane_subnet_cidrs
  subnet_azs    = module.infra.control_plane_subnet_availability_zones
}

data "template_file" "director_ops_file" {
  template = "${chomp(file("${path.module}/templates/director-ops-file.yml"))}"

  vars = {
    cp_subnets = module.build_network_config.subnet_config
    env_name   = var.env_name
  }
}

data "template_file" "resource_config" {
  template = "${chomp(file("${path.module}/templates/cp-resource-config.yml"))}"

  vars = {
    web_target_group      = module.infra.control_plane_web_target_group
    credhub_target_group  = module.infra.control_plane_credhub_target_group
    uaa_target_group      = module.infra.control_plane_uaa_target_group
  }
}

module "setup_director" {
  source = "github.com/nthomson-pivotal/paasify-core//setup-director/aws"

  env_name                    = var.env_name
  provisioner_subnet_id       = module.infra.public_subnet_ids[0]
  dns_zone_id                 = module.infra.dns_zone_id
  pivnet_token                = var.pivnet_token
  om_host                     = module.infra.ops_manager_dns

  azs                         = var.availability_zones
  iam_instance_profile        = module.infra.ops_manager_iam_instance_profile_name
  vpc_id                      = module.infra.vpc_id
  security_group              = module.infra.vms_security_group_id
  key_pair_name               = module.infra.ops_manager_ssh_public_key_name
  ssh_private_key             = module.infra.ops_manager_ssh_private_key
  region                      = var.region
  bucket_name                 = module.infra.ops_manager_bucket
  bucket_access_key_id        = module.infra.ops_manager_iam_user_access_key
  bucket_secret_access_key    = module.infra.ops_manager_iam_user_secret_key

  vpc_cidr                    = var.vpc_cidr
  management_subnet_ids       = module.infra.infrastructure_subnet_ids
  management_subnet_cidrs     = module.infra.infrastructure_subnet_cidrs
  management_subnet_azs       = module.infra.infrastructure_subnet_availability_zones

  director_ops_file           = data.template_file.director_ops_file.rendered

  additional_cert_domains     = [local.plane_endpoint, local.credhub_endpoint, local.uaa_endpoint]

  secrets = {
    admin_access_key_id                = aws_iam_access_key.key.id
    admin_secret_access_key            = aws_iam_access_key.key.secret
    pivnet_token                       = var.pivnet_token
    control_plane_s3_endpoint          = "https://s3.${aws_s3_bucket.control_plane_artifacts.region}.amazonaws.com"
    control_plane_s3_region            = aws_s3_bucket.control_plane_artifacts.region
    control_plane_s3_access_key_id     = aws_iam_access_key.control_plane_bucket.id
    control_plane_s3_secret_access_key = aws_iam_access_key.control_plane_bucket.secret
    control_plane_s3_artifact_bucket   = aws_s3_bucket.control_plane_artifacts.bucket
    control_plane_s3_exports_bucket    = aws_s3_bucket.control_plane_exports.bucket
    git_private_key                    = base64encode(var.git_private_key)
  }

  blocker                     = null_resource.infra_blocker.id
}

module "common" {
  source = "../common"

  iaas               = "aws"
  additional_config  = data.template_file.resource_config.rendered
    
  az_configuration = module.setup_director.az_configuration
  singleton_az     = var.availability_zones[0]

  plane_endpoint   = local.plane_endpoint
  credhub_endpoint = local.credhub_endpoint
  uaa_endpoint     = local.uaa_endpoint

  tls_cert         = module.setup_director.cert_full_chain
  tls_private_key  = module.setup_director.cert_key
  tls_ca_cert      = module.setup_director.cert_ca

  control_plane_username = var.control_plane_username
  control_plane_password = var.control_plane_password

  provisioner_host            = module.setup_director.provisioner_host
  provisioner_ssh_username    = module.setup_director.provisioner_ssh_username
  provisioner_ssh_private_key = module.setup_director.provisioner_ssh_private_key

  blocker          = module.setup_director.blocker
}