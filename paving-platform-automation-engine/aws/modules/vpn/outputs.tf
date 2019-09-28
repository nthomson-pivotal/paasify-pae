output "egress_only_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.egress_only.id
}

output "egress_only_vpn_subnet_id" {
  value = var.subnet_to_associate_id
}

output "egress_only_vpn_dns" {
  value = aws_ec2_client_vpn_endpoint.egress_only.dns_name
}

output "acm_server_certificate_arn" {
  value = aws_ec2_client_vpn_endpoint.egress_only.server_certificate_arn
}

output "acm_client_certificate_arn" {
  value = element(aws_ec2_client_vpn_endpoint.egress_only.authentication_options, 0).root_certificate_chain_arn
}

output "cidrs_to_authorize_for_vpn" {
  value = var.cidrs_to_authorize_for_vpn
}

output "egress_only_vpn_client_cert" {
  value = data.local_file.client_vpn_cert.content
}

output "egress_only_vpn_client_key" {
  value = data.local_file.client_vpn_key.content
}

output "egress_only_vpn_client_config" {
  value = data.local_file.client_config_ovpn.content
}
