#!/bin/bash
set -e

# 1. Ensure the data directory exists
mkdir -p /app/data

# 2. Tell OmniRoute where the database should live
export DATA_DIR=/app/data

# 3. Attempt to restore the SQLite database from the cloud replica if it exists.
# We must pass the -config flag so Litestream knows to use your custom S3 endpoint,
# otherwise it defaults to standard AWS S3 and fails with an InvalidAccessKeyId error.
echo "Attempting to restore SQLite database from Litestream replica..."
litestream restore -config /etc/litestream.yml -if-replica-exists /app/data/storage.sqlite

# 4. Start Litestream replication in the background, and wrap the OmniRoute node process.
# Litestream acts as the parent process. It runs "npm start" (which starts OmniRoute),
# and continuously streams the Write-Ahead Log (WAL) to your bucket.
echo "Starting Litestream replication and OmniRoute application..."
exec litestream replicate -config /etc/litestream.yml -exec "npm start"
