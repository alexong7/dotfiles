#!/bin/bash
# Claude Code custom status line.
# Shows: repo name, worktree indicator, git branch, session cost, context window usage.
# Requires `jq` and `bc` on your PATH.

# Read JSON input from stdin
INPUT=$(cat)

# Colors
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
PINK='\033[35m'
DIM='\033[2m'
RESET='\033[0m'

# Extract cost and context size from JSON input
COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0' 2>/dev/null)
COST_FMT=$(printf '$%.2f' "$COST" 2>/dev/null || echo '$0.00')
CONTEXT_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
CONTEXT_SIZE=$(echo "$INPUT" | jq -r '.context_window.context_window_size // 0' 2>/dev/null)
CONTEXT_USED=$(echo "$CONTEXT_PCT * $CONTEXT_SIZE / 100 / 1000" | bc -l 2>/dev/null || echo 0)
CONTEXT_K=$(printf '%.0fK' "$CONTEXT_USED")

# Get current directory name
DIR_NAME=$(basename "$PWD")

# Check if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get repo name from remote origin URL
    REPO_NAME=$(git remote get-url origin 2>/dev/null | sed 's/.*[\/:]//;s/\.git$//')
    # Get branch name
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -z "$BRANCH" ] && BRANCH="(detached)"

    DISPLAY_REPO="${REPO_NAME}"

    # Check if in a worktree (git-dir differs from git-common-dir)
    GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
    GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
    IS_WORKTREE=false
    [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && IS_WORKTREE=true

    DIR_PART=""
    if [ "$IS_WORKTREE" = false ] && [ "$DIR_NAME" != "$REPO_NAME" ]; then
        DIR_PART=" ${DIM}|${RESET} ${CYAN}${DIR_NAME}${RESET}"
    fi

    WORKTREE_ICON=""
    [ "$IS_WORKTREE" = true ] && WORKTREE_ICON="${YELLOW}⌥${RESET} "

    echo -e "${CYAN}${DISPLAY_REPO}${RESET}${DIR_PART} ${DIM}|${RESET} ${WORKTREE_ICON}${GREEN}${BRANCH}${RESET} ${DIM}|${RESET} ${COST_FMT} ${DIM}|${RESET} ${PINK}${CONTEXT_K} (${CONTEXT_PCT}%)${RESET}"
else
    echo -e "${CYAN}${DIR_NAME}${RESET} ${DIM}|${RESET} (not a git repo) ${DIM}|${RESET} ${COST_FMT} ${DIM}|${RESET} ${PINK}${CONTEXT_K} (${CONTEXT_PCT}%)${RESET}"
fi
