#!/bin/bash

# Default values
DST_FILE_NAME="./.env"
VAULT_URL=""
CLIENT_ID=""
CLIENT_SECRET=""
USE_DEFAULTS=false

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --url VAULT_URL       Vault URL"
    echo "  -i, --client-id ID        Client ID"
    echo "  -s, --client-secret SECRET Client Secret"
    echo "  -d, --defaults            Use default values without prompting"
    echo "  -h, --help                Display this help message"
    echo ""
    echo "If options are not provided, the script will interactively prompt for values."
    echo ""
    echo "Example:"
    echo "  $0 -u https://vault.example.com:8200 -i client123 -s secret456"
    echo "  $0 --defaults  # Use default values without prompting"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -u|--url)
            VAULT_URL="$2"
            shift 2
            ;;
        -i|--client-id)
            CLIENT_ID="$2"
            shift 2
            ;;
        -s|--client-secret)
            CLIENT_SECRET="$2"
            shift 2
            ;;
        -d|--defaults)
            USE_DEFAULTS=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Default values
DEFAULT_VAULT_URL="https://XXXXX.d562c917.z1.hashicorp.cloud:8200"
DEFAULT_CLIENT_ID="XXXXXXXXX"
DEFAULT_CLIENT_SECRET="hvo_secret_XXXXXXXX"

# If using defaults flag is set, use default values without prompting
if [ "$USE_DEFAULTS" = true ]; then
    echo "Using default values without prompting..."
    VAULT_URL="$DEFAULT_VAULT_URL"
    CLIENT_ID="$DEFAULT_CLIENT_ID"
    CLIENT_SECRET="$DEFAULT_CLIENT_SECRET"
else
    # Interactive prompts for missing values
    if [ -z "$VAULT_URL" ]; then
        read -p "Enter Vault URL [$DEFAULT_VAULT_URL]: " VAULT_URL_INPUT
        VAULT_URL=${VAULT_URL_INPUT:-$DEFAULT_VAULT_URL}
    fi

    if [ -z "$CLIENT_ID" ]; then
        read -p "Enter Client ID [$DEFAULT_CLIENT_ID]: " CLIENT_ID_INPUT
        CLIENT_ID=${CLIENT_ID_INPUT:-$DEFAULT_CLIENT_ID}
    fi

    if [ -z "$CLIENT_SECRET" ]; then
        read -p "Enter Client Secret (press Enter to use default): " -s CLIENT_SECRET_INPUT
        echo ""
        CLIENT_SECRET=${CLIENT_SECRET_INPUT:-$DEFAULT_CLIENT_SECRET}
    fi
fi

# Remove trailing slash from VAULT_URL if present
VAULT_URL=${VAULT_URL%/}

echo "> Setting up Vault OIDC environment variables in $DST_FILE_NAME"
echo "> Using Vault URL: $VAULT_URL"
echo "> Using Client ID: $CLIENT_ID"
echo "> Using Client Secret: ${CLIENT_SECRET:0:5}..."

# Create or overwrite .env file
touch $DST_FILE_NAME

# Vault OIDC Configuration
echo "# Vault OIDC Configuration" > $DST_FILE_NAME
echo "VAULT_OIDC_CLIENT_ID=\"$CLIENT_ID\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_CLIENT_SECRET=\"$CLIENT_SECRET\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_ISSUER=\"$VAULT_URL/v1/admin/identity/oidc/provider/vault-provider\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_AUTH_URL=\"$VAULT_URL/ui/vault/admin/identity/oidc/provider/vault-provider/authorize\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_TOKEN_URL=\"$VAULT_URL/v1/admin/identity/oidc/provider/vault-provider/token\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_JWKS_URL=\"$VAULT_URL/v1/admin/identity/oidc/provider/vault-provider/.well-known/keys\"" >> $DST_FILE_NAME
echo "VAULT_OIDC_LOGOUT_URL=\"$VAULT_URL/ui/vault/logout\"" >> $DST_FILE_NAME

# Get the Agent Endpoint URL from Terraform state
echo "> Retrieving AGENT_ENDPOINT_URL from Terraform state"
TERRAFORM_DIR="../terraform"
if [ -d "$TERRAFORM_DIR" ]; then
    cd $TERRAFORM_DIR

    # Extract the invoke_url from the API Gateway stage
    AGENT_ENDPOINT_URL=$(terraform state show module.agent.aws_api_gateway_stage.agent_stage 2>/dev/null | grep invoke_url | awk -F'= ' '{print $2}' | tr -d '"')

    if [ -z "$AGENT_ENDPOINT_URL" ]; then
        echo "WARNING: Could not retrieve AGENT_ENDPOINT_URL from Terraform state"
        read -p "Enter Agent Endpoint URL [http://localhost:8000/api/agent]: " AGENT_ENDPOINT_URL_INPUT
        AGENT_ENDPOINT_URL=${AGENT_ENDPOINT_URL_INPUT:-"http://localhost:8000/api/agent"}
    fi

    cd - > /dev/null
else
    echo "WARNING: Terraform directory not found at $TERRAFORM_DIR"
    read -p "Enter Agent Endpoint URL [http://localhost:8000/api/agent]: " AGENT_ENDPOINT_URL_INPUT
    AGENT_ENDPOINT_URL=${AGENT_ENDPOINT_URL_INPUT:-"http://localhost:8000/api/agent"}
fi

echo "# Agent Endpoint URL" >> $DST_FILE_NAME
echo "AGENT_ENDPOINT_URL=\"$AGENT_ENDPOINT_URL\"" >> $DST_FILE_NAME

# Add session secret key
echo "# Session Secret Key" >> $DST_FILE_NAME
echo "SESSION_SECRET_KEY=\"$(openssl rand -hex 32)\"" >> $DST_FILE_NAME

echo ""
echo "Vault OIDC environment variables have been set up in $DST_FILE_NAME"
echo "AGENT_ENDPOINT_URL: $AGENT_ENDPOINT_URL"
echo ""
echo "You can now start the application with:"
echo "cd web && python app.py"