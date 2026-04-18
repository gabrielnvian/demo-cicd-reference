variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project identifier, used in resource names"
  type        = string
  default     = "hello-app"
}

variable "environment" {
  description = "Deployment environment (staging | prod)"
  type        = string
  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "environment must be 'staging' or 'prod'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "app_image" {
  description = "Full ECR image URI including tag (set by CI/CD)"
  type        = string
  default     = ""
}

variable "desired_count" {
  description = "Number of ECS task replicas"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "ECS task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "ECS task memory in MiB"
  type        = number
  default     = 512
}
