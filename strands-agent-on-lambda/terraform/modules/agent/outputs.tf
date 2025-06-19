output "agent_endpoint" {
  description = "The endpoint URL for the Agent API"
  value = "https://${aws_api_gateway_rest_api.agent_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.agent_stage.stage_name}/"
}