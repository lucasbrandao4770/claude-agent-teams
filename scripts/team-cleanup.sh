#!/bin/bash
# team-cleanup.sh — Clean up after agent teams
# Addresses: orphaned iTerm2 panes (GitHub #24385), stale team/task dirs
#
# Usage: ~/.claude/scripts/team-cleanup.sh [team-name]
#   No args: cleans ALL orphaned teams
#   With arg: cleans specific team

set -euo pipefail

TEAMS_DIR="$HOME/.claude/teams"
TASKS_DIR="$HOME/.claude/tasks"

cleanup_team() {
    local team="$1"
    echo "Cleaning up team: $team"

    # Remove team directory
    if [[ -d "$TEAMS_DIR/$team" ]]; then
        rm -rf "$TEAMS_DIR/$team"
        echo "  Removed $TEAMS_DIR/$team"
    fi

    # Remove task directory
    if [[ -d "$TASKS_DIR/$team" ]]; then
        rm -rf "$TASKS_DIR/$team"
        echo "  Removed $TASKS_DIR/$team"
    fi
}

# Kill orphaned tmux sessions from agent teams
cleanup_tmux() {
    if command -v tmux &>/dev/null; then
        local sessions
        sessions=$(tmux ls 2>/dev/null | grep -v "attached" | cut -d: -f1) || true
        if [[ -n "$sessions" ]]; then
            echo "Found detached tmux sessions:"
            echo "$sessions"
            read -p "Kill all detached sessions? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$sessions" | while read -r s; do
                    tmux kill-session -t "$s" 2>/dev/null || true
                    echo "  Killed session: $s"
                done
            fi
        else
            echo "No orphaned tmux sessions found."
        fi
    fi
}

if [[ $# -eq 1 ]]; then
    cleanup_team "$1"
else
    echo "=== Agent Teams Cleanup ==="
    echo ""

    # Clean team dirs (skip current session's team and task list)
    current_task_list="${CLAUDE_CODE_TASK_LIST_ID:-}"
    current_team="${CLAUDE_CODE_TEAM_NAME:-}"

    if [[ -d "$TEAMS_DIR" ]]; then
        for team_dir in "$TEAMS_DIR"/*/; do
            [[ -d "$team_dir" ]] || continue
            team=$(basename "$team_dir")
            # Skip the currently active team directory
            if [[ -n "$current_team" && "$team" == "$current_team" ]]; then
                echo "  Skipping active team: $team"
                continue
            fi
            cleanup_team "$team"
        done
    fi

    # Clean orphaned task dirs (UUID-named ones from old sessions)
    if [[ -d "$TASKS_DIR" ]]; then
        for task_dir in "$TASKS_DIR"/*/; do
            [[ -d "$task_dir" ]] || continue
            dir_name=$(basename "$task_dir")
            # Skip current session's task list
            [[ "$dir_name" == "$current_task_list" ]] && continue
            # UUID pattern = likely orphaned from a previous session
            if [[ "$dir_name" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
                echo "Removing orphaned task dir: $dir_name"
                rm -rf "$task_dir"
            fi
        done
    fi

    echo ""
    cleanup_tmux
    echo ""
    echo "Done. Close any remaining iTerm2 panes manually with Cmd+W."
fi
