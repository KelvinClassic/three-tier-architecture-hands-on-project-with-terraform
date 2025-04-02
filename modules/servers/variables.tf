variable "names" {
  type = map(string)
  default = {
    "project_title" = "demo"
    frontend_title = "web_tier"
    backend_title = "app_tier"
    db_tier = "database_tier"
  }
}

variable "key_config" {
  type = map(any)
  default = {
    key_name = "kelassic-user-keypair02"
    include_public_key = "true"
    filter_name = "fingerprint"
    filter_values = "5e:47:ce:ba:1e:15:2f:c8:14:63:af:6e:76:e6:fd:05"
  }
}

variable "vpc_name" {
  type = string
  description = "VPC id for the architecture"
}

variable "external_lb_sg" {
  type = list(string)
  description = "Security group for external load balancer"
  default = []
}

variable "internal_lb_sg" {
  type = list(string)
  description = "Security group for internal load balancer"
  default = []
}

variable "public_subnets" {
  type = list(string)
  description = "Public subnets' Ids"
  default = []
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnets' Ids"
  default = []
}

variable "web_tier_sg" {
  type = list(string)
  description = "Security group(s) for public facing application server"
  default = []
}

variable "app_tier_sg" {
  type = list(string)
  description = "Security group(s) for private facing application server"
  default = []
}