import os
import boto3

# Your local input folder
local_input_dir = "./input"

# Your S3 bucket name
bucket_name = "georgios-input-bucket-euw2-0705-unique1"

s3_client = boto3.client("s3")

# Upload all files in input folder
for filename in os.listdir(local_input_dir):
    local_path = os.path.join(local_input_dir, filename)
    if os.path.isfile(local_path):
        s3_client.upload_file(local_path, bucket_name, filename)
        print(f"✅ Uploaded: {filename} → s3://{bucket_name}/{filename}")
