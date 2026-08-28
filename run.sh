#!/bin/bash
set -e

# Force production mode so Next.js does not try to use Webpack for live compilation
export NODE_ENV=production

# 1. Ensure the data directory exists
mkdir -p /app/data

# 2. Tell OmniRoute where the database should live
export DATA_DIR=/app/data

# 3. Attempt to restore the SQLite database from the cloud replica if it exists.
echo "Attempting to restore SQLite database from Litestream replica..."
litestream restore -config /etc/litestream.yml -if-replica-exists /app/data/storage.sqlite

# 4. Start Litestream replication in the background, and wrap the OmniRoute node process.
# We are reverting to npm start because it runs the required bootstrap script for secrets,
# and NODE_ENV=production will stop the Webpack missing module crash.
echo "Starting Litestream replication and OmniRoute application..."
exec litestream replicate -config /etc/litestream.yml -exec "npm start"
