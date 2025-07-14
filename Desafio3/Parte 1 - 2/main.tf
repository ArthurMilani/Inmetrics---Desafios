provider "aws" {
  region  = "us-east-1" 
  profile = "Developer2-765732380112" 
}

data "template_file" "db_host_file" {
  template = <<EOF
${aws_db_instance.rds.address}
EOF
}

#Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/21"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "vpc"
  }
}

#Create the Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "igw"
  }
}

#Create the Public Subnets

#Public A
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "subnet-public-1a"
  }
}

#Public C
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name  = "subnet-public-1c"
  }
}

#Create the Private Subnets

#Private App A
resource "aws_subnet" "app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name  = "subnet-app-1a"
  }
}

#Private App C
resource "aws_subnet" "app_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name  = "subnet-app-1c"
  }
}

#Private DB A
resource "aws_subnet" "db_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name  = "subnet-db-1a"
  }
}

#Private DB C
resource "aws_subnet" "db_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name  = "subnet-db-1c"
  }
}

# Elastic IPs

#Elastic for A
resource "aws_eip" "nat_1a" {
  tags = {
    Name  = "eip-nat-1a"
  }
}

#Elastic for C
resource "aws_eip" "nat_1c" {
  tags = {
    Name  = "eip-nat-1c"
  }
}

# NAT Gateways

# NAT Gateway in us-east-1a
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name  = "natgw-1a"
  }
}

# NAT Gateway in us-east-1c
resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.public_1c.id

  tags = {
    Name  = "natgw-1c"
  }
}

# Public Route Tables

# Public Route Table (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "rt-public"
  }
}

#Association: Public A -> Public Route Table
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

#Association: Public C -> Public Route Table
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables

# Private Route Table (0.0.0.0/0 -> NATGW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name  = "rt-private"
  }
}

#Association: Private App A -> Private Route Table
resource "aws_route_table_association" "app_1a" {
  subnet_id      = aws_subnet.app_1a.id
  route_table_id = aws_route_table.private.id
}

#Association: Private App C -> Private Route Table
resource "aws_route_table_association" "app_1c" {
  subnet_id      = aws_subnet.app_1c.id
  route_table_id = aws_route_table.private.id
}

#Association: Private DB A -> Private Route Table
resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.private.id
}

#Association: Private DB C -> Private Route Table
resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.private.id
}


# Setting the Bastion up

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Permitir acesso SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH acesso publico (temporario)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-bastion"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-020cba7c55df1f615" # Ubuntu 22.04 LTS (us-east-1)
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  key_name = "Flask"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  depends_on = [aws_db_instance.rds]

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-client

              echo "${replace(file("setup.sql"), "$", "\\$")}" > /tmp/init.sql

              mysql -h ${aws_db_instance.rds.address} -u ArthurMilani -p'pacote321' < /tmp/init.sql
EOF
)

  tags = {
    Name  = "bastion"
    AMBIENTE  = "DEV"
    RESPONSAVEL = "arthur.giovanini@inmetrics.com.br"
    SCHEDULE = "online"
  }
}

# =========================== PARTE 2 ==================================
#SG
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Permitir trafego do Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Trafego HTTP do ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description      = "Portas Flask especificas 5000 a 5003 do ALB"
    from_port        = 5000
    to_port          = 5003
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-app"
  }
}

# Launch Template for the Application Instances
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-template-"
  image_id      = "ami-020cba7c55df1f615" # Ubuntu 22.04 LTS (us-east-1)
  instance_type = "t3.micro"
  key_name      = "Flask"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3-pip
              sudo pip3 install flask --break-system-packages --ignore-installed

              cd /home/ubuntu
              sudo git clone -b Desafio03 https://github.com/ArthurMilani/Inmetrics---Desafios.git flask_app

              sudo pip3 install --break-system-packages --ignore-installed -r flask_app/requirements.txt

              echo "${data.template_file.db_host_file.rendered}" > /opt/db_host.txt

              cd flask_app/Standart
              sudo python3 starter.py

              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "app-instance"
      AMBIENTE  = "DEV"
      RESPONSAVEL = "arthur.giovanini@inmetrics.com.br"
      SCHEDULE = "online"
    }
  }

  tags = {
    Name  = "app-launch-template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "asg-app"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  vpc_zone_identifier       = [
    aws_subnet.app_1a.id,
    aws_subnet.app_1c.id
  ]
  launch_template {
  id      = aws_launch_template.app_lt.id
  version = "$Latest"
}
  health_check_type         = "EC2"
  force_delete              = true

  target_group_arns = [
    aws_lb_target_group.clients_tg.arn,
    aws_lb_target_group.products_tg.arn,
    aws_lb_target_group.inventory_tg.arn,
    aws_lb_target_group.users_tg.arn
  ]

  depends_on = [ 
    aws_nat_gateway.nat_1a,
    aws_nat_gateway.nat_1c,
    aws_route_table.private
   ]

  tag {
    key                 = "Name"
    value               = "asg-app-instance"
    propagate_at_launch = true
  }
}

# Target Group (TODO: Remover)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name  = "tg-app"
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  security_groups = [aws_security_group.bastion_sg.id] 

  tags = {
    Name  = "alb-app"
  }
}

# Listener for the Application Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found (Load Balancer Layer)"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "clients_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clients_tg.arn
  }

  condition {
    path_pattern {
      values = ["/clients*"]
    }
  }
}

resource "aws_lb_listener_rule" "products_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.products_tg.arn
  }

  condition {
    path_pattern {
      values = ["/products*"]
    }
  }
}

resource "aws_lb_listener_rule" "inventory_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.inventory_tg.arn
  }

  condition {
    path_pattern {
      values = ["/inventory*"]
    }
  }
}

resource "aws_lb_listener_rule" "users_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.users_tg.arn
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}


#Target Groups for Microservices
resource "aws_lb_target_group" "clients_tg" {
  name     = "clients-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/clients/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "5000"
  }
}

resource "aws_lb_target_group" "products_tg" {
  name     = "products-tg"
  port     = 5001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/products/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "5001"
  }
}

resource "aws_lb_target_group" "inventory_tg" {
  name     = "inventory-tg"
  port     = 5002
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/inventory/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "5002"
  }
}

resource "aws_lb_target_group" "users_tg" {
  name     = "users-tg"
  port     = 5003
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/user/health"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "5003"
  }
}


# Database Configuration

#Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.db_1a.id, aws_subnet.db_1c.id]

  tags = {
    Name = "rds-subnet-group"
  }
}

#Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Permitir acesso do app SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id, aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "rds" {
  identifier              = "rds-mysql-app"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  username                = "ArthurMilani"
  password                = "pacote321"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  multi_az                = true
  publicly_accessible     = false

  tags = {
    Name = "rds-mysql"
    AMBIENTE  = "DEV"
    RESPONSAVEL = "arthur.giovanini@inmetrics.com.br"
    SCHEDULE = "online"
  }
}


  
