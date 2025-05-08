#!/bin/bash
sudo apt update -y
sudo apt install -y python3-pip unzip curl python3-venv

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
export PATH=$PATH:/usr/local/bin

python3 -m venv venv
source venv/bin/activate
pip install boto3

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

source venv/bin/activate
python3 process_s3_files.py

echo '{"status": "done", "timestamp": "'$(date)'"}' > done.json
aws s3 cp done.json s3://georgios-output-bucket-euw2-0705-unique1/done.json --region eu-west-2
