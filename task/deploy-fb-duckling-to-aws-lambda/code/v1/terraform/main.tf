terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test-lambda-image" {
  function_name = "test-lambda-image"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  package_type  = "Image"
  image_uri     = "354292498874.dkr.ecr.ap-southeast-1.amazonaws.com/aws-lambda-image-python:1.0.7"
}

resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.test-lambda-image.function_name
  authorization_type = "NONE"
}
