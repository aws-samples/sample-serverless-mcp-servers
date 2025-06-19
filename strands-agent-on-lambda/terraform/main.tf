locals {
  fn_architecture      = "arm64"
  jwt_signature_secret = "jwt-signature-secret"
}

module "cognito" {
  source = "./modules/cognito"
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
  cognito_jwks_url         = module.cognito.cognito_jwks_url
}


output "outputs_map" {
  value = tomap({
    cognito_userpool_id : module.cognito.cognito_user_pool_id,
    cognito_client_id : module.cognito.cognito_client_id,
    cognito_client_secret : module.cognito.cognito_client_secret,
    cognito_jwks_url : module.cognito.cognito_jwks_url,
    cognito_sign_in_url: module.cognito.cognito_sign_in_url,
    cognito_logout_url: module.cognito.cognito_logout_url,
    cognito_well_known_url: module.cognito.cognito_well_known_url,
    mcp_endpoint : module.mcp_server.mcp_endpoint,
    agent_endpoint : module.agent.agent_endpoint
  })
  sensitive = true
}


