#!/bin/bash
set -e
exec > >(tee -i "setup-docker.log") 2>&1

PASSWORD="$SETUP_PASSWORD"

echo "[1/4] Installing Docker dependencies..."
echo "$PASSWORD" | sudo -S apt install -y ca-certificates curl gnupg lsb-release

echo "[2/4] Adding Docker official repository..."
echo "$PASSWORD" | sudo -S mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[3/4] Installing Docker engine..."
echo "$PASSWORD" | sudo -S apt update
echo "$PASSWORD" | sudo -S apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "$PASSWORD" | sudo -S systemctl enable docker
echo "$PASSWORD" | sudo -S systemctl start docker

echo "[4/4] Initializing Docker Swarm..."
if ! docker info | grep -q 'Swarm: active'; then
  echo "$PASSWORD" | sudo -S docker swarm init
  echo "Docker Swarm initialized."
else
  echo "Docker Swarm already active."
fi

echo "✔ Docker setup complete."
