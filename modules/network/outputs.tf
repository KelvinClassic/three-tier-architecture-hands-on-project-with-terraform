output "vpc_name" {
  description = "VPC id"
  value = aws_vpc.demo_vpc.id
}

output "public_subnets" {
  description = "Public subnets' ids"
  value = [for subnet in aws_subnet.demo_public_subnets : subnet.id]
}

output "private_subnets" {
  description = "Private subnets' ids"
  value = [for subnet in aws_subnet.demo_private_subnets : subnet.id]
}

output "private_subnet_db" {
  description = "Database subnets' ids"
  value = aws_db_subnet_group.demo_db_subnet_group.name
}

output "external_lb_sg_id" {
  description = "External load balancer security groups' ids"
  value = [aws_security_group.demo_external_lb_sg.id]
}

output "web_tier_sg_id" {
  description = "Public subnets security groups' ids"
  value = [aws_security_group.demo_web_tier_sg.id]
}

output "internal_lb_sg_id" {
  description = "Internal load balancer security groups' ids"
  value = [aws_security_group.demo_internal_lb_sg.id]
}

output "app_tier_sg_id" {
  description = "Private subnets security groups' ids"
  value = [aws_security_group.demo_app_tier_sg.id]
}

output "db_tier_sg" {
  description = "Public subnets security groups' ids"
  value = [aws_security_group.demo_db_sg.id]
}

output "ng_elastic_ip" {
  description = "The elastic ip of the nat gateway"
  value = aws_eip.ng_elastic_ip
}