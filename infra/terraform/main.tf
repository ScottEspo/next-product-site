
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_route53_record" "ecs_alb_record" {
  zone_id = data.aws_route53_zones.sandbox_zone.ids[0]
  name    = "nextjs.${data.aws_route53_zones.sandbox_zone.ids[0]}"
  type    = "A"

  alias {
    name                   = aws_lb.ecs_alb.dns_name
    zone_id                = aws_lb.ecs_alb.zone_id
    evaluate_target_health = false
  }
}
