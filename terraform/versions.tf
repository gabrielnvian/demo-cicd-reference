terraform {
 required_version = ">= 1.7"

 required_providers {
 aws = {
 source = "hashicorp/aws"
 version = "~> 5.0"
 }
 }

 # Uncomment to enable remote state (S3 + DynamoDB locking).
 # Create the bucket and table first - see scripts/bootstrap-state.sh.
 #
 # backend "s3" {
 # bucket = "your-org-tf-state"
 # key = "demo-cicd-reference/terraform.tfstate"
 # region = "us-east-1"
 # dynamodb_table = "terraform-locks"
 # encrypt = true
 # }
}

provider "aws" {
 region = var.aws_region

 default_tags {
 tags = {
 Project = var.project
 Environment = var.environment
 ManagedBy = "terraform"
 }
 }
}
