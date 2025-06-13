import click
import logging
from fastapi import FastAPI
from pydantic_settings import BaseSettings
from echo import mcp

# initialization
logger = logging.getLogger(__name__)

# fastapi app
app = FastAPI(title="example", lifespan=lambda app: mcp.session_manager.run())
app.mount("/example", mcp.streamable_http_app())

# main
@click.command()
@click.option("--host", default="0.0.0.0", help="host for FastAPI server (default: 0.0.0.0)")
@click.option("--port", default=8000, help="port for FastAPI server (default: 8000)")
@click.option(
    "--transport",
    default="streamable-http",
    type=click.Choice(["stdio", "streamable-http", "fastapi"]),
    help="transport protocol to use: stdio, streamable-http, fastapi (default: streamable-http))",
)
def main(host: str, port: int, transport: str) -> int:
    logger.info(f"Running server in {transport} mode on {host}:{port}")
    match transport:
        case 'stdio' | 'streamable-http':
            mcp.run(transport=transport)
        case _:
            import uvicorn
            uvicorn.run(app, host=host, port=port, log_level="info")
    return 0

if __name__ == "__main__":
    main()