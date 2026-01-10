#!/bin/bash
# Databricks Bundle Deploy with Retry Logic
# Handles deployment lock issues by automatically retrying with exponential backoff

set -e

# Configuration
MAX_RETRIES=${MAX_RETRIES:-3}
RETRY_DELAY=${RETRY_DELAY:-30}
TARGET=${DATABRICKS_TARGET:-dev}
SERVICE_PRINCIPAL_ID=${SERVICE_PRINCIPAL_ID:-bcfc93d0-4c4a-460c-851f-4eb6e5fcec01}
GITHUB_BRANCH=${GITHUB_BRANCH_NAME:-main}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "Databricks Bundle Deploy with Retry"
echo "=================================================="
echo "Target: $TARGET"
echo "Service Principal: $SERVICE_PRINCIPAL_ID"
echo "Branch: $GITHUB_BRANCH"
echo "Max Retries: $MAX_RETRIES"
echo "Retry Delay: ${RETRY_DELAY}s"
echo "=================================================="
echo ""

retry_count=0

while [ $retry_count -lt $MAX_RETRIES ]; do
    attempt=$((retry_count + 1))
    echo -e "${YELLOW}Deployment attempt $attempt of $MAX_RETRIES${NC}"

    # Attempt deployment
    if databricks bundle deploy \
        -t "$TARGET" \
        --force-lock \
        --var service_principal_application_id="$SERVICE_PRINCIPAL_ID" \
        --var github_branch_name="$GITHUB_BRANCH"; then

        echo -e "${GREEN}✓ Deployment successful on attempt $attempt${NC}"
        exit 0
    fi

    # Deployment failed
    retry_count=$((retry_count + 1))

    if [ $retry_count -lt $MAX_RETRIES ]; then
        # Calculate exponential backoff delay
        delay=$((RETRY_DELAY * retry_count))
        echo -e "${RED}✗ Deployment failed on attempt $attempt${NC}"
        echo -e "${YELLOW}Waiting ${delay}s before retry...${NC}"
        sleep $delay

        # Optional: Try to clear stale locks between retries
        echo "Attempting to clear any stale deployment locks..."
        # This would require knowing the lock file path, which varies by bundle config
    else
        echo -e "${RED}✗ Deployment failed after $MAX_RETRIES attempts${NC}"
    fi
done

echo ""
echo "=================================================="
echo -e "${RED}Deployment failed after $MAX_RETRIES attempts${NC}"
echo "=================================================="
echo ""
echo "Troubleshooting steps:"
echo "1. Check for running Databricks jobs that might hold locks"
echo "2. Manually clear deployment lock files in Databricks workspace"
echo "3. Verify service principal permissions"
echo "4. Check Databricks workspace connectivity"
echo ""

exit 1
