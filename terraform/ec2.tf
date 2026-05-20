locals {
  public_user_data = <<-EOF
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y httpd
    systemctl enable --now httpd
    echo "<h1>Day 7 Public EC2 - $(hostname -f)</h1>" > /var/www/html/index.html
    EOF

  private_user_data = <<-EOF
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y httpd
    systemctl enable --now httpd
    echo "<h1>Day 7 Private EC2 - $(hostname -f)</h1>" > /var/www/html/index.html
    # Private instance: listen on 8080 for connectivity test from bastion
    echo "Listen 8080" >> /etc/httpd/conf/httpd.conf
    echo "<h1>Private app on 8080</h1>" > /var/www/html/index8080.html
    systemctl restart httpd
    EOF
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.public_ec2.id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true
  user_data                   = local.public_user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${local.name_prefix}-public-ec2"
    Tier = "public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_ec2.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  user_data              = local.private_user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${local.name_prefix}-private-ec2"
    Tier = "private"
  }
}
