locals {
  private_ips_cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Security group for HAProxy
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "haproxy" {
  name        = "haproxy"
  description = "HAProxy - allow traffic from testing node and clients."
  vpc_id      = local.vpc_id

  tags = {
    Name      = "haproxy"
    Terraform = true
  }

  ingress {
    description = "Allow SSH from jumphost and testing node."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.testing_node_ip,
      "${aws_instance.jumphost.private_ip}/32",
    ]
  }

  ingress {
    description = "Allow all incoming HTTP from clients in private subnets."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_ips_cidr_blocks
  }

  ingress {
    description = "Allow all incoming HTTPS from clients in private subnets."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.private_ips_cidr_blocks
  }

  ingress {
    description = "Allow stats page from testing node."
    from_port   = 8404
    to_port     = 8404
    protocol    = "tcp"
    cidr_blocks = [
      var.testing_node_ip,
    ]
  }

  egress {
    description = "Allow all outgoing traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Security group for jumphost
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "jumphost" {
  name        = "jumphost"
  description = "jumphost - allow ssh from testing node."
  vpc_id      = local.vpc_id

  tags = {
    Name      = "jumphost"
    Terraform = true
  }

  ingress {
    description = "Allow SSH from testing node IP."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.testing_node_ip,
    ]
  }

  egress {
    description = "Allow all internal outgoing traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.private_ips_cidr_blocks
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Security group for backends
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "backend" {
  name        = "backend"
  description = "Allow backend nodes to connect to the HAProxy server."
  vpc_id      = local.vpc_id

  tags = {
    Name      = "backend"
    Terraform = true
  }

  ingress {
    description = "Allow SSH from jumphost."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.jumphost.private_ip}/32"
    ]
  }

  ingress {
    description = "Allow Flask app port from HAProxy."
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.haproxy.private_ip}/32"
    ]
  }

  egress {
    description = "Allow all outgoing traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Security group for clients
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "client" {
  name        = "client"
  description = "Allow backend nodes to connect to the HAProxy server."
  vpc_id      = local.vpc_id

  tags = {
    Name      = "client"
    Terraform = true
  }

  ingress {
    description = "Allow SSH from jumphost."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.jumphost.private_ip}/32"
    ]
  }

  egress {
    description = "Allow outgoing HTTP traffic to HAProxy."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.haproxy.private_ip}/32",
    ]
  }

  egress {
    description = "Allow outgoing HTTPS traffic to HAProxy."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.haproxy.private_ip}/32",
    ]
  }
}
