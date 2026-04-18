output "ecr_repository_url" {
 description = "ECR repository URL - push images here"
 value = module.ecr.repository_url
}

output "alb_dns_name" {
 description = "Public DNS name of the Application Load Balancer"
 value = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
 description = "ECS cluster name"
 value = module.ecs.cluster_name
}

output "log_group_name" {
 description = "CloudWatch log group for the app"
 value = module.cloudwatch.log_group_name
}
