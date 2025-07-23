terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1" 
  profile = "Developer2-765732380112" 
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}


# DATA SOURCE (Auth)

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


# VPC and Network


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/21"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "igw" }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "subnet-public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags                    = { Name = "subnet-public-1c" }
}

resource "aws_subnet" "app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "subnet-app-1a" }
}

resource "aws_subnet" "app_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1c"
  tags              = { Name = "subnet-app-1c" }
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

resource "aws_eip" "nat_1a" {
  tags = { Name = "eip-nat-1a" }
}

resource "aws_eip" "nat_1c" {
  tags = { Name = "eip-nat-1c" }
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id
  tags          = { Name = "natgw-1a" }
}

resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.public_1c.id
  tags          = { Name = "natgw-1c" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "rt-public" }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = { Name = "rt-private" }
}

resource "aws_route_table_association" "app_1a" {
  subnet_id      = aws_subnet.app_1a.id
  route_table_id = aws_route_table.private.id
}

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

# RDS Configuration

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
    security_groups = [aws_security_group.bastion_sg.id, module.eks.node_security_group_id] #TODO: Colocar o SG do EKS aqui
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


# EKS CLUSTER && NODES

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = "flask-cluster"
  cluster_version = "1.33"

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.app_1a.id, aws_subnet.app_1c.id]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = false

  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::765732380112:role/EKSRole"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 3
      max_size       = 3
      min_size       = 2

      create_iam_role = false
      iam_role_arn    = "arn:aws:iam::765732380112:role/EKSNodeGroupRole"
      

      tags = {
        Name  = "eks-nodegroup"
        AMBIENTE  = "DEV"
        RESPONSAVEL = "arthur.giovanini@inmetrics.com.br"
        CENTRODECUSTO = "ADMPLATDIGITAL"
        SCHEDULE = "online"
      }
    }
    
  }

  tags = {
    Name  = "eks"
    AMBIENTE  = "DEV"
    RESPONSAVEL = "arthur.giovanini@inmetrics.com.br"
    CENTRODECUSTO = "ADMPLATDIGITAL"
    SCHEDULE = "online"
  }
}

resource "aws_eks_access_entry" "cluster_access" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = "arn:aws:iam::765732380112:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Developer2_84263f1c06dd171d"
}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.cluster_access.principal_arn

  access_scope {
    type       = "cluster"
  }
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

# Setting up the Kubernetes Files

#Creates the Env Vars for the Flask App
resource "local_file" "db_secret_yaml" {
  filename = "${path.module}/k8s/db-secret.yaml"

  content = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: db-secret
      namespace: default
    type: Opaque
    stringData:
      DB_HOST: "${aws_db_instance.rds.address}"
      DB_USER: "ArthurMilani"
      DB_PASSWORD: "pacote321"
  YAML

  depends_on = [aws_db_instance.rds]
}

# Creates the Flask Deployment
resource "kubectl_manifest" "flask_deployment" {
  yaml_body = file("${path.module}/k8s/flask-app-deployment.yaml")

  depends_on = [
    module.eks,
    kubectl_manifest.db_secret
  ]
}

resource "kubectl_manifest" "clients_service" {
  yaml_body = file("${path.module}/k8s/clients-service.yaml")
  # depends_on = [kubectl_manifest.flask_deployment]
}

resource "kubectl_manifest" "products_service" {
  yaml_body = file("${path.module}/k8s/products-service.yaml")
  # depends_on = [kubectl_manifest.flask_deployment]
}

resource "kubectl_manifest" "inventory_service" {
  yaml_body = file("${path.module}/k8s/inventory-service.yaml")
  # depends_on = [kubectl_manifest.flask_deployment]
}

resource "kubectl_manifest" "users_service" {
  yaml_body = file("${path.module}/k8s/users-service.yaml")
  # depends_on = [kubectl_manifest.flask_deployment]
}

resource "kubectl_manifest" "db_secret" {
  yaml_body = local_file.db_secret_yaml.content
  depends_on = [local_file.db_secret_yaml]
}



# OUTPUTS

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}