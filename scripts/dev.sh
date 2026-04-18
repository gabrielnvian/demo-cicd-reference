#!/usr/bin/env bash
# Start the app locally with ts-node (no Docker needed).
set -euo pipefail

cd "$(dirname "$0")/../app"

if [ ! -d node_modules ]; then
  echo "Installing dependencies..."
  npm ci
fi

echo "Starting dev server on http://localhost:3000"
npm run dev
