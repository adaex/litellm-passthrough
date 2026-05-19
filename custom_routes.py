from litellm.proxy.proxy_server import app
from fastapi.responses import JSONResponse


def register_routes():
    @app.get("/v1/ping")
    @app.get("/ping")
    async def ping():
        return JSONResponse({"status": "ok"})
