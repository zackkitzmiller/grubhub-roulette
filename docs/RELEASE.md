# 🚀 Release Process - Grubhub Roulette

This document outlines the complete release process for the Grubhub Roulette Chrome extension, including automated CI/CD workflows and manual release procedures.

## 📋 Prerequisites

### Chrome Web Store Developer Account

1. **Create a Chrome Web Store Developer Account**

   - Go to [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole/)
   - Pay the one-time $5 registration fee
   - Complete the developer verification process

2. **Create the Extension Listing**
   - Click "New Item" in the developer dashboard
   - Upload an initial version of the extension
   - Fill out the store listing details (name, description, screenshots, etc.)
   - Note the **Extension ID** from the URL or extension details

### GitHub Secrets Configuration

Set up the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret Name            | Description                | How to Get                                |
| ---------------------- | -------------------------- | ----------------------------------------- |
| `CHROME_EXTENSION_ID`  | Your extension's unique ID | From Chrome Web Store Developer Dashboard |
| `CHROME_CLIENT_ID`     | OAuth2 client ID           | From Google Cloud Console                 |
| `CHROME_CLIENT_SECRET` | OAuth2 client secret       | From Google Cloud Console                 |
| `CHROME_REFRESH_TOKEN` | OAuth2 refresh token       | Generated using OAuth2 flow               |

### Google Cloud Console Setup

1. **Create a Google Cloud Project**

   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one

2. **Enable Chrome Web Store API**

   - Navigate to "APIs & Services > Library"
   - Search for "Chrome Web Store API"
   - Click "Enable"

3. **Create OAuth2 Credentials**

   - Go to "APIs & Services > Credentials"
   - Click "Create Credentials > OAuth 2.0 Client IDs"
   - Choose "Web application"
   - Add authorized redirect URIs:
     - `http://localhost:8080` (for local testing)
     - `https://oauth2.googleapis.com/token` (for production)
   - Download the credentials JSON file
   - Extract `client_id` and `client_secret`

4. **Generate Refresh Token**

   ```bash
   # Install the Chrome Web Store upload tool
   npm install -g chrome-webstore-upload-cli

   # Generate refresh token
   chrome-webstore-upload-cli token --client-id YOUR_CLIENT_ID --client-secret YOUR_CLIENT_SECRET
   ```

## 🔄 Automated Release Process

### GitHub Actions Workflow

The release process is fully automated using GitHub Actions. When you create a release, the following happens:

1. **Trigger**: Create a GitHub release with a tag (e.g., `v2.0.0`)
2. **Validation**: All tests run to ensure code quality
3. **Build**: Extension is packaged into a zip file
4. **Publish**: Extension is automatically uploaded to Chrome Web Store
5. **Artifacts**: Build artifacts are attached to the GitHub release

### Creating a Release

1. **Update Version**

   ```bash
   # Update version in package.json
   npm version patch  # or minor, major

   # Or manually edit package.json
   # The workflow will sync manifest.json automatically
   ```

2. **Create GitHub Release**

   ```bash
   # Create and push a tag
   git tag v2.0.0
   git push origin v2.0.0

   # Or use GitHub CLI
   gh release create v2.0.0 --title "Version 2.0.0" --notes "Release notes here"
   ```

3. **Monitor the Workflow**
   - Go to `Actions` tab in your GitHub repository
   - Watch the "Release to Chrome Web Store" workflow
   - Check for any failures and fix them

## 🛠️ Manual Release Process

### Local Build

```bash
# Build the extension locally
npm run build

# Or with specific version
./scripts/build.sh 2.0.0
```

This creates:

- `dist/grubhub-roulette-v2.0.0.zip` - For Chrome Web Store
- `dist/grubhub-roulette-v2.0.0-unpacked/` - For development/testing

### Manual Upload to Chrome Web Store

1. **Go to Developer Dashboard**

   - Visit [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole/)

2. **Upload New Version**

   - Click on your extension
   - Click "Upload new package"
   - Select the zip file from `dist/` directory
   - Add release notes
   - Click "Submit for review"

3. **Review Process**
   - Google reviews the extension (usually 1-3 business days)
   - You'll receive email notifications about the review status
   - Once approved, the extension goes live automatically

## 📊 Release Checklist

### Pre-Release

- [ ] All tests pass (`npm test`)
- [ ] Extension works on all supported Grubhub pages
- [ ] No console errors during normal operation
- [ ] Version numbers are consistent across files
- [ ] Release notes are prepared
- [ ] Screenshots are updated (if UI changes)

### During Release

- [ ] Create GitHub release with proper tag
- [ ] Monitor GitHub Actions workflow
- [ ] Verify extension upload to Chrome Web Store
- [ ] Check that all artifacts are created

### Post-Release

- [ ] Verify extension appears in Chrome Web Store
- [ ] Test the published extension
- [ ] Update documentation if needed
- [ ] Announce the release (social media, etc.)

## 🔧 Troubleshooting

### Common Issues

1. **Workflow Fails on Validation**

   - Check that all required files exist
   - Verify JavaScript syntax with `npm run test:syntax`
   - Ensure JSON files are valid

2. **Chrome Web Store Upload Fails**

   - Verify all secrets are correctly set
   - Check that the extension ID matches
   - Ensure the refresh token is valid

3. **Version Mismatch**
   - The workflow automatically syncs versions
   - If issues persist, manually update both `package.json` and `manifest.json`

### Debug Commands

```bash
# Test the build process locally
npm run build

# Validate extension files
npm run validate

# Check JavaScript syntax
npm run test:syntax

# Run full test suite
npm test
```

## 📈 Version Management

### Semantic Versioning

We follow [Semantic Versioning](https://semver.org/) (SemVer):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (X.Y.0): New features, backward compatible
- **PATCH** (X.Y.Z): Bug fixes, backward compatible

### Version Update Process

1. **Automatic**: GitHub Actions workflow updates versions from release tags
2. **Manual**: Update `package.json` version, workflow syncs `manifest.json`

### Release Notes Template

```markdown
## What's New in v2.0.0

### ✨ New Features

- Feature 1
- Feature 2

### 🐛 Bug Fixes

- Fixed issue with restaurant selection
- Improved error handling

### 🔧 Improvements

- Enhanced UI responsiveness
- Better performance

### 📚 Documentation

- Updated installation guide
- Added troubleshooting section
```

## 🔐 Security Considerations

- Never commit secrets to the repository
- Use GitHub Secrets for sensitive data
- Regularly rotate OAuth2 credentials
- Monitor extension permissions and usage

## 📞 Support

If you encounter issues with the release process:

1. Check the [GitHub Actions logs](https://github.com/your-username/grubhub-roulette/actions)
2. Review the [Chrome Web Store Developer Documentation](https://developer.chrome.com/docs/webstore/)
3. Open an issue in the repository
4. Check the [troubleshooting section](#troubleshooting) above

---

**Happy Releasing! 🎉**
