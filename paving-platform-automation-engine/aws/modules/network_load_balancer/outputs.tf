output "dns_name" {
  value = aws_lb.load_balancer.dns_name
}

output "security_group_name" {
  value = aws_security_group.load_balancer.name
}

output "target_group_name" {
  value = aws_lb_target_group.load_balancer.name
}
