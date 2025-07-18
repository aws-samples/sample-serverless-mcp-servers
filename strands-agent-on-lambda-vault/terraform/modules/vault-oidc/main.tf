locals {
  # Default values for Vault OIDC configuration
  vault_oidc_client_id     = var.vault_oidc_client_id
  vault_oidc_client_secret = var.vault_oidc_client_secret
  vault_oidc_issuer        = var.vault_oidc_issuer
  vault_oidc_auth_url      = var.vault_oidc_auth_url
  vault_oidc_token_url     = var.vault_oidc_token_url
  vault_oidc_jwks_url      = var.vault_oidc_jwks_url
  vault_oidc_logout_url    = var.vault_oidc_logout_url
}

# No resources are created in this module
# It simply passes through the Vault OIDC configuration values