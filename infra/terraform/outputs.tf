output "api_gateway_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "alb_url" {
  value = "http://${aws_route53_record.ecs_alb_record.fqdn}"
}


#https://${}.execute-api.${var.aws_region}.amazonaws.com/dev/items