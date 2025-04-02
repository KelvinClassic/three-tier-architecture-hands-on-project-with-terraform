variable "names" {
  type = map(string)
  default = {
    "project_title" = "demo"
    frontend_title = "web_tier"
    backend_title = "app_tier"
    db_tier = "database_tier"
  }
}

variable "project_region" {
  type = string
  default = "us-east-1"
}

variable "public_subnets_config" {
  type = map(any)
  default = {
    az-1-web-tier-subnet = {
      subnet_availability_zone = "us-east-1a"
      subnet_cidr_block = "10.0.10.0/24"
    },

    az-2-web-tier-subnet = {
      subnet_availability_zone = "us-east-1b"
      subnet_cidr_block = "10.0.20.0/24"
    }
  }
}

variable "private_subnets_config" {
  type = map(any)
  default = {
    az-1-app-tier-subnet = {
      subnet_availability_zone = "us-east-1a"
      subnet_cidr_block = "10.0.30.0/24"
    },

    az-2-app-tier-subnet = {
      subnet_availability_zone = "us-east-1b"
      subnet_cidr_block = "10.0.40.0/24"
    }
  }
}

variable "database_subnet_config" {
  type = map(any)
  default = {
    az-1-database-subnet = {
      cidr_ipv4 = "10.0.50.0/24"
      availability_zone = "us-east-1a"
    }
    az-2-database-subnet = {
      cidr_ipv4 = "10.0.60.0/24"
      availability_zone = "us-east-1b"
    }
  }
}