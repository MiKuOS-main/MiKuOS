#!/usr/bin/env bash

set -e

REPO_DIR="/etc/nixos"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "ERROR: $REPO_DIR is not a git repository."
    exit 1
fi

CHANGES=$(git status --porcelain)

if [ -z "$CHANGES" ]; then
    echo "No changes detected. Nothing to commit."
    exit 0
fi

echo "Changes detected:"
echo "$CHANGES"
echo
echo "Committing with message: Daily NixOS config backup $DATE"
git add .
git commit -m "Daily NixOS config backup $DATE"
echo
echo "Pushing to origin main..."
git push origin main
echo
echo "Successfully pushed at $DATE"
