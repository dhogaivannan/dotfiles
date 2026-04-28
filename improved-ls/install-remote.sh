#!/usr/bin/env bash
#
# One-liner installer for improved-ls. Downloads the fish files directly
# into ~/.config/fish/{conf.d,functions} without cloning the repo.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dhogaivannan/dotfiles/main/improved-ls/install-remote.sh | bash
#
# Override the source repo if you've forked:
#   export IMPROVED_LS_REPO_RAW=https://raw.githubusercontent.com/<user>/<repo>/main/improved-ls
#   curl -fsSL "$IMPROVED_LS_REPO_RAW/install-remote.sh" | bash
#
# Requires: bash, curl, fish (the wrapper functions only run inside fish)

set -euo pipefail

REPO_RAW="${IMPROVED_LS_REPO_RAW:-https://raw.githubusercontent.com/dhogaivannan/dotfiles/main/improved-ls}"
FISH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"

if ! command -v fish >/dev/null 2>&1; then
    echo "ERROR: fish is not installed. Install it first:" >&2
    echo "  Debian/Ubuntu:  sudo apt install fish" >&2
    echo "  Fedora:         sudo dnf install fish" >&2
    echo "  Arch:           sudo pacman -S fish" >&2
    echo "  macOS:          brew install fish" >&2
    exit 1
fi

mkdir -p "$FISH_DIR/conf.d" "$FISH_DIR/functions"

fetch() {
    local rel=$1
    local dst="$FISH_DIR/$rel"
    echo "  fetching $rel"
    curl -fsSL --proto '=https' --tlsv1.2 "$REPO_RAW/$rel" -o "$dst"
}

echo "Installing improved-ls into $FISH_DIR"
fetch conf.d/improved-ls.fish
fetch functions/ls.fish
fetch functions/ll.fish
fetch functions/la.fish
fetch functions/__ils_colorize.fish

echo
echo "Done. Open a new fish shell, or run:"
echo "    source $FISH_DIR/conf.d/improved-ls.fish"

if [ -f "$FISH_DIR/config.fish" ] && grep -qE '^[[:space:]]*alias[[:space:]]+ls[[:space:]]*=' "$FISH_DIR/config.fish"; then
    echo
    echo "WARNING: $FISH_DIR/config.fish defines 'alias ls=...'."
    echo "         Remove or comment that line so the wrapper takes effect."
fi
