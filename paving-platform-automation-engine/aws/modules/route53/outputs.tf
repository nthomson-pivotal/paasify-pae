output "control_plane_domain" {
  value = aws_route53_record.control_plane.name
}

output "ops_manager_domain" {
  value = aws_route53_record.ops_manager.name
}
