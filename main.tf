provider "aws" {
  region = "eu-west-2" 
}

resource "aws_instance" "ec2" {
    ami = "ami-0dfe0f1abee59c78d"
    instance_type = "t2.micro"
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "georgios-input-bucket-euw2-0705-unique1"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "georgios-output-bucket-euw2-0705-unique1"
  force_destroy = true
}

