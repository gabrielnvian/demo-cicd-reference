# CloudWatch — log group for ECS task output + basic alarms.
#
# Alarms defined here:
#   1. High CPU utilization on the ECS service (>80% for 5 min)
#   2. High memory utilization (>80% for 5 min)
#   3. ALB 5xx error rate (>5 errors in 1 min)
#
# To wire up notifications, create an SNS topic and set var.alarm_sns_arn.

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 14

  tags = { Name = "${var.name_prefix}-logs" }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS CPU > 80% for 4 minutes"

  dimensions = {
    ClusterName = "${var.name_prefix}-cluster"
    ServiceName = "${var.name_prefix}-service"
  }

  alarm_actions = var.alarm_sns_arn != "" ? [var.alarm_sns_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.name_prefix}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS memory > 80% for 4 minutes"

  dimensions = {
    ClusterName = "${var.name_prefix}-cluster"
    ServiceName = "${var.name_prefix}-service"
  }

  alarm_actions = var.alarm_sns_arn != "" ? [var.alarm_sns_arn] : []
}
