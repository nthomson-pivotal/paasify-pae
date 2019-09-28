output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "deployment_route_table_ids" {
  value = aws_route_table.deployment.*.id
}

output "vms_security_group_id" {
  value = aws_security_group.vms_security_group.id
}

output "vms_security_group" {
  value = aws_security_group.vms_security_group.name
}

output "public_subnet_availability_zones" {
  value = aws_subnet.public_subnets.*.availability_zone
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnets.*.cidr_block
}

output "infrastructure_subnet_ids" {
  value = aws_subnet.infrastructure_subnets.*.id
}

output "infrastructure_subnets" {
  value = aws_subnet.infrastructure_subnets.*.id
}

output "infrastructure_subnet_availability_zones" {
  value = aws_subnet.infrastructure_subnets.*.availability_zone
}

output "infrastructure_subnet_cidrs" {
  value = aws_subnet.infrastructure_subnets.*.cidr_block
}

output "infrastructure_subnet_gateways" {
  value = data.template_file.infrastructure_subnet_gateways.*.rendered
}
