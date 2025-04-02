variable "names" {
  type = map(string)
  default = {
    "project_title" = "demo"
    frontend_title = "web_tier"
    backend_title = "app_tier"
    db_tier = "database_tier"
  }
}

variable "database_instance_config" {
  type = map(any)
  default = {
    allocated_storage = 10
    engine = "mysql"
    engine_version = "8.0.39"
    instance_class = "db.r5.large"
    username = "admin"
    password = ""
    identifier = "demo-my-database"
    availability_zone = "us-east-1a"
  }
}

variable "db_sg" {
  type = list(string)
  description = "Database security group"
  default = []
}

variable "db_subnet_group_name" {
  type = string
  description = "Database security group"
  default = ""
}