resource "aws_lb" "mcp_server" {
  name                       = local.project_name
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.public1.id, aws_subnet.public2.id]
  drop_invalid_header_fields = true
  
}

resource "aws_lb_target_group" "mcp_server" {
  name                 = local.project_name
  port                 = local.ecs_task_container_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }
}

# Use HTTP listered ONLY if you do not have a custom domain name registered 
# with Route53. Otherwise:
# 1. Uncomment the route53.tf file
# 2. Remove the HTTP listener and uncomment HTTPS listener in this file
# 3. Update outputs.tf to print HTTPS endpoint instead of HTTP. 
# Only use HTTP for testing purposes!!! Never expose ANYTHING via plain 
# HTTP, use HTTPS only. 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mcp_server.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mcp_server.arn
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.mcp_server.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn = aws_acm_certificate.mcp_server.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.mcp_server.arn
#   }

#   depends_on = [ aws_acm_certificate_validation.cert_validation ]
# }

