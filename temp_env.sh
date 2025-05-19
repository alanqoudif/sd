export RAG_EMBEDDING_ENGINE=ollama
export RAG_EMBEDDING_MODEL=nomic-embed-text
export RAG_OLLAMA_BASE_URL=http://localhost:11434
cd backend && python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080
