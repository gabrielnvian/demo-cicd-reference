#!/usr/bin/env bash
# Build and run the production Docker image locally.
set -euo pipefail

ROOT="$(dirname "$0")/.."
IMAGE_NAME="hello-app:local"
CONTAINER_NAME="hello-app-local"

echo "Building Docker image..."
docker build -t "${IMAGE_NAME}" "${ROOT}"

# Stop and remove any existing container with the same name.
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting container on http://localhost:3000"
docker run --rm \
  --name "${CONTAINER_NAME}" \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e APP_VERSION=local \
  "${IMAGE_NAME}"
