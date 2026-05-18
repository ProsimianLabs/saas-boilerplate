# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_ecs_cluster" "main" {
#   name = "${var.project_name}-${var.environment}"
# }
#
# resource "aws_iam_role" "execution" {
#   name               = "${var.project_name}-${var.environment}-api-execution"
#   assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
# }
#
# resource "aws_iam_role" "task" {
#   name               = "${var.project_name}-${var.environment}-api-task"
#   assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
# }
#
# resource "aws_iam_role_policy_attachment" "execution_ecr" {
#   role       = aws_iam_role.execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
#
# resource "aws_ecs_task_definition" "api" {
#   family                   = "${var.project_name}-${var.environment}-api"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = 256
#   memory                   = 512
#   execution_role_arn       = aws_iam_role.execution.arn
#   task_role_arn            = aws_iam_role.task.arn
#   container_definitions    = jsonencode([{
#     name      = "api"
#     image     = "${var.ecr_repository_url}:latest"
#     portMappings = [{ containerPort = 8080 }]
#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         awslogs-group         = var.log_group_name
#         awslogs-region        = data.aws_region.current.name
#         awslogs-stream-prefix = "api"
#       }
#     }
#   }])
# }
#
# resource "aws_ecs_service" "api" {
#   name            = "${var.project_name}-${var.environment}-api"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.api.arn
#   desired_count   = var.task_count
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets          = var.subnet_ids
#     security_groups  = [var.security_group_id]
#     assign_public_ip = true
#   }
#   load_balancer {
#     target_group_arn = var.target_group_arn
#     container_name   = "api"
#     container_port   = 8080
#   }
# }
