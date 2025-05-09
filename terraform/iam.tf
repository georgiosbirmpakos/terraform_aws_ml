# ===============================
#  IAM Role + Policy for EC2 to Access S3
# ===============================
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "ec2_s3_access_policy"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*",
          aws_s3_bucket.output_bucket.arn,
          "${aws_s3_bucket.output_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_s3_role.name
}

# ===============================
#  S3 Bucket Policy for input bucket
# ===============================
resource "aws_s3_bucket_policy" "input_bucket_policy" {
  bucket = aws_s3_bucket.input_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowEC2RoleAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::886436959827:role/ec2_s3_access_role"
        }
        Action    = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource  = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*"
        ]
      },
      {
        Sid       = "AllowYourUserAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::886436959827:user/terraform"
        }
        Action    = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource  = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*"
        ]
      }
    ]
  })
}
