##S3 Bucket

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

# Enable ACLs: set ownership to ObjectWriter
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}


## IAM role for ec2

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

##IAM policy

resource "aws_iam_role_policy" "s3_policy" {
  name = "ec2_s3_policy"
  role = aws_iam_role.s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
  "Effect": "Allow",
  "Action": [
    "s3:*"
  ],
  Resource: "*"

      }
    ]
  })
}

##IAM instance profile

resource "aws_iam_instance_profile" "s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.s3_role.name
}
