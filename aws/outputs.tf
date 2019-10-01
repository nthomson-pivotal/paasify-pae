output "opsman_host" {
  value = module.setup_director.opsman_host
}

output "opsman_username" {
  value = module.setup_director.opsman_username
}

output "opsman_password" {
  value = module.setup_director.opsman_password
}

output "control_plane_domain" {
  value = local.plane_endpoint
}

output "control_plane_username" {
  value = module.common.control_plane_username
}

output "control_plane_password" {
  value = module.common.control_plane_password
}

output "provisioner_host" {
  value = module.setup_director.provisioner_host
}

output "provisioner_ssh_username" {
  value = module.setup_director.provisioner_ssh_username
}

output "provisioner_ssh_private_key" {
  value = module.setup_director.provisioner_ssh_private_key
}