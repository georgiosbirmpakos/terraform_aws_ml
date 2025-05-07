# ===============================
#  EC2 Instance
# ===============================
resource "aws_instance" "ec2" {
  ami                         = "ami-0a94c8e4ca2674d5a" # ubuntu
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true
  monitoring = true

user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3-pip unzip curl python3-venv

              # Install AWS CLI v2 (replaces outdated version)
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              export PATH=$PATH:/usr/local/bin

              # Create and activate virtual environment
              python3 -m venv venv
              source venv/bin/activate
              pip install boto3

              # Wait until at least one object exists in the input bucket
              echo "⏳ Waiting for input files to appear in S3..."
              while true; do
                count=$(aws s3 ls s3://georgios-input-bucket-euw2-0705-unique1/ | wc -l)
                if [ "$count" -gt 0 ]; then
                  echo "✅ Files found in input bucket."
                  break
                else
                  echo "⏳ Still waiting..."
                  sleep 5
                fi
              done

              # Create Python script
              cat > process_s3_files.py <<EOPYTHON
              import boto3
              import os
              import json

              input_bucket = "georgios-input-bucket-euw2-0705-unique1"
              output_bucket = "georgios-output-bucket-euw2-0705-unique1"
              region = "eu-west-2"

              s3 = boto3.client('s3', region_name=region)
              objects = s3.list_objects_v2(Bucket=input_bucket).get("Contents", [])

              file_mappings = []

              for idx, obj in enumerate(objects, start=1):
                  old_key = obj["Key"]
                  ext = os.path.splitext(old_key)[1]
                  new_key = f"animal_{idx}{ext}"

                  s3.download_file(input_bucket, old_key, old_key)
                  s3.upload_file(old_key, output_bucket, new_key)

                  file_mappings.append({
                      "previous_name": old_key,
                      "current_name": new_key
                  })

              json_file = "file_mappings.json"
              with open(json_file, "w") as f:
                  json.dump(file_mappings, f, indent=4)

              s3.upload_file(json_file, output_bucket, json_file)
              print("✅ S3 processing complete.")
              EOPYTHON

              # Run script in venv
              source venv/bin/activate
              python3 process_s3_files.py
              EOF

  tags = {
    Name = "Georgios EC2"
  }
}
