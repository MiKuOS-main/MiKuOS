#!/usr/bin/env bash

set -euo pipefail

# ── Configuration ──────────────────────────────────────────
REPO="${GIT_BACKUP_REPO:-$HOME/Projects/MyRepo}"
BRANCH="${GIT_BACKUP_BRANCH:-main}"
REMOTE="${GIT_BACKUP_REMOTE:-origin}"
LOG_FILE="${GIT_BACKUP_LOG:-/tmp/daily-git-push.log}"

# ── Logging ────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# ── Main ───────────────────────────────────────────────────
cd "$REPO" || { log "ERROR: Could not cd to $REPO"; exit 1; }

# Check if git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log "ERROR: $REPO is not a git repository"
    exit 1
fi

# Fetch latest changes
log "Fetching from $REMOTE..."
git fetch "$REMOTE" 2>/dev/null || log "WARN: Could not fetch from $REMOTE"

# Check for upstream changes
LOCAL=$(git rev-parse HEAD)
REMOTE_REF=$(git rev-parse "$REMOTE/$BRANCH" 2>/dev/null || echo "")

if [ -n "$REMOTE_REF" ] && [ "$LOCAL" != "$REMOTE_REF" ]; then
    log "Pulling latest changes from $REMOTE/$BRANCH..."
    if ! git pull --rebase "$REMOTE" "$BRANCH" 2>/dev/null; then
        log "WARN: Rebase failed, pulling without rebase..."
        git pull "$REMOTE" "$BRANCH" 2>/dev/null || {
            log "ERROR: Could not pull changes. Manual intervention needed."
            exit 1
        }
    fi
fi

# Stage all changes
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    log "No changes to commit."
    exit 0
fi

# Count changes
CHANGED=$(git diff --cached --shortstat)
log "Changes detected: $CHANGED"

# Commit
COMMIT_MSG="Daily backup $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" || { log "ERROR: Commit failed"; exit 1; }

# Push
if git push "$REMOTE" "$BRANCH" 2>/dev/null; then
    log "Successfully pushed to $REMOTE/$BRANCH"
else
    log "ERROR: Push failed"
    exit 1
fi

log "Backup complete."
