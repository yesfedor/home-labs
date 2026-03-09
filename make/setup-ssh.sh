#!/bin/bash
set -e

# --- Usage ---
# This script installs OpenSSH Server and adds a public key to authorized_keys.
# It is intended to be run on the host machine where you want to enable SSH access.
#
# Usage:
#   ./make/setup-ssh.sh
#   OR
#   bash make/setup-ssh.sh
#
# The script expects the public key to be located at: <repo_root>/ssh/ci.pub

# Determine the absolute path to the repository root
# (Assuming this script is located in <repo_root>/make/)
if [ -z "$REPO_ROOT" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(dirname "$SCRIPT_DIR")"
fi

PUB_KEY_FILE="$REPO_ROOT/ssh/ci.pub"

echo ">>> Setting up Host SSH Access..."
echo "Repository Root: $REPO_ROOT"
echo "Using public key file: $PUB_KEY_FILE"

# 1. Install required packages
echo "Installing openssh-server and resolvconf..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y openssh-server resolvconf
elif command -v yum &> /dev/null; then
    sudo yum install -y openssh-server resolvconf
else
    echo "Warning: Package manager not found (apt/yum). Skipping package installation."
fi

# 2. Ensure SSH service is running
echo "Enabling and starting sshd..."
if command -v systemctl &> /dev/null; then
    sudo systemctl enable ssh
    sudo systemctl start ssh
else
    echo "Warning: systemctl not found. Please ensure sshd is started manually."
fi

# 3. Add public key to authorized_keys
if [ -f "$PUB_KEY_FILE" ]; then
    echo "Adding public key to ~/.ssh/authorized_keys..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Append key if not already present
    PUB_KEY=$(cat "$PUB_KEY_FILE")
    if ! grep -q "$PUB_KEY" ~/.ssh/authorized_keys 2>/dev/null; then
        echo "$PUB_KEY" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        echo "Key added successfully."
    else
        echo "Key already exists in authorized_keys."
    fi
else
    echo "Error: Public key file '$PUB_KEY_FILE' not found!"
    echo "Please place your public key in '$REPO_ROOT/ssh/ci.pub' before running this script."
    exit 1
fi

echo ">>> SSH Setup Complete."
