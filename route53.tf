resource "aws_route53_zone" "hosted_zone" {
  name    = var.zone_name
  comment = "Hosted zone for ${var.zone_name}"
}

resource "aws_route53_record" "dns_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = var.zone_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.kops.public_ip]

  depends_on = [aws_instance.kops]
}