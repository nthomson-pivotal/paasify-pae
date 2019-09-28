locals {
  control_plane_password = "${var.control_plane_password == "" ? random_string.control_plane_password.result : var.control_plane_password}"
}

resource "random_string" "control_plane_password" {
  length  = 8
  special = false
}

data "template_file" "tile_configuration" {
  template = "${chomp(file("${path.module}/templates/config.yml"))}"

  vars = {
    az_configuration = var.az_configuration
    az               = var.singleton_az

    plane_endpoint   = var.plane_endpoint
    credhub_endpoint = var.credhub_endpoint
    uaa_endpoint     = var.uaa_endpoint

    control_plane_username = var.control_plane_username
    control_plane_password = local.control_plane_password

    tls_cert         = "${jsonencode(var.tls_cert)}"
    tls_private_key  = "${jsonencode(var.tls_private_key)}"
  }
}

module "control_plane" {
  source = "github.com/nthomson-pivotal/paasify-core//opsmanager-tile"

  slug         = "platform-automation-engine"
  tile_version = "1.0.2-beta.1"
  om_product   = "control-plane"
  iaas         = var.iaas
  config       = "${data.template_file.tile_configuration.rendered}\n\n${var.additional_config}"

  provisioner_host        = var.provisioner_host
  provisioner_username    = var.provisioner_ssh_username
  provisioner_private_key = var.provisioner_ssh_private_key

  blocker                 = var.blocker
}

module "apply_changes" {
  source = "github.com/nthomson-pivotal/paasify-core//apply-changes"

  provisioner_host            = var.provisioner_host
  provisioner_ssh_username    = var.provisioner_ssh_username
  provisioner_ssh_private_key = var.provisioner_ssh_private_key

  blocker       = module.control_plane.blocker
}