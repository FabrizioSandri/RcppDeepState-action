FROM ubuntu:latest

# Copy the entrypoint to the root filesystem of the container
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Executes `entrypoint.sh` when the Docker container starts up
ENTRYPOINT ["/entrypoint.sh"]