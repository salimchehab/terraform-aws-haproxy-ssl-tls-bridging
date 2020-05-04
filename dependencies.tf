# Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-0b418580298265d5c (64-bit x86)
data "aws_ami" "ubuntu-bionic-1804-amd64-server" {
  most_recent = true
  owners      = [
    "099720109477"
  ]
  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200112"
    ]
  }
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet" "default_eu-central-1a" {
  vpc_id            = data.aws_vpc.main.id
  availability_zone = "eu-central-1a"
}

data "aws_subnet" "default_eu-central-1b" {
  vpc_id            = data.aws_vpc.main.id
  availability_zone = "eu-central-1b"
}

data "aws_subnet" "default_eu-central-1c" {
  vpc_id            = data.aws_vpc.main.id
  availability_zone = "eu-central-1c"
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [
      local.vpc_id]
  }
}

locals {
  ami_id                          = data.aws_ami.ubuntu-bionic-1804-amd64-server.id
  vpc_id                          = data.aws_vpc.main.id
  internet_gateway_id             = data.aws_internet_gateway.default.id
  subnet_id_default_eu_central_1a = data.aws_subnet.default_eu-central-1a.id
  subnet_id_default_eu_central_1b = data.aws_subnet.default_eu-central-1b.id
  subnet_id_default_eu_central_1c = data.aws_subnet.default_eu-central-1c.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Generate HAProxy config from template cfg file
# ----------------------------------------------------------------------------------------------------------------------
data "template_file" "haproxy" {
  template = file("./templates/haproxy.cfg.tpl")

  vars = {
    stats_uri_port = var.stats_uri_port
    flask_port     = "5000"
    crt            = "/home/ubuntu/flask.local.app.pem"
    ca-file        = "/home/ubuntu/EC2CA.pem"
    maxconn        = "32"
    domain         = var.zone_name
    backend-1      = aws_instance.backend-1.tags.Name
    backend-2      = aws_instance.backend-2.tags.Name
  }
}

resource "null_resource" "update_haproxy_cfg" {
  triggers = {
    template = data.template_file.haproxy.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.haproxy.rendered}' > haproxy.cfg"
  }
}
