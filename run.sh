#!/bin/bash
set -e

# Force production mode so the server behaves correctly
export NODE_ENV=production

# 1. Ensure the data directory exists
mkdir -p /app/data

# 2. Tell OmniRoute where the database should live
export DATA_DIR=/app/data

# 3. Attempt to restore the SQLite database from the cloud replica if it exists.
echo "Attempting to restore SQLite database from Litestream replica..."
litestream restore -config /etc/litestream.yml -if-replica-exists /app/data/storage.sqlite

# 4. Start Litestream replication in the background, and wrap the OmniRoute node process.
# We are now executing the standalone Next.js server directly, bypassing the CLI tool entirely.
echo "Starting Litestream replication and OmniRoute application..."
exec litestream replicate -config /etc/litestream.yml -exec "node server.js"
