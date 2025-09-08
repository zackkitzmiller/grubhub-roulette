#!/bin/bash

# Grubhub Roulette Extension Build Script
# Builds the extension for Chrome Web Store submission

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️ Grubhub Roulette Extension Build Script${NC}"
echo "=============================================="

# Get version from package.json or use provided version
if [ -n "$1" ]; then
    VERSION="$1"
    echo -e "${YELLOW}Using provided version: $VERSION${NC}"
else
    if command -v jq >/dev/null 2>&1; then
        VERSION=$(jq -r '.version' package.json)
        echo -e "${YELLOW}Using version from package.json: $VERSION${NC}"
    else
        echo -e "${RED}❌ No version provided and jq not available${NC}"
        echo "Usage: $0 <version>"
        echo "Example: $0 2.0.0"
        exit 1
    fi
fi

# Validate version format (semantic versioning)
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Invalid version format: $VERSION${NC}"
    echo "Version must be in format: X.Y.Z (e.g., 2.0.0)"
    exit 1
fi

echo -e "\n${BLUE}📋 Pre-build Validation${NC}"
echo "------------------------"

# Check required files
required_files=(
    "manifest.json"
    "popup.html"
    "css/popup.css"
    "js/popup.js"
    "js/content.js"
    "js/background.js"
    "icons/icon16.png"
    "icons/icon48.png"
    "icons/icon128.png"
)

echo "Checking required files..."
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file (missing)"
        exit 1
    fi
done

# Validate JSON syntax
echo -e "\nValidating JSON files..."
if command -v jq >/dev/null 2>&1; then
    if jq empty manifest.json 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} manifest.json is valid JSON"
    else
        echo -e "  ${RED}✗${NC} manifest.json has invalid JSON syntax"
        exit 1
    fi
else
    echo -e "  ${YELLOW}⚠${NC} jq not available, skipping JSON validation"
fi

# Check JavaScript syntax
echo -e "\nValidating JavaScript syntax..."
js_files=("js/popup.js" "js/content.js" "js/background.js")
for js_file in "${js_files[@]}"; do
    if command -v node >/dev/null 2>&1; then
        if node -c "$js_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $js_file"
        else
            echo -e "  ${RED}✗${NC} $js_file (syntax error)"
            exit 1
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} Node.js not available, skipping JS syntax check for $js_file"
    fi
done

echo -e "\n${BLUE}🏗️ Building Extension${NC}"
echo "----------------------"

# Create build directory
BUILD_DIR="build"
DIST_DIR="dist"

echo "Creating build directories..."
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Copy files to build directory
echo "Copying extension files..."
cp manifest.json "$BUILD_DIR/"
cp popup.html "$BUILD_DIR/"
cp -r css/ "$BUILD_DIR/"
cp -r js/ "$BUILD_DIR/"
cp -r icons/ "$BUILD_DIR/"

# Update version in manifest.json if needed
if command -v jq >/dev/null 2>&1; then
    current_version=$(jq -r '.version' "$BUILD_DIR/manifest.json")
    if [ "$current_version" != "$VERSION" ]; then
        echo "Updating version in manifest.json from $current_version to $VERSION"
        jq --arg version "$VERSION" '.version = $version' "$BUILD_DIR/manifest.json" > "$BUILD_DIR/manifest.json.tmp"
        mv "$BUILD_DIR/manifest.json.tmp" "$BUILD_DIR/manifest.json"
    fi
fi

# Create zip file for Chrome Web Store
ZIP_NAME="grubhub-roulette-v${VERSION}.zip"
echo "Creating zip file: $ZIP_NAME"

cd "$BUILD_DIR"
zip -r "../$DIST_DIR/$ZIP_NAME" . -x "*.DS_Store" "*.git*" "*.md" "tests/*" "docs/*" ".github/*" "scripts/*"
cd ..

# Create unpacked directory for development
UNPACKED_DIR="grubhub-roulette-v${VERSION}-unpacked"
echo "Creating unpacked directory: $UNPACKED_DIR"
cp -r "$BUILD_DIR" "$DIST_DIR/$UNPACKED_DIR"

echo -e "\n${BLUE}📦 Build Summary${NC}"
echo "=================="
echo -e "Version: ${GREEN}$VERSION${NC}"
echo -e "Build directory: ${GREEN}$BUILD_DIR/${NC}"
echo -e "Distribution directory: ${GREEN}$DIST_DIR/${NC}"
echo -e "Chrome Web Store package: ${GREEN}$DIST_DIR/$ZIP_NAME${NC}"
echo -e "Unpacked extension: ${GREEN}$DIST_DIR/$UNPACKED_DIR/${NC}"

# Show package contents
echo -e "\n${BLUE}📋 Package Contents${NC}"
echo "-------------------"
unzip -l "$DIST_DIR/$ZIP_NAME" | head -20
echo "..."

# Calculate file sizes
ZIP_SIZE=$(du -h "$DIST_DIR/$ZIP_NAME" | cut -f1)
echo -e "\nPackage size: ${GREEN}$ZIP_SIZE${NC}"

echo -e "\n${GREEN}🎉 Build completed successfully!${NC}"
echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo "1. Test the unpacked extension: $DIST_DIR/$UNPACKED_DIR/"
echo "2. Submit to Chrome Web Store: $DIST_DIR/$ZIP_NAME"
echo "3. Load unpacked extension in Chrome for testing:"
echo "   - Go to chrome://extensions/"
echo "   - Enable 'Developer mode'"
echo "   - Click 'Load unpacked' and select: $DIST_DIR/$UNPACKED_DIR/"
