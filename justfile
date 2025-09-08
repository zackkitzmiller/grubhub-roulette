# Grubhub Roulette Chrome Extension Justfile
# Just is a command runner - https://github.com/casey/just

# Default target
default:
    @just --list

# Show help
help:
    @just --list

# Run all tests
test:
    npm test

# Run quick tests
test-quick:
    npm run test:quick

# Run syntax validation
test-syntax:
    npm run test:syntax

# Validate JSON files
test-json:
    npm run test:json

# Run linting
lint:
    npm run lint

# Validate all files
validate:
    npm run validate

# Build the extension
build:
    npm run build

# Build with specific version
build-version version:
    ./scripts/build.sh {{version}}

# Clean build artifacts
clean:
    rm -rf build/ dist/

# Setup Chrome Web Store credentials
setup-chrome-store:
    ./scripts/setup-chrome-store.sh

# Run comprehensive test suite
test-all: validate test

# Prepare for release (validate and build)
prepare-release: test-all build

# Install dependencies
install:
    npm install

# Check for outdated dependencies
outdated:
    npm outdated

# Update dependencies
update:
    npm update

# Show project information
info:
    @echo "Project Information"
    @echo "=================="
    @echo "Just version: $(just --version)"
    @echo "Node version: $(node --version)"
    @echo "NPM version: $(npm --version)"
    @echo "Extension version: $(jq -r '.version' package.json)"

# Development workflow - watch for changes and run tests
dev:
    @echo "Starting development mode..."
    @echo "Run 'just test' in another terminal to test changes"
    @echo "Use 'just build' to create a development build"

# Create a new release tag
release version:
    @echo "Creating release {{version}}..."
    git tag v{{version}}
    git push origin v{{version}}
    @echo "Release {{version}} created and pushed!"

# Show current status
status:
    @echo "Extension Status"
    @echo "==============="
    @echo "Version: $(jq -r '.version' package.json)"
    @echo "Manifest version: $(jq -r '.version' manifest.json)"
    @echo "Files:"
    @ls -la manifest.json popup.html css/ js/ icons/ 2>/dev/null || echo "Some files missing"
    @echo ""
    @echo "Build artifacts:"
    @ls -la dist/ 2>/dev/null || echo "No build artifacts found"

# Format and organize project files
format:
    @echo "Formatting project files..."
    # Format JSON files
    jq . manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json
    jq . package.json > package.json.tmp && mv package.json.tmp package.json
    @echo "✅ JSON files formatted"

# Check project health
health:
    @echo "Project Health Check"
    @echo "==================="
    @echo "Checking required files..."
    @for file in manifest.json popup.html css/popup.css js/popup.js js/content.js js/background.js; do \
        if [ -f "$$file" ]; then \
            echo "✅ $$file"; \
        else \
            echo "❌ $$file (missing)"; \
        fi; \
    done
    @echo ""
    @echo "Checking icons..."
    @for icon in icons/icon16.png icons/icon48.png icons/icon128.png; do \
        if [ -f "$$icon" ]; then \
            echo "✅ $$icon"; \
        else \
            echo "❌ $$icon (missing)"; \
        fi; \
    done
    @echo ""
    @echo "Running validation..."
    @just validate
