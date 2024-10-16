## Create API GAteway
resource "aws_apigatewayv2_api" "http_api" {
  name          = local.apigw_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

#create deployment
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = aws_apigatewayv2_api.http_api.id

  depends_on = [
    aws_apigatewayv2_route.get_product_route,
    aws_apigatewayv2_integration.get_product_integration,
    aws_apigatewayv2_integration.list_products_integration,
    aws_apigatewayv2_route.list_products_route
  ]
}

# Create deployment stages
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id        = aws_apigatewayv2_api.http_api.id
  name          = var.env
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
  # auto_deploy   = true
}

# resource "aws_apigatewayv2_stage" "default_stage" {
#   api_id      = aws_apigatewayv2_api.http_api.id
#   name        = "$default"
#   auto_deploy = true
# }

# Allow lambda to be invoked by API
resource "aws_lambda_permission" "apigw_lambda_list_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products_fn.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_lambda_get_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product_fn.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

## Create integrations
resource "aws_apigatewayv2_integration" "list_products_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_products_fn.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_product_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_product_fn.invoke_arn
  payload_format_version = "2.0"
}


### ROUTES!!



resource "aws_apigatewayv2_route" "list_products_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /products"

  target = "integrations/${aws_apigatewayv2_integration.list_products_integration.id}"
}
resource "aws_apigatewayv2_route" "list_products_options_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "OPTIONS /products"

  target = "integrations/${aws_apigatewayv2_integration.list_products_integration.id}"
}


resource "aws_apigatewayv2_route" "get_product_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /product"

  target = "integrations/${aws_apigatewayv2_integration.get_product_integration.id}"
}
resource "aws_apigatewayv2_route" "get_product_options_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "OPTIONS /product"

  target = "integrations/${aws_apigatewayv2_integration.get_product_integration.id}"
}