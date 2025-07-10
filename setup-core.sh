#!/bin/bash
set -e
exec > >(tee -i "setup-core.log") 2>&1

PASSWORD="$SETUP_PASSWORD"
NEW_USER="devuser"
ADD_SUDO_PRIVILEGES=false

echo "[1/5] Updating system..."
echo "$PASSWORD" | sudo -S apt update && sudo apt upgrade -y

echo "[2/5] Installing base packages..."
echo "$PASSWORD" | sudo -S apt install -y \
  curl wget git vim nano build-essential \
  htop unzip zip ufw tmux openssh-server ca-certificates

echo "[3/5] Enabling firewall and SSH..."
echo "$PASSWORD" | sudo -S ufw allow OpenSSH
echo "$PASSWORD" | sudo -S ufw --force enable

echo "[4/5] Creating user '$NEW_USER'..."
if id "$NEW_USER" &>/dev/null; then
  echo "User already exists. Skipping."
else
  echo "$PASSWORD" | sudo -S adduser --disabled-password --gecos "" "$NEW_USER"
  [ "$ADD_SUDO_PRIVILEGES" = true ] && echo "$PASSWORD" | sudo -S usermod -aG sudo "$NEW_USER"
  echo "$PASSWORD" | sudo -S usermod -aG docker "$NEW_USER"

  if [ -f /root/.ssh/authorized_keys ]; then
    echo "$PASSWORD" | sudo -S mkdir -p /home/$NEW_USER/.ssh
    echo "$PASSWORD" | sudo -S cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
    echo "$PASSWORD" | sudo -S chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
    echo "$PASSWORD" | sudo -S chmod 700 /home/$NEW_USER/.ssh
    echo "$PASSWORD" | sudo -S chmod 600 /home/$NEW_USER/.ssh/authorized_keys
  fi
fi

echo "[5/5] Adding Git prompt to .bashrc..."

BASHRC="/home/$NEW_USER/.bashrc"
GIT_PROMPT_MARKER="# >>> GIT PROMPT CONFIG <<<"

if ! sudo grep -q "$GIT_PROMPT_MARKER" "$BASHRC"; then
  echo "$PASSWORD" | sudo -S tee -a "$BASHRC" > /dev/null << 'EOF'

# >>> GIT PROMPT CONFIG <<<
function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi=42
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi=43
        else
            local ansi=45
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
        else
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD`)"
        fi
        echo -n '\[\e[0;37;'"$ansi"';1m\]'"$branch"'\[\e[0m\] '
    fi
}

function _prompt_command() {
    PS1="\[\033[01;32m\]\u@\h:\[\033[01;34m\]\W\[\033[31m\] \[\033[m\]`_git_prompt`$ "
}

PROMPT_COMMAND=_prompt_command
# <<< END GIT PROMPT CONFIG <<<
EOF

  echo "$PASSWORD" | sudo -S chown $NEW_USER:$NEW_USER "$BASHRC"
  echo "Git prompt added to .bashrc for user $NEW_USER."
fi

echo "✔ Core setup complete. Bashrc updated. Prompt will apply on next login."
