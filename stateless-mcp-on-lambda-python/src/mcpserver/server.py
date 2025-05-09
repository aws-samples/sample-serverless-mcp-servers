import argparse
from fastapi import FastAPI
from echo import mcp

app = FastAPI(title="Echo",lifespan=lambda app: mcp.session_manager.run())
app.mount("/echo", mcp.streamable_http_app())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run the MCP server')
    parser.add_argument('--mode',
                       choices=['stdio', 'streamable-http', 'fastapi'],
                       default='fastapi',
                       help='Server mode: stdio, streamable-http, or fastapi')
    parser.add_argument('--host',
                       default='0.0.0.0',
                       help='Host for FastAPI server (default: 0.0.0.0)')
    parser.add_argument('--port',
                       type=int,
                       default=8000,
                       help='Port for FastAPI server (default: 8000)')

    args = parser.parse_args()
    match args.mode:
        case 'stdio':
            mcp.run(transport='stdio')
        case 'streamable-http':
            mcp.run(transport='streamable-http')
        case _:
            import uvicorn
            uvicorn.run(app, host=args.host, port=args.port, log_level="info")