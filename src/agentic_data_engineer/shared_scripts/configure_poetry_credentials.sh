#!/bin/bash
# Script to configure Poetry credentials from pip.conf
# Reads credentials from ~/.pip/pip.conf and configures Poetry for Skyscanner Artifactory
# Usage: bash shared_scripts/configure_poetry_credentials.sh

set -euo pipefail

echo "=========================================="
echo "Poetry Credential Configuration"
echo "=========================================="
echo ""

# Define pip.conf location
PIP_CONF="$HOME/.pip/pip.conf"

# Check if pip.conf exists
if [ ! -f "$PIP_CONF" ]; then
    echo "⚠ Warning: pip.conf not found at $PIP_CONF"
    echo "  Skipping Poetry credential configuration"
    echo "  If you need to configure credentials manually, run:"
    echo "    poetry config http-basic.skyscanner-artifactory <username> <password>"
    echo ""
    exit 0
fi

echo "Reading credentials from $PIP_CONF..."

# Extract credentials from pip.conf
# Expected format: index-url = https://username:password@host/path
CREDS_LINE=$(grep -E "index-url\s*=\s*https://" "$PIP_CONF" || true)

if [ -z "$CREDS_LINE" ]; then
    echo "⚠ Warning: No credentials found in $PIP_CONF"
    echo "  Expected format: index-url = https://username:password@host/path"
    echo "  Skipping Poetry credential configuration"
    echo ""
    exit 0
fi

# Extract username and password using regex
# Pattern: https://username:password@host/path
USERNAME=$(echo "$CREDS_LINE" | sed -n 's/.*https:\/\/\([^:]*\):.*/\1/p')
PASSWORD=$(echo "$CREDS_LINE" | sed -n 's/.*https:\/\/[^:]*:\([^@]*\)@.*/\1/p')

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "✗ Failed to extract credentials from $PIP_CONF"
    echo "  Expected format: index-url = https://username:password@host/path"
    echo "  Found: $CREDS_LINE"
    echo ""
    exit 1
fi

echo "✓ Credentials extracted successfully"
echo "  Username: $USERNAME"
echo ""

# Configure Poetry with extracted credentials
echo "Configuring Poetry for skyscanner-artifactory..."
poetry config http-basic.skyscanner-artifactory "$USERNAME" "$PASSWORD"

echo "✓ Poetry credentials configured"
echo ""

# Verify configuration
echo "Verifying Poetry configuration..."
if poetry config http-basic.skyscanner-artifactory >/dev/null 2>&1; then
    echo "✓ Poetry is configured for skyscanner-artifactory"
else
    echo "⚠ Warning: Unable to verify Poetry configuration"
fi

echo ""
echo "=========================================="
echo "Configuration Complete!"
echo "=========================================="
echo ""
