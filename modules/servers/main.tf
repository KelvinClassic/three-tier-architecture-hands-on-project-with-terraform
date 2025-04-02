data "aws_ami" "demo_web_app_ubuntu_ami" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    
    name = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_key_pair" "demo_key_pair" {
  key_name = var.key_config["key_name"]
  include_public_key = var.key_config["include_public_key"]

  filter {
    name = var.key_config["filter_name"]
    values = [var.key_config["filter_values"]]
  }
}

# resource "aws_instance" "demo_web_app_instances" {
#   for_each = aws_subnet.demo_public_subnets
#   ami = data.aws_ami.demo_web_app_ubuntu_ami.id
#   instance_type = "t2.micro"
#   subnet_id = each.value.id
#   key_name = data.aws_key_pair.demo_key_pair.key_name
#   security_groups = [aws_security_group.demo_web_app_sg.id]
#   user_data = file(user_data_web.tftpl)

#   tags = {
#     Name = "Web server"
#   }
# }

# resource "aws_instance" "demo_private_app_instances" {
#   for_each = aws_subnet.demo_private_subnets
#   ami = data.aws_ami.demo_web_app_ubuntu_ami.id
#   instance_type = "t2.micro"
#   subnet_id = each.value.id
#   key_name = data.aws_key_pair.demo_key_pair.key_name 
#   security_groups = [aws_security_group.demo_private_app_sg.id]
#   user_data = file(user_data_app.tftpl)

#   tags = {
#     Name = "Private App server"
#   }
# }

resource "aws_lb" "demo_external_lb" {
  name = "${var.names.project_title}-external-load-balancer"
  load_balancer_type = "application"
  security_groups = var.external_lb_sg
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "demo_external_lb_target_group" {
  name = "${var.names.project_title}-external-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_name
  ip_address_type = "ipv4"

  health_check {
    path = "/"
    protocol = "HTTP"
    healthy_threshold = 5 # The number of consecutive health checks successes required before considering an unhealthy target healthy.
    unhealthy_threshold = 2 # The number of consecutive health check failures required before considering a target unhealthy.
    timeout = 5 # The amount of time, in seconds, during which no response means a failed health check.
    interval = 30 # The approximate amount of time between health checks of an individual target
    matcher = 200 # The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, "200,202") or a range of values (for example, "200-299").
  }   
}

# resource "aws_lb_target_group_attachment" "demo_external_lb_tg_attachment" {
#   target_group_arn = aws_lb_target_group.demo_external_lb_target_group.arn
#   for_each = aws_instance.demo_web_app_instances
#   target_id = each.value.id # provide ids of web app instances to be attached to internet facing load balancer
# }

resource "aws_lb_listener" "demo_external_lb_listener" {
  load_balancer_arn = aws_lb.demo_external_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.demo_external_lb_target_group.arn
  }
}

resource "aws_iam_policy" "demo_ec2_all_policy" {
  name        = "ec2-policy01"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("ec2fullaccess,json")

  tags = {
    tag-key = "${var.names.project_title}-ec2-full-access-permission"
  }
}

resource "aws_iam_policy" "demo_s3_read_only_policy" {
  name        = "${var.names.project_title}-s3-read-only-policy"
  description = "s3 read only permission"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("s3readonly.json")

  tags = {
    tag-key = "${var.names.project_title}-s3-read-only-permission"
  }
}

resource "aws_iam_policy" "demo_ssmmanager_policy" {
  name        = "${var.names.project_title}-ssmmanager-policy"
  description = "SSM Manager permission"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("ssmmanagerpolicy.json")

  tags = {
    tag-key = "${var.names.project_title}-ssmmanager-policy"
  }
}

resource "aws_iam_role" "demo_ec2_role" {
  name = "demo_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.names.project_title}-ec2-role"
  }
}

resource "aws_iam_policy_attachment" "attach_ec2_all_policy" {
  name       = "es2-assume-role-attachment"
  roles      = [aws_iam_role.demo_ec2_role.name]
  policy_arn = aws_iam_policy.demo_ec2_all_policy.arn
}

resource "aws_iam_policy_attachment" "attach_s3_read_only_policy" {
  name       = "es2-assume-role-attachment"
  roles      = [aws_iam_role.demo_ec2_role.name]
  policy_arn = aws_iam_policy.demo_s3_read_only_policy.arn
}

