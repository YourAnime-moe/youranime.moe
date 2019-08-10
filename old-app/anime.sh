#!/bin/bash
# Start the anime business...
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

echo "Hey there!"

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"