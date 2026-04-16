#!/bin/bash
# Auto-push activity logs to GitHub every 60 seconds
# Repo: https://github.com/aminulzisan/Facebook-Mass-Report

REPO_DIR="/root/fb-mass-report-auto"
LOG_FILE="/root/autopush_daemon.log"
BRANCH="main"

cd "$REPO_DIR" || exit 1

echo "[$(date)] Autopush daemon started" >> "$LOG_FILE"

while true; do
  # Generate activity log entry
  echo "Repository Activity Monitor" > activity.log
  echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> activity.log
  echo "Uptime: $(uptime -p)" >> activity.log
  echo "System: $(uname -a)" >> activity.log

  # Stage changes
  git add -A

  # Commit with timestamp
  git commit -m "activity: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null

  # Pull first to avoid conflicts, then push
  git pull --rebase origin "$BRANCH" 2>> "$LOG_FILE"
  PUSH_RESULT=$(git push origin "$BRANCH" 2>&1)
  PUSH_EXIT=$?

  if [ $PUSH_EXIT -ne 0 ]; then
    echo "[$(date)] Push failed: $PUSH_RESULT" >> "$LOG_FILE"
    # Force push as fallback if normal push fails
    git push --force origin "$BRANCH" 2>> "$LOG_FILE"
    echo "[$(date)] Force push attempted" >> "$LOG_FILE"
  else
    echo "[$(date)] Push OK" >> "$LOG_FILE"
  fi

  # Wait 60 seconds
  sleep 60
done
