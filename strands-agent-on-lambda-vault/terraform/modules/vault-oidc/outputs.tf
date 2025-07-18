output "vault_oidc_client_id" {
  value = local.vault_oidc_client_id
}

output "vault_oidc_client_secret" {
  value     = local.vault_oidc_client_secret
  sensitive = true
}

output "vault_oidc_issuer" {
  value = local.vault_oidc_issuer
}

output "vault_oidc_auth_url" {
  value = local.vault_oidc_auth_url
}

output "vault_oidc_token_url" {
  value = local.vault_oidc_token_url
}

output "vault_oidc_jwks_url" {
  value = local.vault_oidc_jwks_url
}

output "vault_oidc_logout_url" {
  value = local.vault_oidc_logout_url
}