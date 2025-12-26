#!/bin/bash
# verify-packaging.sh - Verify package build configuration

set -e

echo "=== Package Build Verification Script ==="
echo ""

# Check required files exist
echo "1. Checking configuration files..."
test -f pyproject.toml && echo "  ✓ pyproject.toml exists" || { echo "  ✗ pyproject.toml missing"; exit 1; }
test -f MANIFEST.in && echo "  ✓ MANIFEST.in exists" || { echo "  ✗ MANIFEST.in missing"; exit 1; }

echo ""
echo "2. Checking directories to package..."
test -d .claude && echo "  ✓ .claude/ exists" || { echo "  ✗ .claude/ missing"; exit 1; }
test -d scripts_shared && echo "  ✓ scripts_shared/ exists" || { echo "  ✗ scripts_shared/ missing"; exit 1; }
test -d shared_agents_usage_docs && echo "  ✓ shared_agents_usage_docs/ exists" || { echo "  ✗ shared_agents_usage_docs/ missing"; exit 1; }
test -f .specify/memory/constitution.md && echo "  ✓ .specify/memory/constitution.md exists" || { echo "  ✗ constitution.md missing"; exit 1; }

echo ""
echo "3. Counting files to be packaged..."
claude_count=$(find .claude -type f \( -name "*.md" -o -name "*.json" \) | wc -l | xargs)
scripts_count=$(find scripts_shared -type f | wc -l | xargs)
docs_count=$(find shared_agents_usage_docs -type f -name "*.md" | wc -l | xargs)

echo "  Claude Code files (.md, .json): $claude_count"
echo "  Shared scripts: $scripts_count"
echo "  Agent usage docs: $docs_count"
echo "  Constitution: 1"

total=$((claude_count + scripts_count + docs_count + 1))
echo "  Total additional files: $total"

echo ""
echo "4. Checking pyproject.toml configuration..."
if grep -q '{ include = ".claude" }' pyproject.toml; then
    echo "  ✓ .claude in packages"
else
    echo "  ✗ .claude NOT in packages"
    exit 1
fi

if grep -q '{ include = "scripts_shared" }' pyproject.toml; then
    echo "  ✓ scripts_shared in packages"
else
    echo "  ✗ scripts_shared NOT in packages"
    exit 1
fi

if grep -q '{ include = "shared_agents_usage_docs" }' pyproject.toml; then
    echo "  ✓ shared_agents_usage_docs in packages"
else
    echo "  ✗ shared_agents_usage_docs NOT in packages"
    exit 1
fi

if grep -q 'constitution.md' pyproject.toml; then
    echo "  ✓ constitution.md in include patterns"
else
    echo "  ✗ constitution.md NOT in include patterns"
    exit 1
fi

echo ""
echo "5. Checking MANIFEST.in..."
if grep -q 'recursive-include .claude' MANIFEST.in; then
    echo "  ✓ .claude pattern in MANIFEST.in"
else
    echo "  ✗ .claude pattern NOT in MANIFEST.in"
    exit 1
fi

if grep -q 'recursive-include scripts_shared' MANIFEST.in; then
    echo "  ✓ scripts_shared pattern in MANIFEST.in"
else
    echo "  ✗ scripts_shared pattern NOT in MANIFEST.in"
    exit 1
fi

if grep -q 'constitution.md' MANIFEST.in; then
    echo "  ✓ constitution.md in MANIFEST.in"
else
    echo "  ✗ constitution.md NOT in MANIFEST.in"
    exit 1
fi

echo ""
echo "✅ All packaging configuration checks passed!"
echo ""
echo "Next steps:"
echo "  1. Run: make build-verify"
echo "  2. Check dist/ directory for built packages"
echo "  3. Test installation in a virtual environment"
