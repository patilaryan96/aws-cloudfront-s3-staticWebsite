resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = var.project_name
    Environment = var.environment
    Project     = "CloudFront S3 Static Website"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "${path.module}/website/index.html"
  etag   = filemd5("${path.module}/website/index.html")

  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket = aws_s3_bucket.website.id
  key    = "style.css"
  source = "${path.module}/website/style.css"
  etag   = filemd5("${path.module}/website/style.css")

  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.website.id
  key    = "script.js"
  source = "${path.module}/website/script.js"
  etag   = filemd5("${path.module}/website/script.js")

  content_type = "application/javascript"
}