#!/bin/bash
set -e
exec > >(tee -i "setup-languages.log") 2>&1

PASSWORD="$SETUP_PASSWORD"
TARGET_USER="devuser"
USER_HOME="/home/$TARGET_USER"

echo "[1/4] Installing Python, PHP, and Node.js..."
echo "$PASSWORD" | sudo -S apt install -y python3 python3-pip php-cli

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
echo "$PASSWORD" | sudo -S apt install -y nodejs

echo "[2/4] Installing Golang..."
echo "$PASSWORD" | sudo -S apt install -y golang

echo "[3/4] Configuring GOPATH in .bashrc..."
GO_PATH_LINE='export GOPATH=$HOME/go'
GO_BIN_LINE='export PATH=$PATH:$GOPATH/bin'
BASHRC="$USER_HOME/.bashrc"

if ! grep -q "$GO_PATH_LINE" "$BASHRC"; then
  echo "$GO_PATH_LINE" | sudo tee -a "$BASHRC" > /dev/null
  echo "$GO_BIN_LINE" | sudo tee -a "$BASHRC" > /dev/null
fi

echo "$PASSWORD" | sudo -S chown $TARGET_USER:$TARGET_USER "$BASHRC"

echo "[4/4] Done installing languages and configuring GOPATH."
