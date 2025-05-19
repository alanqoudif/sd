#!/bin/bash
set -e

# Configuration
DOCKER_USERNAME="faisalalanqood"
DOCKER_PASSWORD="Oman121#Oman121#"
GITHUB_REPO="alanqoudif/caa"
SOURCE_IMAGE="ghcr.io/open-webui/open-webui:main"
TARGET_IMAGE="$DOCKER_USERNAME/open-webui:latest"

echo "Pulling official Open WebUI image..."
docker pull $SOURCE_IMAGE

echo "Tagging image..."
docker tag $SOURCE_IMAGE $TARGET_IMAGE

echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "Pushing image to Docker Hub..."
docker push $TARGET_IMAGE

echo "Docker image pushed successfully to Docker Hub: $TARGET_IMAGE"

# Clone GitHub repository if it doesn't exist
if [ ! -d "caa" ]; then
  echo "Cloning GitHub repository..."
  git clone https://github.com/$GITHUB_REPO.git
fi

# Copy Docker-related files to GitHub repo
cd caa

# Create docker-compose file
cat > docker-compose.yaml << EOF
services:
  ollama:
    volumes:
      - ollama:/root/.ollama
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    image: ollama/ollama:latest

  open-webui:
    image: $TARGET_IMAGE
    container_name: open-webui
    volumes:
      - open-webui:/app/backend/data
    depends_on:
      - ollama
    ports:
      - 3000:8080
    environment:
      - 'OLLAMA_BASE_URL=http://ollama:11434'
      - 'WEBUI_SECRET_KEY='
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped

volumes:
  ollama: {}
  open-webui: {}
EOF

# Create standalone docker-compose file
cat > docker-compose-standalone.yaml << EOF
services:
  open-webui:
    image: $TARGET_IMAGE
    container_name: open-webui
    volumes:
      - open-webui-data:/app/backend/data
    ports:
      - 3000:8080
    environment:
      # Change this to your external Ollama URL
      - 'OLLAMA_BASE_URL=http://your-ollama-host:11434'
      - 'WEBUI_SECRET_KEY='
    restart: unless-stopped

volumes:
  open-webui-data: {}
EOF

# Create a README file
cat > README.md << EOF
# Open WebUI Docker Image

This repository contains Docker configuration for the Open WebUI project.

## How to use

### Option 1: Pull from Docker Hub
\`\`\`bash
docker pull $TARGET_IMAGE
\`\`\`

### Option 2: Run with Ollama using docker-compose
\`\`\`bash
curl -O https://raw.githubusercontent.com/$GITHUB_REPO/main/docker-compose.yaml
docker-compose up -d
\`\`\`

### Option 3: Connect to external Ollama instance
\`\`\`bash
curl -O https://raw.githubusercontent.com/$GITHUB_REPO/main/docker-compose-standalone.yaml
# Edit the file to set your Ollama URL
nano docker-compose-standalone.yaml
docker-compose -f docker-compose-standalone.yaml up -d
\`\`\`

## Configuration

### Environment Variables

- \`OLLAMA_BASE_URL\`: URL of the Ollama instance (default: http://ollama:11434)
- \`WEBUI_SECRET_KEY\`: Secret key for securing the WebUI (optional)
- \`OPENAI_API_KEY\`: OpenAI API key for using OpenAI models (optional)

### Volumes

- \`open-webui:/app/backend/data\`: Stores persistent data for the Open WebUI
- \`ollama:/root/.ollama\`: Stores Ollama models and data

## Accessing the UI

Once the containers are running, access the web interface at:

\`\`\`
http://localhost:3000
\`\`\`
EOF

# Commit and push changes
git add .
git commit -m "Update Docker configuration files"
git push

echo "GitHub repository updated successfully!"
echo "Done!" 