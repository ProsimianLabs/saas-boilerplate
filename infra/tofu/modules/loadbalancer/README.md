# infra/tofu/modules/loadbalancer

Provisions an Application Load Balancer with an HTTPS listener (TLS termination using the ACM certificate), an HTTP-to-HTTPS redirect listener, an API target group for ECS tasks, and listener rules that route traffic to the correct target group.

## Resources (Phase 2)

- aws_lb (application)
- aws_lb_listener (443 + 80→443 redirect)
- aws_lb_target_group (api)
- aws_lb_listener_rule

## Inputs

See `variables.tf`.

## Outputs

See `outputs.tf`.
