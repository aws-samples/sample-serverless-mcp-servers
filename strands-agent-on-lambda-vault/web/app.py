import os
from starlette.middleware.sessions import SessionMiddleware
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
import dotenv
import uvicorn
import gradio as gr
import httpx
import oauth
import json
import base64

dotenv.load_dotenv()

AGENT_ENDPOINT_URL = os.getenv("AGENT_ENDPOINT_URL")
print(f"AGENT_ENDPOINT_URL={AGENT_ENDPOINT_URL}")
user_avatar = "https://cdn-icons-png.flaticon.com/512/149/149071.png"
bot_avatar = "https://cdn-icons-png.flaticon.com/512/4712/4712042.png"

fastapi_app = FastAPI()
# Use a more secure secret key for session encryption
# In production, this should be a strong random value stored securely
SESSION_SECRET_KEY = os.getenv("SESSION_SECRET_KEY", "secure-session-key-for-vault-auth")
fastapi_app.add_middleware(
    SessionMiddleware, 
    secret_key=SESSION_SECRET_KEY,
    max_age=3600,  # Session expires after 1 hour
    https_only=True,  # Cookies only sent over HTTPS
    same_site="lax"  # Provides some CSRF protection
)
oauth.add_oauth_routes(fastapi_app)

@fastapi_app.get("/error")
async def error_page(request: Request, message: str = "Authentication error"):
    # Simple error page that displays the error message
    html_content = f"""
    <!DOCTYPE html>
    <html>
        <head>
            <title>Authentication Error</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    margin: 0;
                    padding: 0;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    background-color: #f5f5f5;
                }}
                .error-container {{
                    background-color: white;
                    padding: 2rem;
                    border-radius: 5px;
                    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                    text-align: center;
                    max-width: 500px;
                }}
                h1 {{
                    color: #e74c3c;
                }}
                .button {{
                    display: inline-block;
                    background-color: #3498db;
                    color: white;
                    padding: 0.5rem 1rem;
                    text-decoration: none;
                    border-radius: 4px;
                    margin-top: 1rem;
                }}
            </style>
        </head>
        <body>
            <div class="error-container">
                <h1>Authentication Error</h1>
                <p>{message}</p>
                <a href="/login" class="button">Try Again</a>
            </div>
        </body>
    </html>
    """
    return HTMLResponse(content=html_content)

def check_auth(req: Request):
    # Check if required session data exists
    if not "id_token" in req.session or not "username" in req.session:
        print("check_auth::not found, redirecting to /login")
        raise HTTPException(status_code=302, detail="Redirecting to login", headers={"Location": "/login"})

    # Get username from session
    username = req.session["username"]
    
    # Debug session contents
    print("=" * 80)
    print("SESSION CONTENTS IN CHECK_AUTH:")
    for key, value in req.session.items():
        if key == "id_token" or key == "access_token":
            print(f"{key}: {'[PRESENT]' if value else '[MISSING]'}")
        else:
            print(f"{key}: {value}")
    print("=" * 80)
    
    # Check if token has expired (if expiry information is available)
    if "token_expiry" in req.session:
        import time
        current_time = int(time.time())
        token_expiry = req.session["token_expiry"]
        
        print(f"Token expiry check: Current time: {current_time}, Token expires: {token_expiry}, Remaining: {token_expiry - current_time} seconds")
        
        # If token has expired, redirect to login
        if current_time >= token_expiry:
            print(f"check_auth::token expired, redirecting to /login")
            req.session.clear()
            raise HTTPException(status_code=302, detail="Token expired", headers={"Location": "/login"})
        
        # If token is about to expire (within 5 minutes), try to refresh it
        elif token_expiry - current_time < 300:  # 5 minutes in seconds
            try:
                print(f"check_auth::token about to expire, attempting refresh")
                # Note: Vault OIDC doesn't support token refresh without user interaction
                # We'll need to redirect the user to login again
                # This is a limitation of the OIDC protocol implementation in Vault
                # For a production application, consider using a different auth method
                # that supports token refresh
                pass
            except Exception as e:
                print(f"check_auth::token refresh failed: {str(e)}")
                # Continue with the current token if refresh fails
                pass

    print(f"check_auth::auth found username: {username}")
    return username

