from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse
from authlib.integrations.starlette_client import OAuth
import os
import json
import base64
import json

def add_oauth_routes(fastapi_app: FastAPI):
    # Vault OIDC configuration
    VAULT_OIDC_CLIENT_ID = os.getenv("VAULT_OIDC_CLIENT_ID")
    VAULT_OIDC_CLIENT_SECRET = os.getenv("VAULT_OIDC_CLIENT_SECRET")
    VAULT_OIDC_AUTH_URL = os.getenv("VAULT_OIDC_AUTH_URL")
    VAULT_OIDC_TOKEN_URL = os.getenv("VAULT_OIDC_TOKEN_URL")
    VAULT_OIDC_ISSUER = os.getenv("VAULT_OIDC_ISSUER")
    VAULT_OIDC_JWKS_URL = os.getenv("VAULT_OIDC_JWKS_URL")
    VAULT_OIDC_LOGOUT_URL = os.getenv("VAULT_OIDC_LOGOUT_URL")
    
    OAUTH_CALLBACK_URI = "http://localhost:8000/callback"
    REDIRECT_AFTER_LOGOUT_URL = "http://localhost:8000/chat"

    # Validate required environment variables
    if not all([VAULT_OIDC_CLIENT_ID, VAULT_OIDC_CLIENT_SECRET, VAULT_OIDC_AUTH_URL, 
                VAULT_OIDC_TOKEN_URL, VAULT_OIDC_ISSUER]):
        print("WARNING: Missing required Vault OIDC environment variables")

    oauth = OAuth()
    oauth.register(
        name="vault",
        client_id=VAULT_OIDC_CLIENT_ID,
        client_secret=VAULT_OIDC_CLIENT_SECRET,
        authorize_url=VAULT_OIDC_AUTH_URL,
        access_token_url=VAULT_OIDC_TOKEN_URL,
        jwks_uri=VAULT_OIDC_JWKS_URL,
        client_kwargs={
            "scope": "openid user",  # Match the test app's scope
            "response_type": "code"
        },
        redirect_uri=OAUTH_CALLBACK_URI,
    )

    @fastapi_app.get("/login")
    async def login(req: Request):
        try:
            # Check if Vault OIDC is properly configured
            if not all([VAULT_OIDC_CLIENT_ID, VAULT_OIDC_CLIENT_SECRET, VAULT_OIDC_AUTH_URL]):
                print("ERROR: Vault OIDC is not properly configured")
                return RedirectResponse(url="/error?message=Authentication+provider+not+configured")
            
            # Redirect to Vault authorization endpoint - simplified to match test app
            print(f"Redirecting to Vault OIDC authorization endpoint: {VAULT_OIDC_AUTH_URL}")
            return await oauth.vault.authorize_redirect(req, OAUTH_CALLBACK_URI)
        except Exception as e:
            print(f"Error during login redirect: {str(e)}")
            return RedirectResponse(url="/error?message=Authentication+error")

    @fastapi_app.get("/callback")
    async def callback(req: Request):
        try:
            print("=" * 80)
            print("CALLBACK RECEIVED - Starting token exchange")
            
            # Print query parameters for debugging
            print(f"Query parameters: {req.query_params}")
            code = req.query_params.get("code")
            print(f"Received code: {code}")
            
            # Prepare explicit token exchange parameters to match test app
            token_params = {
                "grant_type": "authorization_code",
                "client_id": VAULT_OIDC_CLIENT_ID,
                "client_secret": VAULT_OIDC_CLIENT_SECRET,
                "code": code,
                "redirect_uri": OAUTH_CALLBACK_URI
            }
            print(f"Requesting tokens with parameters: {token_params}")
            
            # Exchange authorization code for tokens
            tokens = await oauth.vault.authorize_access_token(req)
            print("Token exchange successful")
            
            # Extract token information
            access_token = tokens.get("access_token")
            id_token = tokens.get("id_token")
            
            # Print the raw ID token for debugging
            print("=" * 50)
            print("RAW ID TOKEN:")
            print(id_token)
            print("=" * 50)
            
            if not access_token:
                print("No access token received from Vault OIDC")
                return RedirectResponse(url="/login")
            
            # Extract user information from token claims
            userinfo = tokens.get("userinfo", {})
            
            # Log token information for debugging
            print(f"Token claims: {userinfo}")
            
            # If we have an ID token, decode it using the same method as the test app
            if id_token:
                try:
                    # Use the same base64 decoding approach as the test app
                    base64_payload = id_token.split('.')[1]
                    # Add padding if needed
                    padding = len(base64_payload) % 4
                    if padding > 0:
                        base64_payload += '=' * (4 - padding)
                    
                    # Replace URL-safe characters
                    base64_payload = base64_payload.replace('-', '+').replace('_', '/')
                    
                    # Decode the payload
                    decoded_payload = json.loads(base64.b64decode(base64_payload).decode('utf-8'))
                    print(f"Decoded ID token: {json.dumps(decoded_payload, indent=2)}")
                    
                    # Extract username from the token
                    username = None
                    
                    # Check for username in common fields
                    potential_name_fields = ["username", "name", "preferred_username", "email", "sub"]
                    for field in potential_name_fields:
                        if field in decoded_payload and decoded_payload[field]:
                            username = decoded_payload[field]
                            print(f"Found username in field '{field}': {username}")
                            break
                    
                    # If no username found, use sub
                    if not username and "sub" in decoded_payload:
                        username = decoded_payload["sub"]
                        print(f"Using 'sub' as username: {username}")
                    
                    # Store token expiry if available
                    if "exp" in decoded_payload:
                        req.session["token_expiry"] = decoded_payload["exp"]
                        print(f"Token expiry set from ID token: {decoded_payload['exp']}")
                    
                except Exception as e:
                    print(f"Error decoding ID token: {str(e)}")
                    # Fall back to userinfo extraction
                    username = (
                        userinfo.get("preferred_username") or 
                        userinfo.get("username") or 
                        userinfo.get("email") or 
                        userinfo.get("sub")
                    )
                    print(f"Error occurred, falling back to userinfo username: {username}")
            else:
                # Extract username from userinfo as before
                username = (
                    userinfo.get("preferred_username") or 
                    userinfo.get("username") or 
                    userinfo.get("email") or 
                    userinfo.get("sub")
                )
            
            if not username:
                print("No username found in token claims")
                return RedirectResponse(url="/login")
            
            # Store token information in session
            req.session["access_token"] = access_token
            req.session["id_token"] = id_token if id_token else None
            req.session["username"] = username
            
            print(f"Authentication successful: username={username}")
            print("=" * 80)
            return RedirectResponse(url="/chat")
        
        except Exception as e:
            print(f"Error during token exchange: {str(e)}")
            import traceback
            traceback.print_exc()
            return RedirectResponse(url="/login")

    @fastapi_app.get("/logout")
    async def logout(req: Request):
        # Clear all session data
        req.session.clear()
        
        # If Vault OIDC logout URL is configured, redirect to it
        if VAULT_OIDC_LOGOUT_URL:
            # Include redirect_uri parameter to return to the application after logout
            logout_url = f"{VAULT_OIDC_LOGOUT_URL}?redirect_uri={REDIRECT_AFTER_LOGOUT_URL}"
            print(f"Redirecting to Vault OIDC logout endpoint: {logout_url}")
            return RedirectResponse(url=logout_url)
        else:
            # If no logout URL is configured, just redirect to login page
            print("No Vault OIDC logout URL configured, redirecting to login page")
            return RedirectResponse(url="/login")