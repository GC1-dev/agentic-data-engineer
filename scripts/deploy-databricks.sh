#!/bin/bash
# Deploy to Databricks with versioned workspace folders
# This script temporarily modifies databricks.yaml to inject version into bundle name

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get version from argument or git tags
if [ -n "$1" ]; then
    VERSION="$1"
    echo -e "${GREEN}Using version from argument: $VERSION${NC}"
else
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")
    if [ -n "$VERSION" ]; then
        echo -e "${GREEN}Using version from git tag: $VERSION${NC}"
    else
        VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
        echo -e "${YELLOW}Using version from pyproject.toml: $VERSION${NC}"
    fi
fi

# Backup original databricks.yaml
cp databricks.yaml databricks.yaml.backup

# Modify bundle name to include version
sed -i.tmp "s/name: agentic-data-engineer$/name: agentic-data-engineer-${VERSION}/" databricks.yaml
rm -f databricks.yaml.tmp

echo -e "${GREEN}✓ Modified bundle name to: agentic-data-engineer-${VERSION}${NC}"
echo -e "${GREEN}✓ Deployment path: /Workspace/Users/.../agentic-data-engineer-${VERSION}/${NC}"
echo ""

# Deploy
echo -e "${YELLOW}Deploying to Databricks...${NC}"
databricks bundle deploy -t dev --force-lock \
  --var service_principal_application_id=bcfc93d0-4c4a-460c-851f-4eb6e5fcec01 \
  --var github_branch_name="${GITHUB_BRANCH:-main}" \
  --var package_version="${VERSION}"

DEPLOY_STATUS=$?

# Restore original databricks.yaml
mv databricks.yaml.backup databricks.yaml

if [ $DEPLOY_STATUS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo -e "${GREEN}✓ Deployed to: /Workspace/Users/.../agentic-data-engineer-${VERSION}/${NC}"
else
    echo ""
    echo -e "${RED}✗ Deployment failed${NC}"
    exit $DEPLOY_STATUS
fi
