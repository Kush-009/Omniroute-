# Use the official OmniRoute base image
FROM ghcr.io/diegosouzapw/omniroute:latest

# Switch to root to install dependencies and Litestream
USER root

# Install curl, tar, and CA certificates
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Install update-notifier directly to resolve any missing package errors
RUN npm install update-notifier

# Download and install Litestream v0.3.13 for Linux AMD64
RUN curl -L "https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz" -o litestream.tar.gz \
    && tar -C /usr/local/bin -xzf litestream.tar.gz \
    && rm litestream.tar.gz

# Create the data directory for the SQLite database
RUN mkdir -p /app/data && chown -R root:root /app/data

# Copy the Litestream configuration file and the startup script
COPY litestream.yml /etc/litestream.yml
COPY run.sh /app/run.sh

# Grant execution permissions to the startup script
RUN chmod +x /app/run.sh

# Set the entrypoint to the custom Litestream script
ENTRYPOINT ["/app/run.sh"]
