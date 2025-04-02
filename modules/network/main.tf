resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.names.project_title}-cloud-network"
  }
}

resource "aws_internet_gateway" "demo_igw" {
  tags = {
    Name = "${var.names.project_title}-internet-gateway"
  }
}

resource "aws_internet_gateway_attachment" "demo-vpc-igw-attachment" {
  vpc_id              = aws_vpc.demo_vpc.id
  internet_gateway_id = aws_internet_gateway.demo_igw.id
}

resource "aws_eip" "ng_elastic_ip" {}

resource "aws_nat_gateway" "ngw" {
  subnet_id = aws_subnet.demo_public_subnets["az-1-web-tier-subnet"].id
  allocation_id = aws_eip.ng_elastic_ip.id

  tags = {
    Name = "${var.names.project_title}-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.demo_igw]
}

resource "aws_route_table" "demo_public_subnets_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = var.project_route_tables_cidr_block
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "${var.names.frontend_title}-subnet-route-table"
  }
}

resource "aws_route_table" "demo_private_subnets_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block     = var.project_route_tables_cidr_block
    # Route to nat gateway
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "${var.names.backend_title}-subnet-route-table"
  }
}

resource "aws_route_table_association" "public_subnets_rt_association" {
  for_each = aws_subnet.demo_public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.demo_public_subnets_rt.id
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.demo_private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.demo_private_subnets_rt.id
}

resource "aws_security_group" "demo_external_lb_sg" {
  name        = "external-lb-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.names.project_title}-external-lb-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_external_lb" {
  security_group_id = aws_security_group.demo_external_lb_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["all"]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_external_lb" {
  security_group_id = aws_security_group.demo_external_lb_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["myip"] # Provide your network ipv4 for secure ssh connection
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_public_subnet" {
  security_group_id = aws_security_group.demo_external_lb_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["all"]
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "demo_web_tier_sg" {
  name        = "web-app-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress = [
    {
      description      = "Allow HTTP traffic from external lb"
      from_port        = 80
      protocol         = "tcp"
      to_port          = 80
      security_groups  = [aws_security_group.demo_external_lb_sg.id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },

    {
      description        = "Allow SSH traffic from external lb"
      from_port        = 22
      protocol         = "tcp"
      to_port          = 22
      security_groups  = [aws_security_group.demo_external_lb_sg.id]
      cidr_blocks      = [var.security_groups_cidr_block["myip"]] # Provide your network ipv4 for secure ssh connection
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  egress = [
    {
      description        = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = [var.security_groups_cidr_block["all"]]
      security_groups  = []
      protocol         = "-1" # semantically equivalent to all ports
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]


  tags = {
    Name = "${var.names.project_title}-${var.names.frontend_title}-security-group"
  }
}

resource "aws_security_group" "demo_internal_lb_sg" {
  name        = "internal-lb-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.names.project_title}-internal-lb-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_internal_lb" {
  security_group_id = aws_security_group.demo_internal_lb_sg.id
  referenced_security_group_id = aws_security_group.demo_web_tier_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_internal_lb" {
  security_group_id = aws_security_group.demo_internal_lb_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["all"]
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "demo_app_tier_sg" {
  name        = "Private-app-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.names.project_title}-${var.names.backend_title}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo_allow_traffic_to_private_app" {
  security_group_id = aws_security_group.demo_app_tier_sg.id
  referenced_security_group_id = aws_security_group.demo_internal_lb_sg.id
  from_port         = 4000
  ip_protocol       = "tcp"
  to_port           = 4000
}

# Allow web_app server to ssh into priavte_app server
resource "aws_vpc_security_group_ingress_rule" "demo_allow_web_app_ssh_into_private_app" {
  security_group_id = aws_security_group.demo_app_tier_sg.id
  referenced_security_group_id = aws_security_group.demo_web_tier_sg.id 
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "demo_allow_all_traffic_from_priavte_app" {
  security_group_id = aws_security_group.demo_app_tier_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["all"]
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "demo_db_sg" {
  name        = "Database-security-group"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.names.project_title}-${var.names.db_tier}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_protocol_to_db" {
  security_group_id = aws_security_group.demo_db_sg.id
  referenced_security_group_id = aws_security_group.demo_app_tier_sg.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_db" {
  security_group_id = aws_security_group.demo_db_sg.id
  cidr_ipv4         = var.security_groups_cidr_block["all"]
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_subnet" "demo_public_subnets" {
  for_each = var.public_subnets_config
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = each.value.subnet_cidr_block
  availability_zone = each.value.subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.names.project_title}-${each.key}"
  }
}

resource "aws_subnet" "demo_private_subnets" {
  for_each = var.private_subnets_config
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = each.value.subnet_cidr_block
  availability_zone = each.value.subnet_availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.names.project_title}-${each.key}"
  }
}

resource "aws_subnet" "demo_db_subnets" {
  for_each = var.database_subnet_config
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = each.value.cidr_ipv4
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${var.names.project_title}-${var.names.db_tier}-subnets"
  }
}

resource "aws_db_subnet_group" "demo_db_subnet_group" {
  name       = "${var.names.project_title}-${var.names.db_tier}-subnet-group"
  subnet_ids = [for subnet in aws_subnet.demo_db_subnets : subnet.id]

  tags = {
    Name = "${var.names.project_title}-${var.names.db_tier}-subnet-group"
  }
}