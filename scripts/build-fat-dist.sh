#!/bin/bash
# Build distribution with source files and internal dependencies

set -e

echo "Building distribution..."

# Clean previous builds
rm -rf dist/ build/ fatdist/ requirements.txt

# Get version from PACKAGE_VERSION env var (passed from databricks.yaml)
if [ -n "$PACKAGE_VERSION" ]; then
    VERSION="$PACKAGE_VERSION"
    echo "Using version from PACKAGE_VERSION: $VERSION"
else
    # Get version from latest git tag
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    # If no tag found, get version from pyproject.toml
    if [ -z "$VERSION" ]; then
        echo "No git tag found, reading version from pyproject.toml..."
        VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
    fi

    # Remove 'v' prefix if present
    VERSION=${VERSION#v}

    echo "Using version: $VERSION"
fi

# Create versioned project directory
PROJECT_DIR="fatdist/skyscanner_agentic_data_engineer-${VERSION}"
mkdir -p "$PROJECT_DIR/internal"

# Download internal Skyscanner packages with their dependencies
echo "Downloading internal Skyscanner dependencies..."
poetry run pip download \
    --dest "$PROJECT_DIR/internal" \
    "skyscanner-databricks-utils>=0.2.2" \
    "skyscanner-data-knowledge-base-mcp>=1.0.7" \
    "skyscanner-spark-session-utils>=1.0.1" \
    "skyscanner-data-shared-utils>=1.0.2" 2>/dev/null || echo "Note: Some internal packages may not be available"

# Remove non-Skyscanner packages (keep only internal dependencies)
echo "Filtering to keep only Skyscanner internal dependencies..."
cd "$PROJECT_DIR/internal"
for file in *; do
    if [[ ! "$file" =~ ^skyscanner ]]; then
        echo "Removing external dependency: $file"
        rm -rf "$file"
    fi
done
cd - > /dev/null

# Extract any tarballs
echo "Extracting packages..."
cd "$PROJECT_DIR/internal"
for tarball in *.tar.gz; do
    [ -f "$tarball" ] || continue
    tar -xzf "$tarball" --strip-components=0
    rm "$tarball"
done

# Extract any wheel files to source
for wheel in *.whl; do
    [ -f "$wheel" ] || continue
    echo "Extracting $wheel to source..."
    unzip -q "$wheel" -d "${wheel%.whl}"
    rm "$wheel"
done

# Rename directories to remove version numbers and create VERSION files
for dir in */; do
    [ -d "$dir" ] || continue

    # Remove trailing slash for processing
    dir_name="${dir%/}"

    # Check if this is skyscanner-ip-ranges
    if [[ "$dir_name" =~ ^skyscanner-ip-ranges-([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        pkg_version="${BASH_REMATCH[1]}"
        echo "Renaming $dir to skyscanner_ip/ and creating VERSION file"
        echo "$pkg_version" > "${dir}VERSION"
        mv "$dir" "skyscanner_ip/"
        continue
    fi

    # Extract version from directory name
    # Pattern: package-name-version-py3-none-any/
    if [[ "$dir_name" =~ ([a-zA-Z_]+)-([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        base_name="${BASH_REMATCH[1]}"
        pkg_version="${BASH_REMATCH[2]}"

        if [ "$base_name" != "" ] && [ "$pkg_version" != "" ]; then
            echo "Renaming $dir to ${base_name}/ and creating VERSION file"

            # Create VERSION file before renaming
            echo "$pkg_version" > "${dir}VERSION"

            # Rename directory
            mv "$dir" "${base_name}/"
        fi
    fi
done

cd - > /dev/null

# Copy source files
echo "Copying project source files..."
cp -r src/* "$PROJECT_DIR/"

# Copy essential config files
echo "Copying configuration files..."
cp pyproject.toml "$PROJECT_DIR/"
cp README.md "$PROJECT_DIR/" 2>/dev/null || true
cp LICENSE "$PROJECT_DIR/" 2>/dev/null || true

# Count internal packages
INTERNAL_COUNT=$(ls -d "$PROJECT_DIR/internal"/*/ 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "✓ Build complete"
echo ""
echo "Package structure:"
echo "  fatdist/"
echo "  └── skyscanner_agentic_data_engineer-${VERSION}/"
echo "      ├── internal/              ($INTERNAL_COUNT Skyscanner dependencies - source)"
echo "      │   └── */VERSION          (version files for each package)"
echo "      ├── agentic_data_engineer/ (source files)"
echo "      └── pyproject.toml"

