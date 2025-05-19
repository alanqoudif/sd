import os

# To test CORS_ALLOW_ORIGIN locally, you can set something like
# CORS_ALLOW_ORIGIN=http://localhost:5173;http://localhost:8080
CORS_ALLOW_ORIGIN = os.environ.get(
    "CORS_ALLOW_ORIGIN", "*;http://localhost:5173;http://localhost:5174;http://localhost:8080;http://127.0.0.1:5173;http://127.0.0.1:5174;http://127.0.0.1:8080"
)

WEBUI_URL = PersistentConfig(
    "WEBUI_URL", "webui.url", os.environ.get("WEBUI_URL", "http://localhost:5174")
) 