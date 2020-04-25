resource "aws_route53_zone" "main" {
  name = var.zone_name

  vpc {
    vpc_id = local.vpc_id
  }

  tags = {
    "Name"        = var.zone_name
    "Environment" = "Sandbox"
    "Terraform"   = true
  }
}

resource "aws_route53_record" "client-1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.client-1.tags.Name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_instance.client-1.private_ip]
}

resource "aws_route53_record" "backend-1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.backend-1.tags.Name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_instance.backend-1.private_ip]
}

resource "aws_route53_record" "backend-2" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.backend-2.tags.Name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_instance.backend-2.private_ip]
}

resource "aws_route53_record" "jumphost" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.jumphost.tags.Name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_instance.jumphost.private_ip]
}

resource "aws_route53_record" "haproxy" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${aws_instance.haproxy.tags.Name}.${var.zone_name}"
  type    = "A"
  ttl     = "300"
  records = [
    aws_instance.haproxy.private_ip]
}

resource "aws_route53_record" "flask" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "flask.${var.zone_name}"
  type    = "CNAME"
  ttl     = "5"
  records = [
    aws_route53_record.haproxy.name]
}
