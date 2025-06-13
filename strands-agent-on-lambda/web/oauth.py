from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse
from authlib.integrations.starlette_client import OAuth
import os

def add_oauth_routes(fastapi_app: FastAPI):
    COGNITO_SIGNIN_URL = os.getenv("COGNITO_SIGNIN_URL")
    COGNITO_LOGOUT_URL = os.getenv("COGNITO_LOGOUT_URL")
    COGNITO_WELL_KNOWN_ENDPOINT_URL = os.getenv("COGNITO_WELL_KNOWN_URL")
    COGNITO_CLIENT_ID = os.getenv("COGNITO_CLIENT_ID")
    COGNITO_CLIENT_SECRET = os.getenv("COGNITO_CLIENT_SECRET")
    OAUTH_CALLBACK_URI = "http://localhost:8000/callback"
    REDIRECT_AFTER_LOGOUT_URL = "http://localhost:8000/chat"

    oauth = OAuth()
    oauth.register(
        name="cognito",
        client_id=COGNITO_CLIENT_ID,
        client_secret=COGNITO_CLIENT_SECRET,
        client_kwargs={"scope": "openid email profile"},
        server_metadata_url=COGNITO_WELL_KNOWN_ENDPOINT_URL,
        redirect_uri=OAUTH_CALLBACK_URI,
    )

    @fastapi_app.get("/login")
    async def login(req: Request):
        return await oauth.cognito.authorize_redirect(req, OAUTH_CALLBACK_URI)

    @fastapi_app.get("/callback")
    async def callback(req: Request):
        tokens = await oauth.cognito.authorize_access_token(req)
        print(tokens)
        access_token = tokens["access_token"]
        username = tokens["userinfo"]["cognito:username"]
        req.session["access_token"] = access_token
        req.session["username"] = username
        print(f"username={username} access_token={access_token}")
        return RedirectResponse(url="/chat")

    @fastapi_app.get("/logout")
    async def logout(req: Request):
        req.session.clear()
        logout_url = f"{COGNITO_LOGOUT_URL}&logout_uri={REDIRECT_AFTER_LOGOUT_URL}"
        return RedirectResponse(url=logout_url)

