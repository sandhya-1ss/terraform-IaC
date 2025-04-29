# main.tf
provider "aws" {
  region = "us-east-1"
}

# Variables
variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "terraform"
}

variable "bucket_name" {
  default = "my.lambda.v3.bucket.1"
}
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami             = "ami-0e449927258d45bc4"
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = ["default"]

  tags = {
    Name = "MyEC2Instance"
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  index_document {
    suffix = "index.html"  # Correct block definition for index document
  }
}


# Lambda IAM Role for S3 access
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_s3_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}


data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Attach Policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function
resource "aws_lambda_function" "example" {
  function_name = "S3EventTriggerLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  # Zip the Python Lambda function (will be explained later)
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# S3 event trigger for Lambda function
resource "aws_s3_bucket_notification" "example" {
  bucket = aws_s3_bucket.example.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.example.arn
    events              = ["s3:ObjectCreated:*"]
}
}

# Grant S3 permission to invoke Lambda function
resource "aws_lambda_permission" "allow_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.example.arn
}
