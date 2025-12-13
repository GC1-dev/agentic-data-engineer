#!/bin/bash
# Script to set up Databricks authentication and configuration for zsh (recommended default)
# For bash users, use: scripts/databricks-auth-setup.sh
# Usage: source scripts/databricks-auth-setup-zsh.sh [env_name] [profile] [warehouse_id]
# Example: source scripts/databricks-auth-setup-zsh.sh dev skyscanner-dev 1204fc84c047ff08

set -e

echo "=========================================="
echo "Databricks Authentication Setup"
echo "=========================================="
echo ""

# Get input parameters or use defaults
DATABRICKS_ENV_NAME="${1:-dev}"
DATABRICKS_CONFIG_PROFILE="${2:-skyscanner-dev}"
DATABRICKS_WAREHOUSE_ID="${3:-1204fc84c047ff08}"

# Derive host from profile
DATABRICKS_HOST="https://skyscanner-${DATABRICKS_ENV_NAME}.cloud.databricks.com"

# Validate inputs
if [ -z "$DATABRICKS_CONFIG_PROFILE" ]; then
    echo "Error: Profile name is required"
    echo "Usage: source scripts/databricks-auth-setup-zsh.sh [env_name] [profile] [warehouse_id]"
    echo "Example: source scripts/databricks-auth-setup-zsh.sh dev skyscanner-dev 1204fc84c047ff08"
    echo ""
    echo "Note: For bash users, use scripts/databricks-auth-setup.sh"
    return 1 2>/dev/null || exit 1
fi

if [ -z "$DATABRICKS_WAREHOUSE_ID" ]; then
    echo "Error: Warehouse ID is required"
    echo "Usage: source scripts/databricks-auth-setup-zsh.sh [env_name] [profile] [warehouse_id]"
    echo "Example: source scripts/databricks-auth-setup-zsh.sh dev skyscanner-dev 1204fc84c047ff08"
    echo ""
    echo "Note: For bash users, use scripts/databricks-auth-setup.sh"
    return 1 2>/dev/null || exit 1
fi

# Step 1: Authenticate via browser (one-time setup)
echo "Step 1: Authenticating with Databricks..."
echo "Host: $DATABRICKS_HOST"
echo "Profile: $DATABRICKS_CONFIG_PROFILE"
echo ""

databricks auth login --host "$DATABRICKS_HOST" --profile "$DATABRICKS_CONFIG_PROFILE"

echo ""
echo "✓ Authentication complete"
echo ""

# Step 2: Export environment variables
echo "Step 2: Setting environment variables..."

ZSHRC="$HOME/.zshrc"
DATABRICKS_BLOCK_START="# >>> databricks-auth-setup >>>"
DATABRICKS_BLOCK_END="# <<< databricks-auth-setup <<<"
DATABRICKS_EXPORTS="export DATABRICKS_HOST=\"${DATABRICKS_HOST}\"\nexport DATABRICKS_CONFIG_PROFILE=\"${DATABRICKS_CONFIG_PROFILE}\"\nexport DATABRICKS_WAREHOUSE_ID=\"${DATABRICKS_WAREHOUSE_ID}\""

# Remove existing block if present
if grep -q "$DATABRICKS_BLOCK_START" "$ZSHRC" 2>/dev/null; then
    # Use awk to remove the old block and write to a temp file
    awk "/$DATABRICKS_BLOCK_START/{flag=1;next}/$DATABRICKS_BLOCK_END/{flag=0;next}!flag" "$ZSHRC" > "${ZSHRC}.tmp"
    mv "${ZSHRC}.tmp" "$ZSHRC"
fi

# Append new block
{
    echo "$DATABRICKS_BLOCK_START"
    echo -e "$DATABRICKS_EXPORTS"
    echo "$DATABRICKS_BLOCK_END"
} >> "$ZSHRC"

echo "✓ Environment variables set"
echo ""

# Step 3: Verify configuration
echo "=========================================="
echo "Configuration Verification"
echo "=========================================="
echo "DATABRICKS_HOST: $DATABRICKS_HOST"
echo "DATABRICKS_CONFIG_PROFILE: $DATABRICKS_CONFIG_PROFILE"
echo "DATABRICKS_WAREHOUSE_ID: $DATABRICKS_WAREHOUSE_ID"
echo ""

# Step 4: Test connection
echo "Testing connection..."
if databricks current-user me >/dev/null 2>&1; then
    echo "✓ Successfully connected to Databricks"
    echo ""
    echo "Current user:"
    databricks current-user me
else
    echo "✗ Failed to connect to Databricks"
    echo "  Please check your authentication and try again"
    exit 1
fi


echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "To use these settings in your current shell, run:"
echo "  source scripts/databricks-auth-setup-zsh.sh"
echo ""
echo "Or add these to your ~/.zshrc:"
echo "  export DATABRICKS_HOST=\"$DATABRICKS_HOST\""
echo "  export DATABRICKS_CONFIG_PROFILE=\"$DATABRICKS_CONFIG_PROFILE\""
echo "  export DATABRICKS_WAREHOUSE_ID=\"$DATABRICKS_WAREHOUSE_ID\""
echo ""
echo "Note: For bash users, use scripts/databricks-auth-setup.sh (recommended default for bash)"
echo ""
