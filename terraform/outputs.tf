output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (if enabled)"
  value       = try(aws_nat_gateway.main[0].id, null)
}

output "public_ec2_public_ip" {
  description = "Public IP of the bastion/web instance (SSH entry point)"
  value       = aws_instance.public.public_ip
}

output "public_ec2_private_ip" {
  description = "Private IP of the public subnet EC2"
  value       = aws_instance.public.private_ip
}

output "private_ec2_private_ip" {
  description = "Private IP of the private subnet EC2"
  value       = aws_instance.private.private_ip
}

output "key_pair_name" {
  description = "AWS key pair name"
  value       = aws_key_pair.main.key_name
}

output "private_key_path" {
  description = "Path to generated SSH private key (local, gitignored)"
  value       = abspath("${path.module}/${var.save_private_key_path}")
}

output "ssh_public_instance" {
  description = "SSH command to reach the public instance"
  value       = "ssh -i \"${abspath("${path.module}/${var.save_private_key_path}")}\" ec2-user@${aws_instance.public.public_ip}"
}

output "ssh_private_via_bastion" {
  description = "SSH to private instance via public bastion (ProxyJump)"
  value       = "ssh -i \"${abspath("${path.module}/${var.save_private_key_path}")}\" -J ec2-user@${aws_instance.public.public_ip} ec2-user@${aws_instance.private.private_ip}"
}

output "iam_role_arn" {
  description = "IAM role ARN attached to EC2 instances"
  value       = aws_iam_role.ec2.arn
}
