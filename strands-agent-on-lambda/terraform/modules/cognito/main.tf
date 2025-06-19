data "aws_region" "current" {}

locals {
  redirect_uri = "http://localhost:8000/callback"
  logout_uri   = "http://localhost:8000/chat"
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "strands-agent-on-lambda"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                                 = "user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = [local.redirect_uri]
  logout_urls = [local.logout_uri]
  supported_identity_providers = ["COGNITO"]
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = "strands-on-lambda"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_user" "alice_user" {
  user_pool_id   = aws_cognito_user_pool.user_pool.id
  username       = "Alice"
  message_action = "SUPPRESS"
}

resource "aws_cognito_user" "bob_user" {
  user_pool_id   = aws_cognito_user_pool.user_pool.id
  username       = "Bob"
  message_action = "SUPPRESS"
}

locals {
  cognito_jwks_url       = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}/.well-known/jwks.json"
  cognito_well_known_url = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}/.well-known/openid-configuration"
  cognito_sign_in_url    = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.user_pool_client.id}&response_type=code&redirect_uri=${local.redirect_uri}"
  cognito_logout_url     = "https://${aws_cognito_user_pool_domain.user_pool_domain.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/logout?client_id=${aws_cognito_user_pool_client.user_pool_client.id}"
}