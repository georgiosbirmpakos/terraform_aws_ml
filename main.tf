provider "aws" {
  region = "eu-west-2"
}

# ===============================
#  S3 Buckets
# ===============================
resource "aws_s3_bucket" "input_bucket" {
  bucket        = "georgios-input-bucket-euw2-0705-unique1"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket        = "georgios-output-bucket-euw2-0705-unique1"
  force_destroy = true
}

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
          "arn:aws:s3:::georgios-input-bucket-euw2-0705-unique1",
          "arn:aws:s3:::georgios-input-bucket-euw2-0705-unique1/*",
          "arn:aws:s3:::georgios-output-bucket-euw2-0705-unique1",
          "arn:aws:s3:::georgios-output-bucket-euw2-0705-unique1/*"
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
#  EC2 Instance (manual SSH/script execution)
# ===============================
resource "aws_instance" "ec2" {
  ami                         = "ami-0dfe0f1abee59c78d"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "Georgios EC2"
  }
}
