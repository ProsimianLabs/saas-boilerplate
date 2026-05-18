# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_lb" "main" {
#   name               = "${var.project_name}-${var.environment}-alb"
#   load_balancer_type = "application"
#   internal           = false
#   security_groups    = [var.alb_security_group_id]
#   subnets            = var.subnet_ids
#   tags               = { Name = "${var.project_name}-${var.environment}-alb" }
# }
#
# resource "aws_lb_target_group" "api" {
#   name        = "${var.project_name}-${var.environment}-api-tg"
#   port        = 8080
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id
#   target_type = "ip"
#   health_check {
#     path                = "/health"
#     healthy_threshold   = 2
#     unhealthy_threshold = 3
#   }
# }
#
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.certificate_arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api.arn
#   }
# }
#
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
