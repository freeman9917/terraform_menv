output "application_load_balancer_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
}

output "target_group_id" {
  value       = aws_lb_target_group.alb_target_group.id
}