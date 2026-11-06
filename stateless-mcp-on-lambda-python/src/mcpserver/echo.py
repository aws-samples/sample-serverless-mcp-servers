from mcp.server.fastmcp import FastMCP

mcp = FastMCP(name="EchoServer", stateless_http=True, host="0.0.0.0")

@mcp.tool(description="A simple echo tool")
def echo(message: str) -> str:
    return f"Echo: {message}"
