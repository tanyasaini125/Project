## S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "dishant-connected-bucket"

  tags = {
    Name = "MyS3Bucket"
  }
}

## Block public access OFF
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.my_bucket]
}

## Enable ACLs: set ownership to ObjectWriter
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

## Bucket policy for public read access
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
depends_on = [
 aws_s3_bucket.my_bucket,
aws_s3_bucket_public_access_block.example]
}

## IAM Role for EC2
resource "aws_iam_role" "s3_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

## IAM Policy to access S3
resource "aws_iam_role_policy" "s3_policy" {
  name = "ec2_s3_policy"
  role = aws_iam_role.s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

## Instance profile for EC2
resource "aws_iam_instance_profile" "s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.s3_role.name
}
