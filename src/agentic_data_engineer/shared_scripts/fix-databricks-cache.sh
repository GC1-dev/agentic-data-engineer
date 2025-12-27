#!/bin/bash
# Script to fix corrupted Databricks CLI cache files
# Usage: ./scripts/fix-databricks-cache.sh

set -e

echo "Fixing Databricks CLI cache..."
echo ""

DATABRICKS_DIR="$HOME/.databricks"

# Create databricks directory if it doesn't exist
mkdir -p "$DATABRICKS_DIR"

# Fix token cache file with proper version
TOKEN_CACHE="$DATABRICKS_DIR/token-cache.json"
if [ -f "$TOKEN_CACHE" ]; then
    echo "Checking token cache file..."
    # Check if file has proper version field
    if grep -q '"version":1' "$TOKEN_CACHE" 2>/dev/null; then
        echo "✓ Token cache has correct version"
    else
        echo "✗ Token cache has wrong version or is corrupted - fixing..."
        mv "$TOKEN_CACHE" "$TOKEN_CACHE.backup.$(date +%s)" 2>/dev/null || true
        echo '{"version":1,"tokens":{}}' > "$TOKEN_CACHE"
        echo "✓ Token cache reset with version 1"
    fi
else
    echo "Creating new token cache file with version 1..."
    echo '{"version":1,"tokens":{}}' > "$TOKEN_CACHE"
    echo "✓ Token cache created"
fi

# Clear general cache directory
CACHE_DIR="$DATABRICKS_DIR/cache"
if [ -d "$CACHE_DIR" ]; then
    echo "Clearing cache directory..."
    rm -rf "$CACHE_DIR"
    echo "✓ Cache directory cleared"
fi

echo ""
echo "✓ Databricks CLI cache fixed successfully"
echo ""
echo "You can now run databricks commands without cache errors."
