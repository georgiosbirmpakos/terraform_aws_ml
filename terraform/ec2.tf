# ===============================
#  EC2 Instance
# ===============================
resource "aws_instance" "ec2" {
  ami                         = "ami-0a94c8e4ca2674d5a" # ubuntu
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  monitoring = true

  depends_on = [aws_iam_instance_profile.ec2_profile]


  user_data = file("${path.module}/ec2_user_data.sh")

  tags = {
    Name = "Georgios EC2"
  }
}