resource "aws_iam_policy_attachment" "attach_ssmmanager_policy" {
  name       = "es2-assume-role-attachment"
  roles      = [aws_iam_role.demo_ec2_role.name]
  policy_arn = aws_iam_policy.demo_ssmmanager_policy.arn
}

resource "aws_iam_instance_profile" "demo-iam-web-instance-profile" {
  name = "${var.names.project_title}-${var.names.frontend_title}-instance-profile"
  role = aws_iam_role.demo_ec2_role.name
}

resource "aws_launch_template" "demo_web_app_launch_tpl" {
  name = "${var.names.project_title}-${var.names.frontend_title}-ltpl"
  image_id =data.aws_ami.demo_web_app_ubuntu_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = var.web_tier_sg
  key_name = data.aws_key_pair.demo_key_pair.key_name
  # iam_instance_profile {
  #   arn = ""
  # }
  iam_instance_profile {
    name = aws_iam_instance_profile.demo-iam-web-instance-profile.name
  }

  tags = {
    Name = "${var.names.project_title}-${var.names.frontend_title}-instance-launch-template"
  }

  # Use tag_specification to name instances dircectly at launch if autoscaling group is not used.
  # tag_specifications {
  #   resource_type = "instance"
  #   tags = {
  #     Name = "${var.names.project_title}-${var.names.frontend_title}-instance"
  #   }
  # }

   user_data = filebase64("user_data_web.tpl")
}

resource "aws_autoscaling_group" "demo_web_app_auto_scaling_group" {
  name = "${var.names.project_title}-${var.names.frontend_title}-ag"
  # availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  
  launch_template {
    id = aws_launch_template.demo_web_app_launch_tpl.id
  }

  vpc_zone_identifier = var.public_subnets

  tag {
    key = "Name"
    value = "${var.names.project_title}-${var.names.frontend_title}-server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "web_app_autoscaling_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.demo_web_app_auto_scaling_group.id
  lb_target_group_arn = aws_lb_target_group.demo_external_lb_target_group.arn
}

resource "aws_lb" "demo_internal_lb" {
  name = "${var.names.project_title}-internal-load-balancer"
  load_balancer_type = "application"
  security_groups = var.internal_lb_sg
  internal = true 
  subnets = var.private_subnets
}

resource "aws_lb_target_group" "demo_internal_lb_target_group" {
  name = "${var.names.project_title}-internal-lb-target-group"
  port = 4000
  protocol = "HTTP"
  vpc_id = var.vpc_name
  ip_address_type = "ipv4"
}

# resource "aws_lb_target_group_attachment" "demo_internal_lb_tg_attachment" {
#   target_group_arn = aws_lb_target_group.demo_internal_lb_target_group.arn
#   for_each = aws_instance.demo_web_app_instances
#   target_id = each.value.id # Provide ids of app servers to be attached to internal load balancer
# }

resource "aws_lb_listener" "demo_internal_lb_listener" {
  load_balancer_arn = aws_lb.demo_internal_lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.demo_internal_lb_target_group.arn
  }
}

resource "aws_launch_template" "demo_private_app_launch_tpl" {
  name = "${var.names.project_title}-${var.names.backend_title}-ltpl"
  image_id = data.aws_ami.demo_web_app_ubuntu_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = var.app_tier_sg
  key_name = data.aws_key_pair.demo_key_pair.key_name
  # iam_instance_profile {
  #   arn = ""
  # }

  iam_instance_profile {
    name = aws_iam_instance_profile.demo-iam-web-instance-profile.name
  }

  tags = {
    Name = "${var.names.project_title}-${var.names.backend_title}-launch-template"
  }

  # Use tag_specification to name instances dircectly at launch if autoscaling group is not used.
  # tag_specifications {
  #   resource_type = "instance"
  #   tags = {
  #     Name = "${var.names.project_title}-${var.names.backend_title}-instance"
  #   }
  # }

  user_data = filebase64("user_data_app.tpl")
}

resource "aws_autoscaling_group" "demo_private_app_auto_scaling_group" {
  name = "${var.names.project_title}-${var.names.backend_title}-ag"
  # availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  
  launch_template {
    id = aws_launch_template.demo_private_app_launch_tpl.id
  }

  vpc_zone_identifier = var.private_subnets

  tag {
    key = "Name"
    value = "${var.names.project_title}-${var.names.backend_title}-server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "private_app_autoscaling_group_attachment" {
  autoscaling_group_name = aws_autoscaling_group.demo_private_app_auto_scaling_group.id
  lb_target_group_arn = aws_lb_target_group.demo_internal_lb_target_group.arn
}