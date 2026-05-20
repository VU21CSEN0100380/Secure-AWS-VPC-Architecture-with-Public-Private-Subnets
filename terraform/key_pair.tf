resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name = var.key_name
  }
}

resource "local_file" "private_key" {
  content              = tls_private_key.ssh.private_key_pem
  filename             = "${path.module}/${var.save_private_key_path}"
  file_permission      = "0600"
  directory_permission = "0700"
}
