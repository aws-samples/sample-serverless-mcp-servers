from mcp.server.fastmcp import FastMCP
from pydantic_settings import BaseSettings

# settings
class Settings(BaseSettings):
    host: str = "0.0.0.0"
    port: int = 8000
settings = Settings()

# mcp server
mcp = FastMCP(
    name="EchoServer",
    host=settings.host,
    port=settings.port,
    stateless_http=True
)

@mcp.tool(description="A simple echo tool")
def echo(message: str) -> str:
    return f"Echo: {message}"
