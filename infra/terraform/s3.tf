### LAmbda permissions

resource "aws_iam_role" "lambda_exec_role_s3_load" {
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

resource "aws_iam_role_policy" "lambda_exec_policy_s3_load" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:*",
        "s3:*"
      ]
      Effect   = "Allow"
      Resource = "*"
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

data "archive_file" "lambda_s3upload" {
  type        = "zip"
  source_dir  = "${path.module}/functions/dynamoLoad"
  output_path = "${path.module}/dynamo_load.zip"
}

resource "aws_lambda_function" "s3_upload_function" {
  filename      = data.archive_file.lambda_s3upload.output_path
  function_name = "batch_load"
  role          = aws_iam_role.lambda_exec_role_s3_load.arn
  handler       = "dynamo.handler"
  runtime       = "python"
  source_code_hash = data.archive_file.list_products_zip.output_base64sha256
}




resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}


resource "aws_s3_bucket" "bucket" {
  bucket = "your-bucket-name"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_upload_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "products/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}