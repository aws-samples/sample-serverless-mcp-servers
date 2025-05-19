output "mcp_endpoint" {
    value = "${aws_api_gateway_stage.dev.invoke_url}/${aws_api_gateway_resource.mcp.path_part}"
}