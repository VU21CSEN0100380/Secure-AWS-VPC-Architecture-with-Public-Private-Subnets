variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment label used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Prefix for resource naming"
  type        = string
  default     = "secure-vpc-day7"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for public and private instances"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the public (bastion) instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Name of the EC2 key pair in AWS"
  type        = string
  default     = "secure-vpc-day7-key"
}

variable "save_private_key_path" {
  description = "Local path where the generated private key PEM is written (gitignored)"
  type        = string
  default     = "keys/secure-vpc-day7-key.pem"
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway for private subnet outbound internet (incurs hourly cost)"
  type        = bool
  default     = true
}
