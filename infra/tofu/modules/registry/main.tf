# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_ecr_repository" "api" {
#   name                 = "${var.project_name}-api"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration { scan_on_push = true }
# }
#
# resource "aws_ecr_repository" "workers" {
#   name                 = "${var.project_name}-workers"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration { scan_on_push = true }
# }
#
# resource "aws_ecr_lifecycle_policy" "api" {
#   repository = aws_ecr_repository.api.name
#   policy = jsonencode({
#     rules = [{
#       rulePriority = 1
#       description  = "Keep last 10 images"
#       selection = {
#         tagStatus   = "any"
#         countType   = "imageCountMoreThan"
#         countNumber = 10
#       }
#       action = { type = "expire" }
#     }]
#   })
# }
#
# resource "aws_ecr_lifecycle_policy" "workers" {
#   repository = aws_ecr_repository.workers.name
#   policy = jsonencode({
#     rules = [{
#       rulePriority = 1
#       description  = "Keep last 10 images"
#       selection = {
#         tagStatus   = "any"
#         countType   = "imageCountMoreThan"
#         countNumber = 10
#       }
#       action = { type = "expire" }
#     }]
#   })
# }
