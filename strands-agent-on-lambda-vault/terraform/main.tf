locals {
  fn_architecture      = "arm64"
  jwt_signature_secret = "jwt-signature-secret"
}

# Vault OIDC configuration
module "vault_oidc" {
  source = "./modules/vault-oidc"
  # Replace these values with your own Vault OIDC configuration
  vault_oidc_client_id     = "your_client_d"
  vault_oidc_client_secret = "your_client_secret"
  vault_oidc_issuer        = "https://https://your-vault-instance/v1/identity/oidc/provider/your-provider"
  vault_oidc_auth_url      = "https://https://your-vault-instance/ui/vault/identity/oidc/provider/your-provider/authorize"
  vault_oidc_token_url     = "https://https://your-vault-instance/v1/identity/oidc/provider/your-provider/token"
  vault_oidc_jwks_url      = "https://https://your-vault-instance/v1/identity/oidc/provider/your-provider/.well-known/keys"
  vault_oidc_logout_url    = "https://https://your-vault-instance/ui/vault/logout"  # Optional
}

module "mcp_server" {
  source               = "./modules/mcp-server"
  fn_architecture      = local.fn_architecture
  jwt_signature_secret = local.jwt_signature_secret
}

module "agent_dependencies" {
  source = "./modules/agent-dependencies"
}

module "agent" {
  source                   = "./modules/agent"
  fn_architecture          = local.fn_architecture
  fn_dependecies_layer_arn = module.agent_dependencies.dependencies_layer_arn
  jwt_signature_secret     = local.jwt_signature_secret
  mcp_endpoint             = module.mcp_server.mcp_endpoint
  oidc_jwks_url            = module.vault_oidc.vault_oidc_jwks_url
}

output "outputs_map" {
  value = tomap({
    vault_oidc_client_id : module.vault_oidc.vault_oidc_client_id,
    vault_oidc_client_secret : module.vault_oidc.vault_oidc_client_secret,
    vault_oidc_issuer : module.vault_oidc.vault_oidc_issuer,
    vault_oidc_auth_url : module.vault_oidc.vault_oidc_auth_url,
    vault_oidc_token_url : module.vault_oidc.vault_oidc_token_url,
    vault_oidc_jwks_url : module.vault_oidc.vault_oidc_jwks_url,
    mcp_endpoint : module.mcp_server.mcp_endpoint,
    agent_endpoint : module.agent.agent_endpoint
  })
  sensitive = true
}
