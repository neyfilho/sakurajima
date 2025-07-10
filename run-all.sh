#!/bin/bash
set -e

echo "==> Starting full setup process..."

read -s -p "Enter sudo password: " SETUP_PASSWORD
echo
export SETUP_PASSWORD

chmod +x setup-core.sh setup-languages.sh setup-docker.sh

echo "==> Running core setup..."
./setup-core.sh

echo "==> Running language installation..."
./setup-languages.sh

echo "==> Running Docker and Swarm setup..."
./setup-docker.sh

unset SETUP_PASSWORD
echo "==> All setup steps completed successfully."
