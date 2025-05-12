#!/bin/bash
set -e

# Update and install dependencies
sudo apt update -y
sudo apt install -y python3-pip unzip curl python3-venv

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip and install boto3 inside venv
pip install --upgrade pip
pip install boto3

cat > process_zip.py <<EOF
import boto3, os, zipfile

input_bucket = "georgios-input-bucket-euw2-0705-unique1"
output_bucket = "georgios-output-bucket-euw2-0705-unique1"
region = "eu-west-2"

# Create working dirs
os.makedirs("extracted", exist_ok=True)

s3 = boto3.client("s3", region_name=region)
s3.download_file(input_bucket, "input_images.zip", "input_images.zip")

# Extract images
with zipfile.ZipFile("input_images.zip", "r") as zip_ref:
    zip_ref.extractall("extracted")

# Rename and repackage
processed = []
for idx, fname in enumerate(os.listdir("extracted"), start=1):
    ext = os.path.splitext(fname)[1]
    new_name = f"animal_{idx}{ext}"
    os.rename(f"extracted/{fname}", new_name)
    processed.append(new_name)

with zipfile.ZipFile("output_images.zip", "w") as zipf:
    for f in processed:
        zipf.write(f)

# Upload output ZIP to S3
s3.upload_file("output_images.zip", output_bucket, "output_images.zip")
EOF

# Run Python script
python process_zip.py
