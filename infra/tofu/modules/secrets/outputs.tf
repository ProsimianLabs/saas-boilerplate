# output "api_secret_arns"     { value = [for p in aws_ssm_parameter.secret : p.arn] }
# output "workers_secret_arns" { value = [for p in aws_ssm_parameter.secret : p.arn] }
