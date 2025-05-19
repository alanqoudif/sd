# Open WebUI Docker Images

This repository contains Docker configuration for the [Open WebUI](https://github.com/open-webui/open-webui) project, a user-friendly web interface for interacting with AI models through Ollama.

## Available Docker Images

Two Docker images are available:

1. **Standard Image** (`faisalalanqood/open-webui:latest`): Includes both Open WebUI and requires a connection to an Ollama instance.
2. **Standalone Image** (`faisalalanqood/open-webui:standalone`): Only Open WebUI that can connect to an external Ollama instance.

## Quick Start

### Option 1: Pull from Docker Hub

Standard version:
```bash
docker pull faisalalanqood/open-webui:latest
```

Standalone version:
```bash
docker pull faisalalanqood/open-webui:standalone
```

### Option 2: Run using docker-compose

#### Standard version with Ollama:
```bash
curl -O https://raw.githubusercontent.com/alanqoudif/caa/main/docker-compose-hub.yaml
docker-compose -f docker-compose-hub.yaml up -d
```

#### Standalone version (connect to external Ollama):
```bash
curl -O https://raw.githubusercontent.com/alanqoudif/caa/main/docker-compose-standalone.yaml
# Edit the file to set your Ollama URL
nano docker-compose-standalone.yaml
docker-compose -f docker-compose-standalone.yaml up -d
```

## Configuration

### Environment Variables

Both images support the following environment variables:

- `OLLAMA_BASE_URL`: URL of the Ollama instance (default: http://ollama:11434 in standard version)
- `WEBUI_SECRET_KEY`: Secret key for securing the WebUI (optional)
- `OPENAI_API_KEY`: OpenAI API key for using OpenAI models (optional)

### Volumes

- `open-webui:/app/backend/data`: Stores persistent data for the Open WebUI
- `ollama:/root/.ollama`: Stores Ollama models and data (standard version only)

## Building from Source

If you want to build the images yourself:

```bash
git clone https://github.com/alanqoudif/caa.git
cd caa
chmod +x build-and-push.sh
./build-and-push.sh
```

## Accessing the UI

Once the containers are running, access the web interface at:

```
http://localhost:3000
```

## Additional Resources

- [Open WebUI Official Repository](https://github.com/open-webui/open-webui)
- [Ollama Official Repository](https://github.com/ollama/ollama) 