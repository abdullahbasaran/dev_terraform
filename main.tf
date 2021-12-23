terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "172.31.16.0/21"

  azs             = ["eu-east-1a", "eu-east-1b"]
  public_subnets  = ["172.31.16.0/21", "172.31.24.0/21"]
  private_subnets = ["172.31.32.0/21", "172.31.40.0/21", "172.31.48.0/21", "172.31.56.0/21"]
  

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.vpc_name}-vpc"
    }
  )
}


# Create the public subnets
resource "aws_subnet" "public_web" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${var.zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${var.zones[count.index]}"
  }
}


# Create the private subnets
resource "aws_subnet" "private_application" {
  count = length(var.web_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${var.zones[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-web-subnet-${var.zones[count.index]}"
  }
}

resource "aws_subnet" "private_dbms" {
  count = length(var.web_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${var.zones[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-web-subnet-${var.zones[count.index]}"
  }
}



// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }

}

// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private_application_server" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}

resource "aws_instance" "ec2_private_dbms_server" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[1]
  vpc_security_group_ids      = [var.sg_priv_id]

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}