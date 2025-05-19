#!/bin/bash
set -e

# Configuration
DOCKER_USERNAME="faisalalanqood"
DOCKER_PASSWORD="Oman121#Oman121#"
GITHUB_REPO="alanqoudif/caa"
IMAGE_NAME="open-webui"
TAG="latest"
STANDALONE_TAG="standalone"

echo "Building Docker images..."
docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$TAG .
docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$STANDALONE_TAG -f Dockerfile.standalone .

echo "Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "Pushing images to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:$TAG
docker push $DOCKER_USERNAME/$IMAGE_NAME:$STANDALONE_TAG

echo "Docker images pushed successfully to Docker Hub:"
echo "- $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
echo "- $DOCKER_USERNAME/$IMAGE_NAME:$STANDALONE_TAG"

# Clone GitHub repository if it doesn't exist
if [ ! -d "caa" ]; then
  echo "Cloning GitHub repository..."
  git clone https://github.com/$GITHUB_REPO.git
fi

# Copy Docker-related files to GitHub repo
cd caa
cp ../Dockerfile .
cp ../Dockerfile.standalone .
cp ../docker-compose.yaml .
cp ../docker-compose-hub.yaml .
cp ../docker-compose-standalone.yaml .
cp ../.dockerignore .
cp ../README.GitHub.md README.md

# Commit and push changes
git add .
git commit -m "Update Docker configurations and documentation"
git push

echo "GitHub repository updated successfully!"
echo "Done!" 