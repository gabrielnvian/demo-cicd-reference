# ECR - private container registry for the app image.
#
# Lifecycle policy: keeps the last 10 tagged images to control storage costs.
# Scanning on push catches known CVEs automatically.

resource "aws_ecr_repository" "app" {
 name = "${var.project}"
 image_tag_mutability = "MUTABLE"

 image_scanning_configuration {
 scan_on_push = true
 }

 tags = { Name = "${var.name_prefix}-ecr" }
}

resource "aws_ecr_lifecycle_policy" "app" {
 repository = aws_ecr_repository.app.name

 policy = jsonencode({
 rules = [
 {
 rulePriority = 1
 description = "Keep last 10 tagged images"
 selection = {
 tagStatus = "tagged"
 tagPrefixList = ["v", "sha-"]
 countType = "imageCountMoreThan"
 countNumber = 10
 }
 action = { type = "expire" }
 },
 {
 rulePriority = 2
 description = "Expire untagged images after 7 days"
 selection = {
 tagStatus = "untagged"
 countType = "sinceImagePushed"
 countUnit = "days"
 countNumber = 7
 }
 action = { type = "expire" }
 }
 ]
 })
}
