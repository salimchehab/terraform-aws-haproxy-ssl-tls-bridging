resource "aws_eip" "nat_1" {
  tags = {
    Name        = "EIP-NAT-1"
    Application = "Elastic IP for NAT-Gateway-1"
    Terraform   = true
  }
}

# Nat-Gateway-1
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = local.subnet_id_default_eu_central_1a

  tags = {
    Name      = "NAT-Gateway-1"
    Terraform = true
  }
}

# allow internet access to backends through Nat-Gateway-1
resource "aws_route_table" "nat_gw_1" {
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name        = "Route-NAT-Gateway-1"
    Application = "Internet through Nat #1"
    Terraform   = true
  }
}

resource "aws_route_table_association" "app_1_subnet_to_nat_gw" {
  route_table_id = aws_route_table.nat_gw_1.id
  subnet_id      = local.subnet_id_default_eu_central_1b
}
