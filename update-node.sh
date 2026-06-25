#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Updating system and installing prerequisites ==="
apt-get update && apt-get install -y ca-certificates curl gnupg

echo "=== Adding NodeSource architecture for Node.js 20 ==="
mkdir -p /etc/apt/keyrings
# Added --yes to overwrite the existing key automatically
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --yes --dearmor -o /etc/apt/keyrings/nodesource.gpg

# FIXED: Changed .list.p to .list.d
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

echo "=== Installing Node.js ==="
apt-get update
# FIXED: Changed node-js to nodejs
apt-get install -y nodejs

echo "=== Verifying installations ==="
node -v
npm -v

echo "=== Resuming Caterpillar Installation ==="
curl -fsSL caterpillar.alice.io/d/i.sh | sh
