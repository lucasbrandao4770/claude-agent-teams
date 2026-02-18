#!/usr/bin/env bash
# install.sh — Symlink claude-agent-teams into ~/.claude/ for activation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "Installing claude-agent-teams..."
echo "  Source: ${SCRIPT_DIR}"
echo "  Target: ${CLAUDE_DIR}"
echo ""

# Create target directories if they don't exist
mkdir -p "${CLAUDE_DIR}/skills"
mkdir -p "${CLAUDE_DIR}/commands"
mkdir -p "${CLAUDE_DIR}/scripts"

# Symlink skill
if [ -L "${CLAUDE_DIR}/skills/agent-teams" ]; then
    echo "  Updating existing symlink: skills/agent-teams"
    rm "${CLAUDE_DIR}/skills/agent-teams"
elif [ -d "${CLAUDE_DIR}/skills/agent-teams" ]; then
    echo "  WARNING: ${CLAUDE_DIR}/skills/agent-teams is a directory, not a symlink."
    echo "  Back it up and remove it manually, then re-run this script."
    exit 1
fi
ln -s "${SCRIPT_DIR}/skill" "${CLAUDE_DIR}/skills/agent-teams"
echo "  Linked: skills/agent-teams -> skill/"

# Symlink commands
for cmd_dir in team oss; do
    target="${CLAUDE_DIR}/commands/${cmd_dir}"
    if [ -L "${target}" ]; then
        rm "${target}"
    elif [ -d "${target}" ]; then
        echo "  WARNING: ${target} is a directory, not a symlink."
        echo "  Back it up and remove it manually, then re-run this script."
        exit 1
    fi
    ln -s "${SCRIPT_DIR}/commands/${cmd_dir}" "${target}"
    echo "  Linked: commands/${cmd_dir}/ -> commands/${cmd_dir}/"
done

# Symlink scripts
if [ -L "${CLAUDE_DIR}/scripts/team-cleanup.sh" ]; then
    rm "${CLAUDE_DIR}/scripts/team-cleanup.sh"
elif [ -f "${CLAUDE_DIR}/scripts/team-cleanup.sh" ]; then
    echo "  WARNING: ${CLAUDE_DIR}/scripts/team-cleanup.sh is a regular file, not a symlink."
    echo "  Back it up and remove it manually, then re-run this script."
    exit 1
fi
ln -s "${SCRIPT_DIR}/scripts/team-cleanup.sh" "${CLAUDE_DIR}/scripts/team-cleanup.sh"
echo "  Linked: scripts/team-cleanup.sh"

echo ""
echo "Done! Verify with: claude -p 'run /team'"
echo ""
echo "To uninstall, remove the symlinks:"
echo "  rm ${CLAUDE_DIR}/skills/agent-teams"
echo "  rm ${CLAUDE_DIR}/commands/team"
echo "  rm ${CLAUDE_DIR}/commands/oss"
echo "  rm ${CLAUDE_DIR}/scripts/team-cleanup.sh"
