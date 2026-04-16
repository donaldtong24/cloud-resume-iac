terraform {
  backend "s3" {
    bucket         = "donald-tong-terraform-bucket" # Create this bucket manually once
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Or your preferred region
}

# This creates your S3 bucket for the resume
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "donald-tong-cloud-resume-iac" # Change this!
}

# This makes it a website
resource "aws_s3_bucket_website_configuration" "resume_config" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# This tells terraform to take your local file and upload it to teh bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "index.html" # Make sure your file is named exactly this in your folder!
  content_type = "text/html"
  # THIS IS THE MISSING PIECE:
  etag = filemd5("index.html")
}
#this tells terraform to take your local styles.css file
resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "style.css"
  source       = "style.css" # Ensure this file exists in your project folder
  content_type = "text/css"
  # THIS IS THE MISSING PIECE:
  etag = filemd5("style.css")
}
# script.js
resource "aws_s3_object" "javascript" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "script.js"
  source       = "script.js"
  content_type = "text/javascript"

  # THIS IS THE MISSING PIECE:
  etag = filemd5("script.js")
}

# Set up for OAC and Cloudfront
# 1. Create the Security Guard (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-resume-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. The Cloudfront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

#bucket policy so that it only accepts from our cloudfront

resource "aws_s3_bucket_policy" "resume_policy" {
  bucket = aws_s3_bucket.resume_bucket.id
  policy = data.aws_iam_policy_document.resume_policy_doc.json
}

data "aws_iam_policy_document" "resume_policy_doc" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

#output block
output "cloudfront_url" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The public URL of your resume website"
}

# DynamoDb table
resource "aws_dynamodb_table" "cloud_resume_stats" {
  name         = "cloud-resume-stats-iac"
  billing_mode = "PAY_PER_REQUEST" # Cheapest for a resume project
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S" # S stands for String
  }
}

# This "seeds" the table with an initial count of 0
resource "aws_dynamodb_table_item" "init_item" {
  table_name = aws_dynamodb_table.cloud_resume_stats.name
  hash_key   = aws_dynamodb_table.cloud_resume_stats.hash_key

  item = <<ITEM
{
  "id": {"S": "visitors"},
  "count": {"N": "0"}
}
ITEM
}

# 1. The "Passport" itself (The Role)
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# 2. The "Visa" (The Policy) that allows talking to DynamoDB
resource "aws_iam_role_policy" "dynamodb_lambda_policy" {
  name = "dynamodb_lambda_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.cloud_resume_stats.arn
      },
    ]
  })
}
# Permission 1: Specific to the Function URL
resource "aws_lambda_permission" "allow_public_access" {
  statement_id           = "AllowExecutionFromPublicURL" # Unique ID 1
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.resume_lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# Permission 2: General Invoke Permission
resource "aws_lambda_permission" "allow_invoke_function" {
  statement_id  = "AllowExecutionFromGeneralInvoke" # Unique ID 2 (Changed from your error)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume_lambda.function_name
  principal     = "*"
}
# 1. Zip the Python file
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "lambda_function_iac.py"
  output_path = "${path.module}/lambda_function.zip"
}

# 2. Create the Lambda Function
resource "aws_lambda_function" "resume_lambda" {
  filename      = data.archive_file.zip_the_python_code.output_path
  function_name = "resume_counter_function"
  role          = aws_iam_role.iam_for_lambda.arn # This uses the "Passport" we made earlier
  handler       = "lambda_function_iac.lambda_handler" # Matches your file name and function name
  runtime       = "python3.12"

  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
}

# 3. Add a URL so we can test it directly (Function URL)
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.resume_lambda.function_name
  authorization_type = "NONE"


 # REMOVED CORS block here
}

# 4. Output the URL so you can click it!
output "lambda_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}

