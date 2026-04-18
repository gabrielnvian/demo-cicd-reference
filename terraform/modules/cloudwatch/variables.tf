variable "name_prefix"    { type = string }
variable "project"        { type = string }
variable "environment"    { type = string }

variable "alarm_sns_arn" {
  description = "SNS topic ARN for alarm notifications. Leave empty to disable."
  type        = string
  default     = ""
}
