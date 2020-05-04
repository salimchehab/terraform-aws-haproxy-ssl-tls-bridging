# ----------------------------------------------------------------------------------------------------------------------
# Key pairs for EC2 instances: jumphost, client, and backends
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_key_pair" "ec2-haproxy" {
  key_name   = "ec2-haproxy"
  public_key = file("./ssh_keys/ec2-haproxy.key.pub")
}

resource "aws_key_pair" "ec2-jumphost" {
  key_name   = "ec2-jumphost"
  public_key = file("./ssh_keys/ec2-jumphost.key.pub")
}

resource "aws_key_pair" "ec2-backends" {
  key_name   = "ec2-backends"
  public_key = file("./ssh_keys/ec2-backends.key.pub")
}

resource "aws_key_pair" "ec2-clients" {
  key_name   = "ec2-clients"
  public_key = file("./ssh_keys/ec2-clients.key.pub")
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2 HAProxy in public subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "haproxy" {
  ami                         = local.ami_id
  associate_public_ip_address = true
  instance_type               = "t2.large"
  key_name                    = aws_key_pair.ec2-haproxy.key_name
  vpc_security_group_ids      = [
    aws_security_group.haproxy.id,
  ]
  subnet_id                   = local.subnet_id_default_eu_central_1a

  user_data  = file("./install_haproxy.sh")
  # copy generated generated haproxy.cfg file to /etc/haproxy/haproxy.cfg
  provisioner "file" {
    source      = "./haproxy.cfg"
    destination = "/etc/haproxy/haproxy.cfg"
  }
  tags       = {
    Name      = "HAProxy"
    Env       = "Sandbox"
    OS        = "Ubuntu"
    Terraform = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2 jumphost in public subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "jumphost" {
  ami                         = local.ami_id
  associate_public_ip_address = true
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.ec2-jumphost.key_name
  vpc_security_group_ids      = [
    aws_security_group.jumphost.id,
  ]
  subnet_id                   = local.subnet_id_default_eu_central_1a

  tags = {
    Name      = "jumphost"
    Env       = "Sandbox"
    OS        = "Ubuntu"
    Terraform = true
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2 backends in private subnet for backends
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "backend-1" {
  ami                         = local.ami_id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.ec2-backends.key_name
  vpc_security_group_ids      = [
    aws_security_group.backend.id,
  ]
  subnet_id                   = local.subnet_id_default_eu_central_1b
  associate_public_ip_address = false

  user_data = file("./install_flask.sh")

  tags = {
    Name      = "backend-1"
    Env       = "Sandbox"
    OS        = "Ubuntu"
    Terraform = true
  }
}

resource "aws_instance" "backend-2" {
  ami                         = local.ami_id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.ec2-backends.key_name
  vpc_security_group_ids      = [
    aws_security_group.backend.id,
  ]
  subnet_id                   = local.subnet_id_default_eu_central_1b
  associate_public_ip_address = false

  user_data = file("./install_flask.sh")

  tags       = {
    Name      = "backend-2"
    Env       = "Sandbox"
    OS        = "Ubuntu"
    Terraform = true
  }
  # depends on NAT-Gateway internet access
  depends_on = [
    aws_route_table.nat_gw_1]
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2 clients in private subnet for clients
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "client-1" {
  ami                         = local.ami_id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.ec2-clients.key_name
  vpc_security_group_ids      = [
    aws_security_group.client.id,
  ]
  subnet_id                   = local.subnet_id_default_eu_central_1c
  associate_public_ip_address = false

  tags = {
    Name      = "client-1"
    Env       = "Sandbox"
    OS        = "Ubuntu"
    Terraform = true
  }
}
