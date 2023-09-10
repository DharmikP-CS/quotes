locals {
  binary_path= "${path.module}/dist/bootstrap"
  src_path= "${path.module}/src/main.go"  
  archive_path= "${path.module}/dist/executable.zip"
  binary_name= "bootstrap"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.16.1"
    }
  }
  backend "s3" {
    bucket = "iaac-dharmik"
    key    = "quotes/terraform/state"
    region = "ap-south-1"
  }
}

provider "aws" {
  region  = "ap-south-1"
}

resource "null_resource" "function_binary" {
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.binary_path} ${local.src_path}"
  }
}

data "archive_file" "lambda_quotes" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}

resource "aws_lambda_function" "quotes" {
  function_name = "quotes"

  runtime = "provided.al2"
  handler = local.binary_name

  filename = local.archive_path
  source_code_hash = data.archive_file.lambda_quotes.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function_url" "quotes" {
  function_name      = aws_lambda_function.quotes.function_name
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "quotes" {
  name = "/aws/lambda/${aws_lambda_function.quotes.function_name}"

  retention_in_days = 1
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
