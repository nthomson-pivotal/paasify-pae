resource "aws_ec2_client_vpn_endpoint" "egress_only" {
  description            = "VPN to test egress only network"
  server_certificate_arn = data.aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr_block

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client.arn
  }

  connection_log_options {
    enabled = false
  }

  split_tunnel = true

  tags = merge(var.tags, map("Name", "${var.env_name}-egress-only-vpn"))
}

resource "aws_ec2_client_vpn_network_association" "vpn_to_subnet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.egress_only.id
  subnet_id              = var.subnet_to_associate_id
}

resource "null_resource" "configure_vpn_endpoint" {
  depends_on = [aws_ec2_client_vpn_endpoint.egress_only]

  provisioner "local-exec" {
    when        = "create"
    command     = data.local_file.configure_vpn_endpoint.content
    interpreter = ["/bin/bash", "-c"]

    environment = {
      ROOT_DOMAIN           = var.root_domain
      VPC_ID                = var.vpc_id
      SECURITY_GROUP_ID     = var.security_group_id
      VPN_ENDPOINT_ID       = aws_ec2_client_vpn_endpoint.egress_only.id
      CIDRS_TO_AUTHORIZE    = join(" ", var.cidrs_to_authorize_for_vpn)
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
      AWS_DEFAULT_REGION    = var.region
    }
  }
}

resource "null_resource" "setup_mutual_tls" {
  provisioner "local-exec" {
    when        = "create"
    command     = data.local_file.setup_mutual_tls_for_vpn.content
    interpreter = ["/bin/bash", "-c"]

    environment = {
      REGION                = var.region
      ROOT_DOMAIN           = var.root_domain
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
      AWS_DEFAULT_REGION    = var.region
    }
  }
}

data "local_file" "setup_mutual_tls_for_vpn" {
  filename = "${path.module}/scripts/setup_mutual_tls_for_vpn.sh"
}

data "local_file" "configure_vpn_endpoint" {
  filename = "${path.module}/scripts/configure_vpn_endpoint.sh"
}

data "local_file" "client_vpn_cert" {
  depends_on = [null_resource.setup_mutual_tls]
  filename   = "${path.cwd}/mutual_auth/client.${var.root_domain}.crt"
}

data "local_file" "client_vpn_key" {
  depends_on = [null_resource.setup_mutual_tls]
  filename   = "${path.cwd}/mutual_auth/client.${var.root_domain}.key"
}

data "local_file" "client_config_ovpn" {
  depends_on = [null_resource.configure_vpn_endpoint]
  filename   = "${path.cwd}/client-config.ovpn"
}

data "aws_acm_certificate" "server" {
  depends_on = [null_resource.setup_mutual_tls]

  domain      = var.root_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "client" {
  depends_on = [null_resource.setup_mutual_tls]

  domain      = format("%s.%s", "client", var.root_domain)
  statuses    = ["ISSUED"]
  most_recent = true
}
