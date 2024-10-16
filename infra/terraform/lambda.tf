### LAmbda permissions

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:Query",
        "dynamodb:GetItem",
        "dynamodb:Scan"
      ]
      Effect   = "Allow"
      Resource = aws_dynamodb_table.products.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
    }, ]
  })
}
## Create all the zip files for Lambdas and layers

data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/layer"
  output_path = "${path.module}/lambda_layer.zip"
}

data "archive_file" "list_products_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/listProducts/"
  output_path = "${path.module}/listProducts.zip"
}

data "archive_file" "get_product_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/getProduct/"
  output_path = "${path.module}/getProduct.zip"
}

### Create Lambda layer with node dependencies for AWS SDK
resource "aws_lambda_layer_version" "node_modules_layer" {
  layer_name          = "node-modules-layer"
  compatible_runtimes = ["nodejs14.x"]
  filename            = data.archive_file.lambda_layer_zip.output_path
  source_code_hash    = data.archive_file.lambda_layer_zip.output_base64sha256
}


resource "aws_lambda_function" "list_products_fn" {
  filename      = data.archive_file.list_products_zip.output_path
  function_name = "list_products"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "listProducts.handler"
  runtime       = "nodejs18.x"
  layers        = [aws_lambda_layer_version.node_modules_layer.arn]

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.products.name
    }
  }
  source_code_hash = data.archive_file.list_products_zip.output_base64sha256
}

resource "aws_lambda_function" "get_product_fn" {
  filename      = data.archive_file.get_product_zip.output_path
  function_name = "get_product_details"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "getProduct.handler"
  runtime       = "nodejs18.x"
  layers        = [aws_lambda_layer_version.node_modules_layer.arn]

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.products.name
    }
  }
  source_code_hash = data.archive_file.get_product_zip.output_base64sha256
}