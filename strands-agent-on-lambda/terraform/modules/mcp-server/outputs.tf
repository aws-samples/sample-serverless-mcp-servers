# MCP Server module outputs

output "mcp_endpoint" {
  description = "The endpoint URL for the MCP API"
  value       = "https://${aws_api_gateway_rest_api.mcp_api.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/${aws_api_gateway_stage.mcp_stage.stage_name}/mcp"
}

output "jwt_signature_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the Agent-to-MCP JWT signature secret"
  # Reference the version so consumers depend on the secret value being written
  value = aws_secretsmanager_secret_version.jwt_signature_secret.secret_arn
}
