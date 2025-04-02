# Terraform Project - Three Tier Architecture Automation in AWS

This project involves the use of Terraform configuration to automate the deployment of a three tier archtecture (web-tier, app-tier and database-tier) in AWS. 

The architecture includes the following:
- VPC
- internet gateway
- web tier - 2 public subnets routing to the internet gateway
- 2 nat gateway placed within the plublic subnets
- app-tier - 2 priavte subnets routing to the nat gateway
- database-tier - 2 private subnets specially configured to house the database
- external facing load balancer that sends all tcp traffic from the internet to the web-tier
- internal load balancer that is configured to route traffic securely to the app-tier
-  external autoscaling group that scales EC2 servers in the web-tier to a maximum of 2 in high traffic load
-  internal autoscaling group that scales EC2 servers in the app-tier to a maximum of 2 in high traffic load