def handle_chat_message(message, history, request: gr.Request):
    username = request.username
    token = request.request.session["id_token"]
    print(f"username={username}, message={message}")
    
    print("=" * 80)
    print("CHAT FUNCTION - TOKEN DEBUGGING")
    print(f"Token length: {len(token) if token else 'None'}")
    
    # Print first and last 20 chars of token if it exists
    if token and len(token) > 40:
        print(f"Token preview: {token[:20]}...{token[-20:]}")
    else:
        print(f"Token: {token}")
    
    # Try to decode token using the same method as in the test app
    try:
        # Use the same base64 decoding approach as the test app
        base64_payload = token.split('.')[1]
        # Add padding if needed
        padding = len(base64_payload) % 4
        if padding > 0:
            base64_payload += '=' * (4 - padding)
        
        # Replace URL-safe characters
        base64_payload = base64_payload.replace('-', '+').replace('_', '/')
        
        # Decode the payload
        decoded_payload = json.loads(base64.b64decode(base64_payload).decode('utf-8'))
        print("DECODED TOKEN CLAIMS:")
        print(json.dumps(decoded_payload, indent=2))
        
        # Extract specific claims that might be useful
        print("\nUSEFUL CLAIMS:")
        for claim in ['sub', 'name', 'username', 'email', 'department', 'role', 'employee_id']:
            if claim in decoded_payload:
                print(f"  {claim}: {decoded_payload[claim]}")
    except Exception as e:
        print(f"Error decoding token: {str(e)}")
    print("=" * 80)

    agent_response = httpx.post(
        AGENT_ENDPOINT_URL,
        headers={"Authorization": f"Bearer {token}"},
        json={"text": message},
        timeout=30,
    )

    if agent_response.status_code == 401 or agent_response.status_code ==403:
        return f"Agent returned authorization error. Try to re-login. Status code: {agent_response.status_code}"

    if agent_response.status_code != 200:
        return f"Failed to communicate with Agent. Status code: {agent_response.status_code}"

    response_text = agent_response.json()['text']
    return response_text

def on_gradio_app_load(request: gr.Request):
    return f"Logout ({request.username})", [gr.ChatMessage(
        role="assistant",
        content=f"Hi {request.username}, I'm your friendly corporate travel agent! I'm here to make booking your next business trip easier. Tell me how I can help. "
    )]

# Create a simple login page with just a button
def create_login_page():
    with gr.Blocks() as login_app:
        gr.Markdown("# Welcome to AcmeCorp Travel Agent")
        gr.Markdown("Please log in to continue")
        
        login_button = gr.Button("Log-in With HCP Vault", variant="primary")
        login_button.click(
            fn=None,
            js="() => window.location.href='/login'"
        )
    
    return login_app

# Create the chat interface that appears after login
def create_chat_interface():
    with gr.Blocks() as chat_app:
        header = gr.Markdown("# AcmeCorp Travel Agent")
        with gr.Accordion("Architecture (click to open)", open=False):
            gr.Image(value='arch.png', show_label=False)

        chat_interface = gr.ChatInterface(
            fn=handle_chat_message,
            type="messages",
            chatbot=gr.Chatbot(
                type="messages",
                label="Book your next business trip with ease",
                avatar_images=(user_avatar, bot_avatar),
                placeholder="<b>Welcome to the AcmeCorp Travel Agent.</b>"
            )
        )

        logout_button = gr.Button(value="Logout", variant="secondary")
        logout_button.click(
            fn=None,
            js="() => window.location.href='/logout'"
        )

        chat_app.load(on_gradio_app_load, inputs=None, outputs=[logout_button, chat_interface.chatbot])
    
    return chat_app

# Create the login page
login_app = create_login_page()

# Create the chat interface
chat_app = create_chat_interface()

# Root route redirects to login or chat based on authentication status
@fastapi_app.get("/")
async def root(request: Request):
    if "id_token" in request.session and "username" in request.session:
        return RedirectResponse(url="/chat")
    else:
        return RedirectResponse(url="/login-page")

# Mount the login page without authentication
gr.mount_gradio_app(fastapi_app, login_app, path="/login-page")

# Mount the chat app with authentication
gr.mount_gradio_app(fastapi_app, chat_app, path="/chat", auth_dependency=check_auth)

if __name__ == "__main__":
    uvicorn.run(fastapi_app, host="0.0.0.0", port=8000)
