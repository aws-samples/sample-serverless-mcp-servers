import os
from starlette.middleware.sessions import SessionMiddleware
from fastapi import FastAPI, Request, HTTPException
import dotenv
import uvicorn
import gradio as gr
import httpx
import oauth

dotenv.load_dotenv()

AGENT_ENDPOINT_URL = os.getenv("AGENT_ENDPOINT_URL")
print(f"AGENT_ENDPOINT_URL={AGENT_ENDPOINT_URL}")
user_avatar = "https://cdn-icons-png.flaticon.com/512/149/149071.png"
bot_avatar = "https://cdn-icons-png.flaticon.com/512/4712/4712042.png"

fastapi_app = FastAPI()
fastapi_app.add_middleware(SessionMiddleware, secret_key="secret")
oauth.add_oauth_routes(fastapi_app)

def check_auth(req: Request):
    if not "access_token" in req.session or not "username" in req.session:
        print("check_auth::not found, redirecting to /login")
        raise HTTPException(status_code=302, detail="Redirecting to login", headers={"Location": "/login"})

    username = req.session["username"]

    print(f"check_auth::auth found username: {username}")
    return username

def chat(message, history, request: gr.Request):
    username = request.username
    token = request.request.session["access_token"]
    print(f"username={username}, message={message}")
    print(f"token={token}")

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

with gr.Blocks() as gradio_app:
    header = gr.Markdown("Welcome to AcmeCorp Travel Agent")
    with gr.Accordion("Architecture (click to open)", open=False):
        gr.Image(value='arch.png', show_label=False)

    chat = gr.ChatInterface(
        fn=chat,
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

    gradio_app.load(on_gradio_app_load, inputs=None, outputs=[logout_button, chat.chatbot])

gr.mount_gradio_app(fastapi_app, gradio_app, path="/chat", auth_dependency=check_auth)

if __name__ == "__main__":
    uvicorn.run(fastapi_app, host="0.0.0.0", port=8000)

