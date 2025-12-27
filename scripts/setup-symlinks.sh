#!/usr/bin/env bash
# Setup symlinks at project root for convenient access to package resources
# The actual directories are in src/agentic_data_engineer/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Setting up symlinks at project root..."

# Define symlinks as separate arrays
LINK_NAMES=(".claude" ".specify" "shared_schema" "shared_scripts" "shared_agents_usage_docs")
TARGETS=("src/agentic_data_engineer/.claude" "src/agentic_data_engineer/.specify" "src/agentic_data_engineer/shared_schema" "src/agentic_data_engineer/shared_scripts" "src/agentic_data_engineer/shared_agents_usage_docs")

cd "$PROJECT_ROOT"

# Create or verify each symlink
for i in "${!LINK_NAMES[@]}"; do
    link_name="${LINK_NAMES[$i]}"
    target="${TARGETS[$i]}"

    if [ -L "$link_name" ]; then
        # Symlink exists, verify it points to the right place
        current_target=$(readlink "$link_name")
        if [ "$current_target" = "$target" ]; then
            echo "✓ $link_name -> $target (already correct)"
        else
            echo "⚠ $link_name points to $current_target, updating to $target"
            rm "$link_name"
            ln -s "$target" "$link_name"
            echo "✓ Updated $link_name -> $target"
        fi
    elif [ -e "$link_name" ]; then
        # Something exists but it's not a symlink
        echo "⚠ $link_name exists but is not a symlink. Please remove it manually:"
        echo "  rm -rf $link_name"
        exit 1
    else
        # Create new symlink
        ln -s "$target" "$link_name"
        echo "✓ Created $link_name -> $target"
    fi
done

echo ""
echo "✅ All symlinks are set up correctly!"
echo ""
echo "Verifying symlinks work:"
for link_name in "${LINK_NAMES[@]}"; do
    if [ -e "$link_name" ]; then
        echo "  ✓ $link_name resolves correctly"
    else
        echo "  ✗ $link_name is broken!"
        exit 1
    fi
done

echo ""
echo "✅ All symlinks verified!"
