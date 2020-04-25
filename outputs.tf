output "ec2-haproxy-id" {
  description = "EC2 instance id of HAProxy."
  value       = aws_instance.haproxy.id
}

output "ec2-jumphost-id" {
  description = "EC2 instance id of jumphost."
  value       = aws_instance.jumphost.id
}

output "ec2-backend-1-id" {
  description = "EC2 instance id of backend-1."
  value       = aws_instance.backend-1.id
}

output "ec2-backend-2-id" {
  description = "EC2 instance id of backend-2."
  value       = aws_instance.backend-2.id
}

output "ec2-client-1-id" {
  description = "EC2 instance id of client-1."
  value       = aws_instance.client-1.id
}

output "sg-haproxy-id" {
  description = "Security group id of HAProxy."
  value       = aws_security_group.haproxy.id
}

output "sg-jumphost-id" {
  description = "Security group id of jumphost."
  value       = aws_security_group.jumphost.id
}

output "sg-backend-id" {
  description = "Security group id of backends."
  value       = aws_security_group.backend.id
}

output "sg-client-id" {
  description = "Security group id of clients."
  value       = aws_security_group.client.id
}

output "ec2-haproxy-private-ip" {
  description = "Private ip of HAProxy."
  value       = aws_instance.haproxy.private_ip
}

output "ec2-jumphost-private-ip" {
  description = "Private ip of jumphost."
  value       = aws_instance.jumphost.private_ip
}

output "ec2-backend-1-private-ip" {
  description = "Private ip of backend-1."
  value       = aws_instance.backend-1.private_ip
}

output "ec2-backend-2-private-ip" {
  description = "Private ip of backend-2."
  value       = aws_instance.backend-2.private_ip
}

output "ec2-client-1-private-ip" {
  description = "Private ip of client-1."
  value       = aws_instance.client-1.private_ip
}

output "ec2-haproxy-public-ip" {
  description = "Public ip of HAProxy."
  value       = aws_instance.haproxy.public_ip
}

output "ec2-jumphost-public-ip" {
  description = "Public ip of jumphost."
  value       = aws_instance.jumphost.public_ip
}

output "nat-gw-1-public-ip" {
  description = "Public ip of NAT-Gateway-1."
  value       = aws_nat_gateway.nat_1.public_ip
}

output "zone_id" {
  description = "Route53 hosted zone id."
  value       = aws_route53_zone.main.zone_id
}
