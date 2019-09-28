output "aws_lb_interface_endpoint_ips" {
  value = data.aws_network_interface.lb_endpoints.*.private_ip
}

output "aws_ec2_interface_endpoint_ips" {
  value = data.aws_network_interface.ec2_endpoints.*.private_ip
}
