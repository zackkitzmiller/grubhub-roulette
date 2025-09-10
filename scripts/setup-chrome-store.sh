#!/bin/bash

# Chrome Web Store Setup Helper Script
# Helps configure the necessary credentials for automated publishing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Chrome Web Store Setup Helper${NC}"
echo "=================================="

echo -e "\n${YELLOW}This script will help you set up the necessary credentials for automated Chrome Web Store publishing.${NC}"

# Check if required tools are installed
echo -e "\n${BLUE}📋 Checking Prerequisites${NC}"
echo "------------------------"

if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
else
    echo -e "${GREEN}✓${NC} Node.js is installed"
fi

if ! command -v npm >/dev/null 2>&1; then
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
else
    echo -e "${GREEN}✓${NC} npm is installed"
fi

# Install chrome-webstore-upload-cli if not present
if ! command -v chrome-webstore-upload-cli >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Installing chrome-webstore-upload-cli...${NC}"
    npm install -g chrome-webstore-upload-cli
    echo -e "${GREEN}✓${NC} chrome-webstore-upload-cli installed"
else
    echo -e "${GREEN}✓${NC} chrome-webstore-upload-cli is already installed"
fi

echo -e "\n${BLUE}📝 Setup Instructions${NC}"
echo "====================="

echo -e "\n${YELLOW}1. Chrome Web Store Developer Account${NC}"
echo "   - Go to: https://chrome.google.com/webstore/devconsole/"
echo "   - Pay the $5 registration fee"
echo "   - Create your extension listing"
echo "   - Note your Extension ID from the URL"

echo -e "\n${YELLOW}2. Google Cloud Console Setup${NC}"
echo "   - Go to: https://console.cloud.google.com/"
echo "   - Create a new project or select existing"
echo "   - Enable 'Chrome Web Store API'"
echo "   - Create OAuth 2.0 credentials"
echo "   - Download the credentials JSON file"

echo -e "\n${YELLOW}3. Generate Refresh Token${NC}"
echo "   Run this command with your credentials:"
echo -e "   ${GREEN}chrome-webstore-upload-cli token --client-id YOUR_CLIENT_ID --client-secret YOUR_CLIENT_SECRET${NC}"

echo -e "\n${YELLOW}4. GitHub Secrets Configuration${NC}"
echo "   Go to your repository: Settings > Secrets and variables > Actions"
echo "   Add these secrets:"
echo "   - CHROME_EXTENSION_ID: Your extension ID"
echo "   - CHROME_CLIENT_ID: From Google Cloud Console"
echo "   - CHROME_CLIENT_SECRET: From Google Cloud Console"
echo "   - CHROME_REFRESH_TOKEN: Generated in step 3"

echo -e "\n${BLUE}🧪 Test Your Setup${NC}"
echo "=================="

read -p "Do you want to test your setup now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Testing Chrome Web Store connection...${NC}"

    # Check if secrets are available (this won't work in CI, but helpful for local testing)
    if [ -n "$CHROME_EXTENSION_ID" ] && [ -n "$CHROME_CLIENT_ID" ] && [ -n "$CHROME_CLIENT_SECRET" ] && [ -n "$CHROME_REFRESH_TOKEN" ]; then
        echo -e "${GREEN}✓${NC} Environment variables are set"
        echo "You can test the connection by running:"
        echo -e "${GREEN}chrome-webstore-upload-cli info --extension-id $CHROME_EXTENSION_ID --client-id $CHROME_CLIENT_ID --client-secret $CHROME_CLIENT_SECRET --refresh-token $CHROME_REFRESH_TOKEN${NC}"
    else
        echo -e "${YELLOW}⚠${NC} Environment variables not set"
        echo "Set them manually or configure GitHub Secrets"
    fi
fi

echo -e "\n${BLUE}📚 Additional Resources${NC}"
echo "======================="
echo "• Chrome Web Store Developer Documentation: https://developer.chrome.com/docs/webstore/"
echo "• Google Cloud Console: https://console.cloud.google.com/"
echo "• GitHub Actions Documentation: https://docs.github.com/en/actions"
echo "• This project's release documentation: docs/RELEASE.md"

echo -e "\n${GREEN}🎉 Setup complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Complete the setup steps above"
echo "2. Create a GitHub release to trigger the automated publishing"
echo "3. Monitor the GitHub Actions workflow for any issues"

echo -e "\n${BLUE}Need help?${NC}"
echo "• Check docs/RELEASE.md for detailed instructions"
echo "• Open an issue in the repository"
echo "• Review the GitHub Actions logs if the workflow fails"
