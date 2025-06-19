variable "fn_architecture" {
  description = "Lambda function architecture (ARM64 or X86_64)"
  type        = string
  default     = "arm64"
}

variable "fn_dependecies_layer_arn" {
  type = string
}

variable "jwt_signature_secret" {
  description = "Secret used for JWT signature verification"
  type        = string
}

variable "mcp_endpoint" {
  description = "Endpoint URL for the MCP API"
  type        = string
}

variable "cognito_jwks_url" {
  description = "JWKS URL for Cognito authentication"
  type        = string
}