terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Busca a AMI Ubuntu 22.04 LTS mais recente automaticamente
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Referencia a VPC existente
data "aws_vpc" "existing" {
  id = var.vpc_id
}

# Referencia a Subnet existente
data "aws_subnet" "existing" {
  id = var.subnet_id
}

# Referencia o Security Group existente
data "aws_security_group" "existing" {
  id = var.security_group_id
}

# Referencia o Key Pair existente
data "aws_key_pair" "existing" {
  key_name = var.key_name
}



# EC2 - unico recurso criado
resource "aws_instance" "lab_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.existing.id
  vpc_security_group_ids = [data.aws_security_group.existing.id]
  key_name               = data.aws_key_pair.existing.key_name

  tags = { Name = "lab-ec2" }
}