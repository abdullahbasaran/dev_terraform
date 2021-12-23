variable "aws_region" {
	default = "us-east-1"
}

variable "vpc_cidr" {
	default = "172.31.16.0/21"
}

variable "subnets_cidr" {
	default = ["172.31.16.0/24", "172.31.24.0/24", "172.31.32.0/24", "172.31.40.0/24", "172.31.48.0/24", "172.31.56.0/24"]
}

variable "azs" {
	default = ["us-east-1a", "us-east-1b"]
}

variable "webservers_ami" {
  default = "ami-0ed9277fb7eb570c9"
}

variable "instance_type" {
  default = "t2.micro"
}