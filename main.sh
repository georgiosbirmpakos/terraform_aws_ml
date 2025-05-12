#!/bin/bash
set -e

INPUT_BUCKET="georgios-input-bucket-euw2-0705-unique1"
OUTPUT_BUCKET="georgios-output-bucket-euw2-0705-unique1"
REGION="eu-west-2"
ZIP_NAME="input_images.zip"
OUTPUT_ZIP="output_images.zip"
PROJECT_ROOT="$(pwd)"

# Step 0: Init and create only buckets + IAM
cd terraform
terraform init -input=false
terraform apply \
  -target=aws_s3_bucket.input_bucket \
  -target=aws_s3_bucket.output_bucket \
  -target=aws_iam_role.ec2_s3_role \
  -target=aws_iam_role_policy.ec2_s3_policy \
  -target=aws_iam_instance_profile.ec2_profile \
  -auto-approve
cd ..

# Step 1: ZIP and upload input files using Python
python upload_input_to_s3.py

# Step 2: Upload ZIP to input bucket
aws s3 cp $ZIP_NAME s3://$INPUT_BUCKET/ --region $REGION

# Step 3: Deploy the rest (EC2, VPC, endpoint, etc.)
cd terraform
terraform apply -auto-approve
cd ..

# Step 4: Wait for EC2 output
until aws s3 ls s3://$OUTPUT_BUCKET/$OUTPUT_ZIP --region $REGION > /dev/null 2>&1; do
    echo "⏳ Waiting for EC2 to finish..."
    sleep 10
done

# Step 5: Download output
mkdir -p ~/Desktop/output
aws s3 cp s3://$OUTPUT_BUCKET/$OUTPUT_ZIP ~/Desktop/output/$OUTPUT_ZIP --region $REGION
cd ~/Desktop/output && unzip -o $OUTPUT_ZIP

# Step 6: Clean up
cd "$PROJECT_ROOT/terraform"
terraform destroy -auto-approve

echo "✅ Done!"
