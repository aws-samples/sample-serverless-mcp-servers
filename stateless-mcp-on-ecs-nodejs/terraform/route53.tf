# resource "aws_acm_certificate" "mcp_server"{
#     domain_name = "${local.project_name}.${local.r53_zone_name}"
#     validation_method = "DNS"
#     lifecycle {
#         create_before_destroy = true
#     }
# }

# data "aws_route53_zone" "zone" {
#   name         = local.r53_zone_name
#   private_zone = false
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.mcp_server.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.zone.zone_id
# }

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn = aws_acm_certificate.mcp_server.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation: record.fqdn]
# }

# resource "aws_route53_record" "mcp_server" {
#   zone_id = data.aws_route53_zone.zone.zone_id
#   name = aws_acm_certificate.mcp_server.domain_name
#   type = "A"
  
#   alias {
#     name = aws_lb.mcp_server.dns_name
#     zone_id = aws_lb.mcp_server.zone_id
#     evaluate_target_health = true
#   }

#   depends_on = [ aws_acm_certificate_validation.cert_validation ]
# }