terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.62.0"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "us-west-1"
  profile = "my-profile"
}
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "linkedin-app"  # Ensure this bucket name is unique
  tags = {
    Name        = "Frontend Bucket"
    Environment = "Production"
  }
}
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.frontend_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_ownership_controls" "frontend_bucket_acl_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket                   = aws_s3_bucket.frontend_bucket.id
  block_public_acls        = false
  block_public_policy      = false
  ignore_public_acls       = false
  restrict_public_buckets  = false
}
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json

  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket_public_access]
}
data "aws_iam_policy_document" "allow_public_access" {
  statement {
    sid       = "AllowPublicReadAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
resource "aws_s3_object" "frontend_files" {
  for_each = fileset("${path.module}/frontend", "**/*")

  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = each.value
  source       = "${path.module}/frontend/${each.value}"
  content_type = lookup(local.content_type_map, regex(".*\\.(\\w+)$", each.value)[0], "application/octet-stream")
}
locals {
  content_type_map = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
  }
}
output "frontend_website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
