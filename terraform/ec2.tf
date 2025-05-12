resource "aws_instance" "ec2" {
  ami                         = "ami-0a94c8e4ca2674d5a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  monitoring                  = false

  user_data = file("${path.module}/ec2_user_data.sh")

  depends_on = [aws_iam_instance_profile.ec2_profile]

  tags = {
    Name = "Georgios EC2"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow all outbound"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
