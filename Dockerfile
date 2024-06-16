FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl

# Copy the entrypoint script into the image
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
