output "vpc_prod_id" {
  description = "The ID of the Prod VPC"
  value       = module.vpc_prod.vpc_id
}

output "vpc_non_prod_id" {
  description = "The ID of the Non-prod VPC"
  value       = module.vpc_non_prod.vpc_id
}

output "vpc_mgmt_id" {
  description = "The ID of the Mgmt VPC"
  value       = module.vpc_mgmt.vpc_id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.lb_dns_name
}

output "ec2_instance_ids" {
  description = "IDs of EC2 instances"
  value       = { for k, v in module.ec2_instances : k => v.id }
}
