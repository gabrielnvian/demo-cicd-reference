#!/usr/bin/env bash
# Compile TypeScript to dist/.
set -euo pipefail

cd "$(dirname "$0")/../app"
echo "Building TypeScript..."
npm ci
npm run build
echo "Build complete - output in app/dist/"
