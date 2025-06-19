output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "cognito_well_known_url" {
  value = local.cognito_well_known_url
}

output "cognito_sign_in_url" {
  value = local.cognito_sign_in_url
}

output "cognito_logout_url" {
  value = local.cognito_logout_url
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_client_secret" {
  value     = aws_cognito_user_pool_client.user_pool_client.client_secret
  sensitive = true
}

output "cognito_jwks_url" {
  value = local.cognito_jwks_url
}