#!/bin/bash
# === CONFIG ===
INPUT_BUCKET="georgios-input-bucket-euw2-0705-unique1"
OUTPUT_BUCKET="georgios-output-bucket-euw2-0705-unique1"

echo "🔧 Re-initializing Terraform..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
terraform init -input=false

echo "🗑️ Emptying S3 buckets before destroy..."
aws s3 rm s3://$INPUT_BUCKET --recursive
aws s3 rm s3://$OUTPUT_BUCKET --recursive

echo "📦 Importing existing S3 buckets into Terraform state..."
terraform import aws_s3_bucket.input_bucket $INPUT_BUCKET
terraform import aws_s3_bucket.output_bucket $OUTPUT_BUCKET

echo "🧨 Destroying previous infrastructure..."
terraform destroy -auto-approve

echo "🚀 Creating infrastructure..."
terraform apply -auto-approve

echo "⏳ Waiting for buckets to be ready..."
sleep 10

echo "☁️ Uploading files to S3..."
python upload_input_to_s3.py

echo "🧹 Cleaning up local Terraform files..."
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

echo "✅ All done and cleaned up!"
