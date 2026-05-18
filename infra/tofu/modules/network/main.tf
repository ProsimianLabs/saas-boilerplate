# Phase 1 scaffold. Resources stubbed as comments — populated in Phase 2.

# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   tags = { Name = "${var.project_name}-${var.environment}-vpc" }
# }
#
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#   tags   = { Name = "${var.project_name}-${var.environment}-igw" }
# }
#
# data "aws_availability_zones" "available" { state = "available" }
#
# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true
#   tags                    = { Name = "${var.project_name}-${var.environment}-public-${count.index}" }
# }
#
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
# }
#
# resource "aws_route_table_association" "public" {
#   count          = length(aws_subnet.public)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
#
# resource "aws_security_group" "alb" {
#   name        = "${var.project_name}-${var.environment}-alb"
#   description = "ALB ingress 443 from anywhere; egress to api SG"
#   vpc_id      = aws_vpc.main.id
#   ingress { from_port = 443; to_port = 443; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
#   ingress { from_port = 80;  to_port = 80;  protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
#   egress  { from_port = 0;   to_port = 0;   protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
# }
#
# resource "aws_security_group" "api" {
#   name        = "${var.project_name}-${var.environment}-api"
#   description = "API tasks: ingress only from ALB SG"
#   vpc_id      = aws_vpc.main.id
#   ingress { from_port = 8080; to_port = 8080; protocol = "tcp"; security_groups = [aws_security_group.alb.id] }
#   egress  { from_port = 0;    to_port = 0;    protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
# }
#
# resource "aws_security_group" "workers" {
#   name        = "${var.project_name}-${var.environment}-workers"
#   description = "Workers: no inbound; outbound to internet + Redis/DB"
#   vpc_id      = aws_vpc.main.id
#   egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
# }
