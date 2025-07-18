variable "vault_oidc_client_id" {
  description = "Client ID for Vault OIDC"
  type        = string
}

variable "vault_oidc_client_secret" {
  description = "Client secret for Vault OIDC"
  type        = string
  sensitive   = true
}

variable "vault_oidc_issuer" {
  description = "URL of the Vault OIDC issuer"
  type        = string
}

variable "vault_oidc_auth_url" {
  description = "Authorization endpoint URL for Vault OIDC"
  type        = string
}

variable "vault_oidc_token_url" {
  description = "Token endpoint URL for Vault OIDC"
  type        = string
}

variable "vault_oidc_jwks_url" {
  description = "JWKS endpoint URL for Vault OIDC"
  type        = string
}

variable "vault_oidc_logout_url" {
  description = "Logout endpoint URL for Vault OIDC"
  type        = string
  default     = ""
}