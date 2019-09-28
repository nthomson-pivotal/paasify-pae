output "iaas" {
  value = "aws"
}

output "region" {
  value = var.region
}

output "azs" {
  value = var.availability_zones
}

output "dns_zone_id" {
  value = aws_route53_zone.hosted_zone.zone_id
}

output "env_dns_zone_name_servers" {
  value = aws_route53_zone.hosted_zone.name_servers
}

output "vms_security_group_id" {
  value = module.infra.vms_security_group_id
}

output "public_subnet_ids" {
  value = module.infra.public_subnet_ids
}

output "public_subnets" {
  value = module.infra.public_subnet_ids
}

output "public_subnet_availability_zones" {
  value = module.infra.public_subnet_availability_zones
}

output "public_subnet_cidrs" {
  value = module.infra.public_subnet_cidrs
}

output "infrastructure_subnet_ids" {
  value = module.infra.infrastructure_subnet_ids
}

output "infrastructure_subnets" {
  value = module.infra.infrastructure_subnets
}

output "infrastructure_subnet_availability_zones" {
  value = module.infra.infrastructure_subnet_availability_zones
}

output "infrastructure_subnet_cidrs" {
  value = module.infra.infrastructure_subnet_cidrs
}

output "infrastructure_subnet_gateways" {
  value = module.infra.infrastructure_subnet_gateways
}

output "vpc_id" {
  value = module.infra.vpc_id
}

output "network_name" {
  value = module.infra.vpc_id
}

/**************
* Ops Manager *
***************/
output "ops_manager_bucket" {
  value = module.ops_manager_config.bucket
}

output "ops_manager_public_ip" {
  value = aws_eip.ops_manager.public_ip
}

output "ops_manager_dns" {
  value = module.dns.ops_manager_domain
}

output "ops_manager_iam_instance_profile_name" {
  value = module.ops_manager_config.ops_manager_iam_instance_profile_name
}

output "ops_manager_iam_user_name" {
  value = module.ops_manager_config.ops_manager_iam_user_name
}

output "ops_manager_iam_user_access_key" {
  value = module.ops_manager_config.ops_manager_iam_user_access_key
}

output "ops_manager_iam_user_secret_key" {
  value     = module.ops_manager_config.ops_manager_iam_user_secret_key
  sensitive = true
}

output "ops_manager_security_group_id" {
  value = module.ops_manager_config.security_group_id
}

output "ops_manager_private_ip" {
  value = aws_eip.ops_manager.private_ip
}

output "ops_manager_ssh_private_key" {
  sensitive = true
  value     = module.ops_manager_config.ssh_private_key
}

output "ops_manager_ssh_public_key_name" {
  value = module.ops_manager_config.ssh_public_key_name
}

output "ops_manager_ssh_public_key" {
  value = module.ops_manager_config.ssh_public_key
}

output "ops_manager_subnet_id" {
  value = local.ops_man_subnet_id
}

/****************
* Control Plane *
*****************/
output "control_plane_domain" {
  value = module.dns.control_plane_domain
}

output "control_plane_root_domain" {
  value = local.root_domain
}

output "control_plane_subnet_ids" {
  value = module.control_plane.subnet_ids
}

output "control_plane_subnet_gateways" {
  value = module.control_plane.subnet_gateways
}

output "control_plane_subnet_cidrs" {
  value = module.control_plane.subnet_cidrs
}

output "control_plane_subnet_availability_zones" {
  value = module.control_plane.subnet_availability_zones
}

output "control_plane_credhub_target_group" {
  value = module.credhub_lb.target_group_name
}

output "control_plane_credhub_security_group" {
  value = module.credhub_lb.security_group_name
}

output "control_plane_uaa_target_group" {
  value = module.uaa_lb.target_group_name
}

output "control_plane_uaa_security_group" {
  value = module.uaa_lb.security_group_name
}

output "control_plane_web_target_group" {
  value = module.plane_lb.target_group_name
}

output "control_plane_web_security_group" {
  value = module.plane_lb.security_group_name
}

output "control_plane_tsa_target_group" {
  value = module.tsa_lb.target_group_name
}

output "control_plane_tsa_security_group" {
  value = module.tsa_lb.security_group_name
}

output "control_plane_vms_security_group" {
  value = module.infra.vms_security_group
}

