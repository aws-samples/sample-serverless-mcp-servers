variable "fn_architecture" {
  description = "Lambda function architecture (ARM64 or X86_64)"
  type        = string
  default     = "arm64"
}

variable "jwt_signature_secret" {
  description = "Secret used for JWT signature verification"
  type        = string
  default     = "jwt-signature-secret"
}