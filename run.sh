#!/bin/bash
set -e

# 1. Ensure the data directory exists
mkdir -p /app/data

# 2. Tell OmniRoute where the database should live
export DATA_DIR=/app/data

# 3. Attempt to restore the SQLite database from the S3 bucket if it exists.
# Because Render's free tier starts with a blank slate every time it wakes up,
# this command pulls the most recent backup before OmniRoute starts.
echo "Attempting to restore SQLite database from Litestream replica..."
litestream restore -v -if-replica-exists -o /app/data/storage.sqlite "s3://${LITESTREAM_BUCKET}/storage.sqlite"

# 4. Start Litestream replication in the background, and wrap the OmniRoute node process.
# Litestream acts as the parent process. It runs "npm start" (which starts OmniRoute),
# and continuously streams the Write-Ahead Log (WAL) to the S3 bucket.
echo "Starting Litestream replication and OmniRoute application..."
exec litestream replicate -config /etc/litestream.yml -exec "npm start"

