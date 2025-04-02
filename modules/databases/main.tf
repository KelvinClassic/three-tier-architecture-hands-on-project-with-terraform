resource "aws_db_instance" "aruora_mysql_instance" {
  allocated_storage = var.database_instance_config["allocated_storage"]
  engine = var.database_instance_config["engine"]
  engine_version = var.database_instance_config["engine_version"]
  instance_class = var.database_instance_config["instance_class"]
  username = var.database_instance_config["username"]
  password = var.database_instance_config["password"]
  identifier = var.database_instance_config["identifier"]
  availability_zone = var.database_instance_config["availability_zone"]
  vpc_security_group_ids = var.db_sg
  db_subnet_group_name = var.db_subnet_group_name
  skip_final_snapshot = true

  tags = {
    Name = "${var.names.project_title}-${var.names.db_tier}-instance"
  }
}