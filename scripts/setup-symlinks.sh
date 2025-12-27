#!/usr/bin/env bash
# Setup symlinks for agentic_data_engineer package
# This ensures the package structure is correct for development and packaging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_DIR="$PROJECT_ROOT/src/agentic_data_engineer"

echo "Setting up symlinks in $PACKAGE_DIR..."

# Define symlinks as separate arrays
LINK_NAMES=(".claude" ".specify" "schema" "shared_scripts" "shared_agents_usage_docs")
TARGETS=("../../.claude" "../../.specify" "../../schema" "../../shared_scripts" "../../shared_agents_usage_docs")

# Create package directory if it doesn't exist
mkdir -p "$PACKAGE_DIR"

# Create or verify each symlink
for i in "${!LINK_NAMES[@]}"; do
    link_name="${LINK_NAMES[$i]}"
    target="${TARGETS[$i]}"
    link_path="$PACKAGE_DIR/$link_name"

    if [ -L "$link_path" ]; then
        # Symlink exists, verify it points to the right place
        current_target=$(readlink "$link_path")
        if [ "$current_target" = "$target" ]; then
            echo "✓ $link_name -> $target (already correct)"
        else
            echo "⚠ $link_name points to $current_target, updating to $target"
            rm "$link_path"
            ln -s "$target" "$link_path"
            echo "✓ Updated $link_name -> $target"
        fi
    elif [ -e "$link_path" ]; then
        # Something exists but it's not a symlink
        echo "⚠ $link_name exists but is not a symlink. Please remove it manually:"
        echo "  rm -rf $link_path"
        exit 1
    else
        # Create new symlink
        ln -s "$target" "$link_path"
        echo "✓ Created $link_name -> $target"
    fi
done

echo ""
echo "✅ All symlinks are set up correctly!"
echo ""
echo "Verifying symlinks work:"
for link_name in "${LINK_NAMES[@]}"; do
    link_path="$PACKAGE_DIR/$link_name"
    if [ -e "$link_path" ]; then
        echo "  ✓ $link_name resolves correctly"
    else
        echo "  ✗ $link_name is broken!"
        exit 1
    fi
done

echo ""
echo "✅ All symlinks verified!"
