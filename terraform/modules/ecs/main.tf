# ECS Fargate service - runs the containerised app behind an ALB.
#
# Architecture:
# Internet → ALB (public subnets) → Target Group → Fargate tasks (public subnets)
#
# For production, move tasks to private subnets and add a NAT Gateway in the VPC
# module (see the commented block in modules/vpc/main.tf).

# ── IAM ──────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "execution" {
 name = "${var.name_prefix}-ecs-execution"

 assume_role_policy = jsonencode({
 Version = "2012-10-17"
 Statement = [{
 Effect = "Allow"
 Principal = { Service = "ecs-tasks.amazonaws.com" }
 Action = "sts:AssumeRole"
 }]
 })
}

resource "aws_iam_role_policy_attachment" "execution" {
 role = aws_iam_role.execution.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
 name = "${var.name_prefix}-ecs-task"

 assume_role_policy = jsonencode({
 Version = "2012-10-17"
 Statement = [{
 Effect = "Allow"
 Principal = { Service = "ecs-tasks.amazonaws.com" }
 Action = "sts:AssumeRole"
 }]
 })
}

# ── Cluster ───────────────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "main" {
 name = "${var.name_prefix}-cluster"

 setting {
 name = "containerInsights"
 value = "enabled"
 }
}

# ── Security groups ───────────────────────────────────────────────────────────

resource "aws_security_group" "alb" {
 name = "${var.name_prefix}-alb-sg"
 description = "Allow HTTP inbound to ALB"
 vpc_id = var.vpc_id

 ingress {
 from_port = 80
 to_port = 80
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "app" {
 name = "${var.name_prefix}-app-sg"
 description = "Allow traffic from ALB to app tasks"
 vpc_id = var.vpc_id

 ingress {
 from_port = var.app_port
 to_port = var.app_port
 protocol = "tcp"
 security_groups = [aws_security_group.alb.id]
 }

 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
}

# ── ALB ───────────────────────────────────────────────────────────────────────

resource "aws_lb" "main" {
 name = "${var.name_prefix}-alb"
 load_balancer_type = "application"
 subnets = var.public_subnets
 security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "app" {
 name = "${var.name_prefix}-tg"
 port = var.app_port
 protocol = "HTTP"
 target_type = "ip"
 vpc_id = var.vpc_id

 health_check {
 path = "/health"
 healthy_threshold = 2
 unhealthy_threshold = 3
 interval = 30
 }
}

resource "aws_lb_listener" "http" {
 load_balancer_arn = aws_lb.main.arn
 port = 80
 protocol = "HTTP"

 default_action {
 type = "forward"
 target_group_arn = aws_lb_target_group.app.arn
 }
}

# ── Task definition ───────────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "app" {
 family = "${var.name_prefix}-task"
 requires_compatibilities = ["FARGATE"]
 network_mode = "awsvpc"
 cpu = var.cpu
 memory = var.memory
 execution_role_arn = aws_iam_role.execution.arn
 task_role_arn = aws_iam_role.task.arn

 container_definitions = jsonencode([
 {
 name = "app"
 image = var.app_image
 essential = true

 portMappings = [
 { containerPort = var.app_port, protocol = "tcp" }
 ]

 environment = [
 { name = "NODE_ENV", value = var.environment },
 { name = "PORT", value = tostring(var.app_port) }
 ]

 logConfiguration = {
 logDriver = "awslogs"
 options = {
 "awslogs-group" = var.log_group_name
 "awslogs-region" = var.aws_region
 "awslogs-stream-prefix" = "ecs"
 }
 }

 healthCheck = {
 command = ["CMD-SHELL", "wget -qO- http://localhost:${var.app_port}/health || exit 1"]
 interval = 30
 timeout = 5
 retries = 3
 startPeriod = 15
 }
 }
 ])
}

# ── ECS Service ───────────────────────────────────────────────────────────────

resource "aws_ecs_service" "app" {
 name = "${var.name_prefix}-service"
 cluster = aws_ecs_cluster.main.id
 task_definition = aws_ecs_task_definition.app.arn
 desired_count = var.desired_count
 launch_type = "FARGATE"

 network_configuration {
 subnets = var.public_subnets
 security_groups = [aws_security_group.app.id]
 assign_public_ip = true
 }

 load_balancer {
 target_group_arn = aws_lb_target_group.app.arn
 container_name = "app"
 container_port = var.app_port
 }

 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent = 200

 # Force a new deployment when the task definition changes (used by deploy.yml).
 force_new_deployment = true

 depends_on = [aws_lb_listener.http]

 lifecycle {
 ignore_changes = [task_definition]
 }
}
