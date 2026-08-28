#!/bin/bash
set -e

# Force production mode so the server behaves correctly
export NODE_ENV=production

# Prevent Node.js from using more than 400MB of RAM. 
# Render's free tier maxes out at 512MB. If Node passes that, it uses disk swap space, 
# which makes the app incredibly slow. This flag keeps it fast.
export NODE_OPTIONS="--max-old-space-size=400"

# 1. Ensure the data directory exists
mkdir -p /app/data

# 2. Tell OmniRoute where the database should live
export DATA_DIR=/app/data

# 3. Attempt to restore the SQLite database from the cloud replica if it exists.
echo "Attempting to restore SQLite database from Litestream replica..."
litestream restore -config /etc/litestream.yml -if-replica-exists /app/data/storage.sqlite

# 4. Start Litestream replication in the background, and wrap the OmniRoute node process.
echo "Starting Litestream replication and OmniRoute application..."
exec litestream replicate -config /etc/litestream.yml -exec "node server.js"
