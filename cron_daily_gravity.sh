#!/bin/bash

echo "Starting daily Pi-hole gravity update: $(date)"

# Force update of all lists
pihole -g

# Optional: verify if FTL is running
if ! pgrep -x "pihole-FTL" > /dev/null; then
  echo "FTL is not running. Attempting restart..."
  systemctl restart pihole-FTL
else
  echo "FTL is running."
fi

echo "Finished Pi-hole maintenance: $(date)"
