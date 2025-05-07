import boto3
import os
import json

input_bucket = "georgios-input-bucket-euw2-0705-unique1"
output_bucket = "georgios-output-bucket-euw2-0705-unique1"
region = "eu-west-2"

s3 = boto3.client('s3', region_name=region)

# Get list of objects in input bucket
objects = s3.list_objects_v2(Bucket=input_bucket).get("Contents", [])

file_mappings = []

for idx, obj in enumerate(objects, start=1):
    old_key = obj["Key"]
    ext = os.path.splitext(old_key)[1]
    new_key = f"animal_{idx}{ext}"

    # Download the file locally
    s3.download_file(input_bucket, old_key, old_key)

    # Re-upload with new name to output bucket
    s3.upload_file(old_key, output_bucket, new_key)

    file_mappings.append({
        "previous_name": old_key,
        "current_name": new_key
    })

# Save JSON
json_file = "file_mappings.json"
with open(json_file, "w") as f:
    json.dump(file_mappings, f, indent=4)

# Upload JSON file to output bucket
s3.upload_file(json_file, output_bucket, json_file)

print("✅ S3 processing complete.")
