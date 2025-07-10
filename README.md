# Sakurajima is Lazy Server Setup

This project exists because the author couldn't be bothered to manually install and configure everything on a Debian server every time.  
Also, because i have the bad habit of messing with the kernel for no apparent reason, and things tend to break often, so a full setup script became necessary.

So instead of:
- Updating the system manually
- Creating users
- Setting up a firewall
- Tweaking the bash prompt with Git info
- Installing Node.js, Python, Go, PHP, Docker, Docker Swarm
- Editing `.bashrc` to set environment variables

You run one script and it's done.

## What It Does

The setup is split into three scripts:

### `setup-core.sh`
- Updates the system
- Creates a limited user (`devuser`)
- Enables UFW (firewall)
- Copies SSH keys from root if available
- Adds a Git-aware prompt to `.bashrc`

### `setup-languages.sh`
- Installs:
  - Python 3
  - PHP CLI
  - Node.js (via NodeSource)
  - Golang
- Adds `GOPATH` and `GOBIN` to `.bashrc`

### `setup-docker.sh`
- Installs Docker from the official Docker APT repository
- Initializes Docker Swarm

### `run-all.sh`
- Orchestrates all the scripts above
- Prompts for the `sudo` password once
- Stops if any script fails
- Logs each script’s output to its own file

## How to Run

1. Copy all scripts to your Debian machine.
2. Make them executable:
   ```bash
   chmod +x run-all.sh setup-core.sh setup-languages.sh setup-docker.sh
   ```
3. Run the main script:
   ```bash
   ./run-all.sh
   ```

## Requirements

- Debian 12 or newer
- Internet access for APT and Docker
- Root or sudo access
- A functional keyboard
- Laziness to automate things you could do manually

## Logs

Each script creates a separate log file for review or debugging:

- `setup-core.log`
- `setup-languages.log`
- `setup-docker.log`

These logs will appear in the same directory as the scripts after execution.

## License

No license. No restrictions. Use, copy, destroy, or rewrite as you like.
