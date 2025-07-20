#!/bin/bash

# Configuration
PIHOLE_PASS="PASTE_YOUR_PASSWORD_HERE"
GROUP_NAME="Advanced Filtering"
GROUP_DESC="Blocks porn, malware, and ad domains"
API_TOKEN=$(echo -n "$PIHOLE_PASS" | sha256sum | cut -d ' ' -f1)

# Create group
echo "Creating group: $GROUP_NAME"
GROUP_ID=$(sqlite3 /etc/pihole/gravity.db "INSERT INTO 'group' (enabled, name, date_added, date_modified, description) VALUES (1, '$GROUP_NAME', strftime('%s','now'), strftime('%s','now'), '$GROUP_DESC'); SELECT last_insert_rowid();")
echo "Group ID: $GROUP_ID"

# Adlists
declare -a adlists=(
  "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
  "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  "https://adaway.org/hosts.txt"
  "https://v.firebog.net/hosts/Prigent-Malware.txt"
  "https://v.firebog.net/hosts/Prigent-Crypto.txt"
  "https://v.firebog.net/hosts/Shalla-mal.txt"
  "https://urlhaus.abuse.ch/downloads/hostfile/"
  "https://malwaredomains.lehigh.edu/files/justdomains"
)

for url in "${adlists[@]}"
do
  echo "Adding adlist: $url"
  sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO adlist (address, enabled, date_added, date_modified, comment) VALUES ('$url', 1, strftime('%s','now'), strftime('%s','now'), 'Added via script');"
  ADLIST_ID=$(sqlite3 /etc/pihole/gravity.db "SELECT id FROM adlist WHERE address = '$url';")
  sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO group_adlist (group_id, adlist_id) VALUES ($GROUP_ID, $ADLIST_ID);"
done

# Associate all existing clients to the group
echo "Associating all clients to group ID $GROUP_ID"
CLIENT_IDS=$(sqlite3 /etc/pihole/gravity.db "SELECT id FROM client;")
for CLIENT_ID in $CLIENT_IDS; do
  sqlite3 /etc/pihole/gravity.db "INSERT OR IGNORE INTO client_group (client_id, group_id) VALUES ($CLIENT_ID, $GROUP_ID);"
done

# Update gravity
echo "Running gravity update..."
pihole -g

echo "Adlist setup completed."
