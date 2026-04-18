#!/usr/bin/env bash
# One-time setup: create the S3 bucket and DynamoDB table used for Terraform
# remote state. Run this ONCE before your first `terraform init`.
#
# Prerequisites: AWS CLI configured with sufficient IAM permissions.
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
BUCKET="${TF_STATE_BUCKET:-your-org-tf-state}"
TABLE="${TF_LOCK_TABLE:-terraform-locks}"

echo "Creating S3 bucket: ${BUCKET}"
aws s3api create-bucket \
  --bucket "${BUCKET}" \
  --region "${REGION}" \
  $( [ "${REGION}" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=${REGION}" )

aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Creating DynamoDB table: ${TABLE}"
aws dynamodb create-table \
  --table-name "${TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}"

echo "Done. Update terraform/versions.tf to uncomment the S3 backend block."
