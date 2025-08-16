terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "aws_vpc" "this" {
  cidr_block = "176.0.0.0/16"

  tags = {
    Name = "ManageContactApp_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.this.id
  cidr_block = "176.0.1.0/24"
  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "ManageContactApp_PublicSubnet"
  }
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ecs_instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ecs_sg.id]
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "manage-contact-app-${random_id.suffix.hex}"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "manage-contact-app-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family = "manage-contact-app-task"
  requires_compatibilities = ["EC2"]
  network_mode = "brige"
  cpu = "256"
  memory = "512"
  container_definitions = jsondecode([
    {
      "name": "mc_app",
      "image": var.image_name,
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 80
        }
      ],
      "dependsOn": [
        {
            "containerName": "mc_db",
            "condition": "HEALTHY"
        }
      ],
      "environment": [
        { name: "DB_HOST", value: "mc_db"},
        { name: "POSTGRES_USER", value: var.postgres_user },
        { name: "POSTGRES_PASSWORD", value: var.postgres_password },
        { name: "POSTGRES_DB", value: var.postgres_db }
      ]
    },
    {
      "name": "mc_db",
      "image": "postgres:15",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5432,
          "hostPort": 5432
        }
      ]
      "environment": [
        { name: "POSTGRES_USER", value: var.postgres_user },
        { name: "POSTGRES_PASSWORD", value: var.postgres_password },
        { name: "POSTGRES_DB", value: var.postgres_db }
      ]
    }
  ])
}