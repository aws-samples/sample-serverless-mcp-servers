# MCP Server module outputs

output "mcp_endpoint" {
  description = "The endpoint URL for the MCP API"
    value = "https://${aws_api_gateway_rest_api.mcp_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.mcp_stage.stage_name}/mcp"
}