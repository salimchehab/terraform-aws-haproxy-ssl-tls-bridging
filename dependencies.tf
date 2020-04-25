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
