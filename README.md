# Grubhub Roulette Chrome Extension

[![Tests](https://github.com/zackkitzmiller/grubhub-roulette/actions/workflows/test.yml/badge.svg)](https://github.com/zackkitzmiller/grubhub-roulette/actions/workflows/test.yml)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/zackkitzmiller/grubhub-roulette)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A robust Chrome extension that randomly selects a restaurant from Grubhub listings when you can't decide what to eat!

## Features

### 🎯 Core Functionality

- **Random Restaurant Selection**: Picks one restaurant from all available options on Grubhub pages
- **Smart Content Filtering**: Removes featured/promotional content for better randomization
- **Auto Load More**: Automatically loads additional restaurants for more options

### 🛡️ Robustness Improvements

- **Fallback Selectors**: Multiple selector strategies to handle DOM changes
- **Comprehensive Error Handling**: Graceful degradation with user-friendly error messages
- **Race Condition Prevention**: Proper async/await patterns with timeout mechanisms
- **Page Validation**: Ensures extension only runs on supported Grubhub pages

### 🎨 Enhanced User Experience

- **Loading Indicators**: Visual feedback during processing
- **Status Messages**: Success/error notifications with auto-hide
- **Configuration Options**: Toggle featured content removal and auto-load
- **Improved UI**: Modern, responsive design with better accessibility

### 🔧 Technical Improvements

- **Class-based Architecture**: Organized, maintainable code structure
- **Proper Logging**: Structured logging for debugging
- **Storage Integration**: Saves user preferences
- **Timeout Handling**: Prevents hanging operations

## Supported Pages

The extension works on these Grubhub page types:

- `/lets-eat*` - Main restaurant browsing
- `/restaurant*` - Individual restaurant pages
- `/delivery*` - Delivery listings
- `/takeout*` - Takeout listings
- `/search*` - Search results pages

## Project Structure

```text
grubhub-roulette/
├── manifest.json          # Extension manifest
├── popup.html             # Extension popup UI
├── js/                    # JavaScript files
│   ├── popup.js           # Popup functionality
│   ├── content.js         # Content script
│   └── background.js      # Background service worker
├── css/                   # Stylesheets
│   └── popup.css          # Popup styling
├── icons/                 # Extension icons
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
├── tests/                 # Test scripts
│   ├── test.sh            # Comprehensive tests
│   ├── quick-test.sh      # Quick validation
│   └── test-functionality.html
├── docs/                  # Documentation
│   └── TESTING.md         # Testing guide
└── README.md
```

## Installation

1. Clone or download this repository
2. Open Chrome and navigate to `chrome://extensions/`
3. Enable "Developer mode" in the top right
4. Click "Load unpacked" and select the extension directory
5. Navigate to a supported Grubhub page and click the extension icon

## Development

This project uses [Just](https://github.com/casey/just) as the command runner instead of npm scripts. Install Just and run `just --list` to see all available commands.

```bash
# Install Just (if not already installed)
# On macOS: brew install just
# On Linux: curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash

# See all available commands
just --list

# Run tests
just test

# Build the extension
just build
```

## Usage

1. **Navigate** to any supported Grubhub page with restaurant listings
2. **Click** the Grubhub Roulette extension icon in your browser toolbar
3. **Configure** options (optional):
   - Remove featured restaurants: Filters out promoted content
   - Load more restaurants: Automatically loads additional options
4. **Click** "Spin the Wheel!" to randomly select a restaurant
5. **Enjoy** your randomly selected meal!

## Configuration Options

### Remove Featured Restaurants

When enabled (default), removes promotional and featured restaurant sections to ensure truly random selection from regular listings.

### Load More Restaurants

When enabled (default), automatically clicks "Load More" buttons to expand the available restaurant pool before making a selection.

## Error Handling

The extension includes comprehensive error handling for common scenarios:

- **Page Not Supported**: Clear message if not on a Grubhub page
- **No Restaurants Found**: Handles empty or loading pages gracefully
- **Network Issues**: Timeout handling for slow-loading content
- **DOM Changes**: Fallback selectors for site updates

## Technical Architecture

### Content Script (`content.js`)

- `GrubhubRoulette`: Main class handling restaurant selection logic
- `SelectorManager`: Robust element selection with fallback strategies
- `Logger`: Structured logging for debugging and monitoring

### Popup (`popup.js`, `popup.html`, `popup.css`)

- `PopupController`: Manages UI interactions and user preferences
- Modern, responsive design with status feedback
- Configuration options with persistent storage

### Background Script (`background.js`)

- `BackgroundService`: Handles extension lifecycle events
- Installation and update management

## Browser Compatibility

- Chrome 88+ (Manifest V3 support)
- Edge 88+ (Chromium-based)

## Version History

### v2.0 (Current)

- Complete rewrite with robust architecture
- Added fallback selectors and error handling
- Enhanced UI with configuration options
- Improved page validation and timeout handling
- Added user preference storage

### v1.0 (Original)

- Basic random restaurant selection
- Simple DOM manipulation
- Limited error handling

## Building and Releasing

### Local Build

```bash
# Build the extension for Chrome Web Store
just build

# Build with specific version
just build-version 2.0.0
```

This creates:

- `dist/grubhub-roulette-v2.0.0.zip` - For Chrome Web Store submission
- `dist/grubhub-roulette-v2.0.0-unpacked/` - For development/testing

### Automated Release

The extension uses GitHub Actions for automated releases to the Chrome Web Store:

1. **Create a GitHub Release** with a version tag (e.g., `v2.0.0`)
2. **The workflow automatically**:
   - Validates the extension
   - Builds the package
   - Uploads to Chrome Web Store
   - Creates release artifacts

### Setup for Automated Publishing

1. **Chrome Web Store Developer Account** ($5 one-time fee)
2. **Google Cloud Console** project with Chrome Web Store API enabled
3. **GitHub Secrets** configured with OAuth2 credentials

See [docs/RELEASE.md](docs/RELEASE.md) for detailed setup instructions and complete release process documentation.

## Testing

### Automated Testing

The extension includes comprehensive automated tests that run on every commit:

```bash
# Run quick tests
just test-quick

# Run full test suite
just test

# Check JavaScript syntax only
just test-syntax

# Validate JSON files
just test-json
```

### Continuous Integration

All tests run automatically via GitHub Actions on:

- Every push to main/master/develop branches
- Every pull request
- Manual workflow dispatch

The CI pipeline validates:

- ✅ File structure and existence
- ✅ JavaScript syntax
- ✅ JSON validity
- ✅ Extension manifest requirements
- ✅ Family-friendly content
- ✅ CSS/HTML structure
- ✅ URL pattern support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with proper error handling
4. **Run tests locally**: `just test`
5. Test on multiple Grubhub page types
6. Submit a pull request (tests will run automatically)

## License

MIT License - feel free to modify and distribute!
