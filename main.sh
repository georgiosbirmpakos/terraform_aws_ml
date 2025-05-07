#!/bin/bash
set -e

# === CONFIG ===
INPUT_BUCKET="georgios-input-bucket-euw2-0705-unique1"
OUTPUT_BUCKET="georgios-output-bucket-euw2-0705-unique1"

cd terraform || { echo "❌ terraform folder not found"; exit 1; }

echo "🌱 Initializing Terraform..."
terraform init -input=false

echo "🚧 Step 1: Create only the S3 buckets..."
terraform apply -target=aws_s3_bucket.input_bucket -target=aws_s3_bucket.output_bucket -auto-approve

echo "🧹 Step 2: Empty existing contents in S3 buckets..."
aws s3 rm s3://$INPUT_BUCKET --recursive || true
aws s3 rm s3://$OUTPUT_BUCKET --recursive || true

echo "☁️ Step 3: Upload input files to input bucket..."
cd .. || exit 1
python upload_input_to_s3.py

echo "🚀 Step 4: Deploy IAM, EC2, and remaining infrastructure..."
cd terraform || exit 1
terraform apply -auto-approve

echo "✅ Done! EC2 will process files and upload renamed versions with JSON mapping."
