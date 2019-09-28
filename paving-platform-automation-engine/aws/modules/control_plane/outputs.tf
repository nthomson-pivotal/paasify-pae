output "subnet_ids" {
  value = aws_subnet.control_plane.*.id
}

output "subnet_gateways" {
  value = data.template_file.subnet_gateways.*.rendered
}

output "subnet_cidrs" {
  value = aws_subnet.control_plane.*.cidr_block
}

output "subnet_availability_zones" {
  value = aws_subnet.control_plane.*.availability_zone
}
