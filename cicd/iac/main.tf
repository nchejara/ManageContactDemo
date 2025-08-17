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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.this.id
  cidr_block = "176.0.1.0/24"
  map_public_ip_on_launch  = true

  tags = {
    Name = "ManageContactApp_PublicSubnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Add only when access DB from outside, expose DB port not require for internal communication
  # ingress { 
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating IAM role
#############################
resource "aws_iam_role" "iam_instance_profile" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach AmazonEC2ContainerServiceforEC2Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.iam_instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Attach AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role_policy_attachment" "ecs_instance_ecr_policy" {
  role       = aws_iam_role.iam_instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.iam_instance_profile.name
}

### Key pair [optional]
resource "tls_private_key" "key_rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "iac_key" {
  key_name = "iac_key"
  public_key = tls_private_key.key_rsa.public_key_openssh
}

resource "local_file" "local_iac_key" {
  content = tls_private_key.key_rsa.private_key_pem
  filename = "${path.cwd}/iac_key.pem"
}

data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ecs_instance" {
  ami = data.aws_ami.amazon.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ecs_sg.id]
  key_name = "iac_key"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  # For base AWS AMI, You have to install docker, ecs-agent and launch ecs-agent container
  # Option #1
  # user_data = <<-EOF
  #             #!/bin/bash
  #             # Docker installation code
  #             echo "ECS_CLUSTER=manage-contact-app-cluster" >> /etc/ecs/ecs.config
  #             systemctl enable --now ecs
  #             EOF

  # Option #2
  #  provisioner "remote-exec" {
  #   inline = [
      # "sudo apt-get update -y",
      # "sudo apt-get install -y ca-certificates curl gnupg lsb-release",

      # # Add Docker’s official GPG key
      # "sudo mkdir -p /etc/apt/keyrings",
      # "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",

      # # Setup Docker repo
      # "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # # Install Docker
      # "sudo apt-get update -y",
      # "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",

      # # Enable Docker
      # "sudo systemctl enable docker",
      # "sudo systemctl start docker",
      # "sudo usermod -aG docker ubuntu",

      # "echo 'ECS_CLUSTER=my_cluster' | sudo tee -a /etc/ecs/ecs.config"

  #   ]
  # }

  # connection {
  #   type        = "ssh"
  #   user        = "ec2_user"
  #   private_key = file("./iac_key.pem")
  #   host        = self.public_ip
  # }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "manage-contact-app-${random_id.suffix.hex}"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "default"
}

# ECS Services
resource "aws_ecs_service" "mc_service" {
  name = "mc-service"
  cluster = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count = 1
  launch_type = "EC2"
  

}

resource "aws_ecs_task_definition" "my_task" {
  family = "manage-contact-app-task"
  requires_compatibilities = ["EC2"]
  network_mode = "bridge"
  cpu = "256"
  memory = "512"
  container_definitions = jsonencode([
    {
      "name": "mc_app",
      "image": var.image_name,
      "memory": 256,
      "cpu": 128,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "dependsOn": [
        {
            "containerName": "mc_db",
            "condition": "HEALTHY"
        }
      ],
      "links": ["mc_db"],
      "environment": [
        { name: "DB_HOST", value: "mc_db"},
        { name: "POSTGRES_USER", value: var.postgres_user },
        { name: "POSTGRES_PASSWORD", value: var.postgres_password },
        { name: "POSTGRES_DB", value: var.postgres_db }
      ]
    },
    {
      "name": "mc_db",
      "image": "postgres:latest",
      "memory": 256,
      "cpu": 128,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5432,
          "hostPort": 5432
        }
      ],
      "environment": [
        { name: "POSTGRES_USER", value: var.postgres_user },
        { name: "POSTGRES_PASSWORD", value: var.postgres_password },
        { name: "POSTGRES_DB", value: var.postgres_db }
      ],
      "healthCheck": {
        "command": [
            "CMD-SHELL",
            "pg_isready -U ${var.postgres_user} -d ${var.postgres_db}"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 10
        }
    }
  ])
}