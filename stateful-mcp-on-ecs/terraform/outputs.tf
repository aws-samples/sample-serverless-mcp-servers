output "mcp_endpoint" {
    value = "http://${aws_lb.mcp_server.dns_name}/mcp"
}