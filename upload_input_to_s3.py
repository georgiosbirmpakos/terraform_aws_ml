import os
import zipfile
import boto3

# Local input directory
local_input_dir = "./input"
zip_filename = "input_images.zip"
bucket_name = "georgios-input-bucket-euw2-0705-unique1"
region = "eu-west-2"

# Step 1: Create ZIP file from input folder
with zipfile.ZipFile(zip_filename, "w") as zipf:
    for filename in os.listdir(local_input_dir):
        full_path = os.path.join(local_input_dir, filename)
        if os.path.isfile(full_path):
            zipf.write(full_path, arcname=filename)
            print(f"📦 Zipped: {filename}")

# Step 2: Upload ZIP to S3
s3 = boto3.client("s3", region_name=region)
s3.upload_file(zip_filename, bucket_name, zip_filename)
print(f"✅ Uploaded ZIP to s3://{bucket_name}/{zip_filename}")
