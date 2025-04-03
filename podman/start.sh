#!/bin/bash
# AI Chatbot Deployment Script
set -euo pipefail  # Enable strict error handling

# Configuration
CONTAINER_NAME="ai-chatbot"
IMAGE_NAME="ai-chatbot"
PORT="8501"
VOLUME_PATH="${HOME}/chatbot_data"

# Create data directory if not exists
mkdir -p "${VOLUME_PATH}"

# Build the image (with cache cleanup)
echo "Building container image..."
podman build --rm -t "${IMAGE_NAME}" -f Containerfile .

# Stop and remove existing container if running
if podman ps -a | grep -q "${CONTAINER_NAME}"; then
    echo "Stopping existing container..."
    podman stop "${CONTAINER_NAME}" >/dev/null
    podman rm "${CONTAINER_NAME}" >/dev/null
fi

# Run the container with persistent storage
echo "Starting new container..."
podman run -d \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:8501" \
    -v "${VOLUME_PATH}:/app/data" \
    --restart unless-stopped \
    "${IMAGE_NAME}"

# Show running status
echo "Container deployed successfully:"
podman ps --filter "name=${CONTAINER_NAME}"

echo -e "\nAccess the chatbot at: http://localhost:${PORT}"
