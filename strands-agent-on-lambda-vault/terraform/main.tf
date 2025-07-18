locals {
  fn_architecture      = "arm64"
  jwt_signature_secret = "jwt-signature-secret"
}

# Vault OIDC configuration from vault-oidc-config.txt
module "vault_oidc" {
  source = "./modules/vault-oidc"
  
  # Values from vault-oidc-config.txt
  vault_oidc_client_id     = "K1cGecsTj2A95TchCgzuJ3uRfV8xJSiE"
  vault_oidc_client_secret = "hvo_secret_XjykRWraMi3G9gD0hQZEDFOjGk8WwN6Mn3ApRIpMXP1GASun1bgqypcu1K6nTNqF"
  vault_oidc_issuer        = "https://second-cluster-public-vault-e99520000d.d562c917.z1.hashicorp.cloud:8200/v1/admin/identity/oidc/provider/vault-provider"
  vault_oidc_auth_url      = "https://second-cluster-public-vault-e9952e4d.d562c917.z1.hashicorp.cloud:8200/ui/vault/admin/identity/oidc/provider/vault-provider/authorize"
  vault_oidc_token_url     = "https://second-cluster-public-vault-e9952e4d.d562c917.z1.hashicorp.cloud:8200/v1/admin/identity/oidc/provider/vault-provider/token"
  vault_oidc_jwks_url      = "https://second-cluster-public-vault-e9952e4d.d562c917.z1.hashicorp.cloud:8200/v1/admin/identity/oidc/provider/vault-provider/.well-known/keys"
  vault_oidc_logout_url    = ""  # Not provided in config, can be added if available
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


