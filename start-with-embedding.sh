#!/bin/bash

# Stop any running instances
pkill -f "uvicorn open_webui.main:app" || true

# Define RAG embedding configuration
export RAG_EMBEDDING_ENGINE="ollama"
export RAG_EMBEDDING_MODEL="nomic-embed-text"
export RAG_OLLAMA_BASE_URL="http://localhost:11434"

# Start the backend server
cd "$(dirname "$0")"
python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --workers 1 