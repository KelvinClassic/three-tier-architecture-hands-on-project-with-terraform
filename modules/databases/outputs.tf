output "db_endpoint" {
  description = "The hostname of the database"
  value = aws_db_instance.aruora_mysql_instance.endpoint
}

output "db_hostname" {
  description = "The hostname of the database"
  value = aws_db_instance.aruora_mysql_instance.address
}