variable "names" {
  type = map(string)
  default = {
    "project_title" = "demo"
    frontend_title = "web_tier"
    backend_title = "app_tier"
    db_tier = "database_tier"
  }
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "project_route_tables_cidr_block" {
    type = string
    default = "0.0.0.0/0"  
}

variable "security_groups_cidr_block" {
  type = map(any)
  default = {
    all = "0.0.0.0/0",
    myip =  "82.1.107.0/24"
  }
}

variable "public_subnets_config" {
  type = map(any)
  default = {
    az-1-web-tier-subnet = {
      subnet_availability_zone = ""
      subnet_cidr_block = ""
    },

    az-2-web-tier-subnet = {
      subnet_availability_zone = ""
      subnet_cidr_block = ""
    }
  }
}

variable "private_subnets_config" {
  type = map(any)
  default = {
    az-1-app-tier-subnet = {
      subnet_availability_zone = ""
      subnet_cidr_block = ""
    },

    az-2-app-tier-subnet = {
      subnet_availability_zone = ""
      subnet_cidr_block = ""
    }
  }
}

variable "database_subnet_config" {
  type = map(any)
  default = {
    az-1-database-subnet = {
      cidr_ipv4 = ""
      availability_zone = ""
    }
    az-2-database-subnet = {
      cidr_ipv4 = ""
      availability_zone = ""
    }
  }
}