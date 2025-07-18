# Vault OIDC Configuration Guide

This document provides information about the environment variables used for HashiCorp Vault OIDC authentication in the Travel Agent application.

## Environment Variables

The following environment variables are required for Vault OIDC authentication:

| Variable | Description |
|----------|-------------|
| `VAULT_OIDC_CLIENT_ID` | The client ID provided by Vault for your application. This identifies your application to the Vault OIDC provider. |
| `VAULT_OIDC_CLIENT_SECRET` | The client secret provided by Vault. This is used to authenticate your application when exchanging the authorization code for tokens. |
| `VAULT_OIDC_ISSUER` | The URL of the Vault OIDC issuer. This is used to validate tokens and discover OIDC endpoints. |
| `VAULT_OIDC_AUTH_URL` | The authorization endpoint URL. Users are redirected here to authenticate. |
| `VAULT_OIDC_TOKEN_URL` | The token endpoint URL. Used to exchange the authorization code for access and ID tokens. |
| `VAULT_OIDC_JWKS_URL` | The JSON Web Key Set URL. Used to validate the signature of tokens issued by Vault. |
| `VAULT_OIDC_LOGOUT_URL` | The logout endpoint URL. Users are redirected here when logging out of the application. |

## Setup

You can set up these environment variables using the provided script:

```bash
./setup-vault-env.sh
```

This script will create or update the `.env` file in the web directory with the necessary Vault OIDC configuration.

## Manual Configuration

If you need to manually configure the environment variables, you can create a `.env` file in the web directory with the following content:

```
# Vault OIDC Configuration
VAULT_OIDC_CLIENT_ID="your-client-id"
VAULT_OIDC_CLIENT_SECRET="your-client-secret"
VAULT_OIDC_ISSUER="https://your-vault-instance/v1/identity/oidc/provider/your-provider"
VAULT_OIDC_AUTH_URL="https://your-vault-instance/ui/vault/identity/oidc/provider/your-provider/authorize"
VAULT_OIDC_TOKEN_URL="https://your-vault-instance/v1/identity/oidc/provider/your-provider/token"
VAULT_OIDC_JWKS_URL="https://your-vault-instance/v1/identity/oidc/provider/your-provider/.well-known/keys"
VAULT_OIDC_LOGOUT_URL="https://your-vault-instance/ui/vault/logout"
```

Replace the placeholder values with your actual Vault OIDC configuration.

## Vault OIDC Provider Configuration

To set up a Vault OIDC provider, refer to the HashiCorp Vault documentation:
[Vault OIDC Provider Configuration](https://developer.hashicorp.com/vault/docs/auth/jwt)

## Security Considerations

- Keep your client secret secure and never commit it to version control
- Use HTTPS for all OIDC endpoints
- Implement proper token validation and session management
- Follow OIDC best practices for secure authentication flows