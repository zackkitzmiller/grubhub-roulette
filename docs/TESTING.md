# 🧪 Grubhub Roulette - Testing Guide

This document provides comprehensive testing instructions for the Grubhub Roulette Chrome extension.

## 🚀 Quick Start Testing

### Automated Tests

```bash
# Run quick automated tests
./quick-test.sh

# Run comprehensive test suite
./test.sh

# Open functionality tests in browser
open test-functionality.html
```

## 📋 Manual Testing Checklist

### 1. Extension Installation

- [ ] Open Chrome and navigate to `chrome://extensions/`
- [ ] Enable "Developer mode" toggle
- [ ] Click "Load unpacked" and select the extension directory
- [ ] Verify extension appears in the list with correct name and version
- [ ] Check that extension icon appears in the toolbar

### 2. Page Compatibility Testing

Test the extension on these Grubhub page types:

#### ✅ Supported Pages

- [ ] `https://grubhub.com/lets-eat` - Main browsing
- [ ] `https://grubhub.com/search?queryText=pizza` - Search results
- [ ] `https://grubhub.com/delivery/new-york-ny` - Delivery listings
- [ ] `https://grubhub.com/takeout/chicago-il` - Takeout listings
- [ ] `https://www.grubhub.com/lets-eat` - WWW subdomain

#### ❌ Unsupported Pages (Should show error)

- [ ] `https://google.com` - Non-Grubhub site
- [ ] `https://grubhub.com/about` - Grubhub info page
- [ ] `https://grubhub.com` - Homepage

### 3. Core Functionality Testing

#### Basic Operation

- [ ] Click extension icon to open popup
- [ ] Verify "Spin the Wheel!" button is visible
- [ ] Click "Spin the Wheel!" button
- [ ] Verify status message appears
- [ ] Check that only one restaurant remains visible
- [ ] Verify success message shows restaurant count

#### Options Menu

- [ ] Click "⚙️ Options" to expand options
- [ ] Verify arrow rotates when expanding/collapsing
- [ ] Test each checkbox option:
  - [ ] Remove featured restaurants
  - [ ] Load more restaurants (5 attempts)
  - [ ] Aggressive loading (15 attempts)
  - [ ] Prefer regular spots over featured
- [ ] Verify options are saved between sessions

#### Error Handling

- [ ] Test on page with no restaurants (should show error)
- [ ] Test on unsupported page (should show error message)
- [ ] Test with network issues (should timeout gracefully)
- [ ] Test clicking button multiple times quickly (should prevent duplicate processing)

### 4. Advanced Feature Testing

#### Restaurant Loading

- [ ] Test with "Load more restaurants" enabled
- [ ] Test with "Aggressive loading" enabled
- [ ] Verify more restaurants are loaded before selection
- [ ] Check console logs for loading progress

#### Regular Restaurant Preference

- [ ] Enable "Prefer regular spots over featured"
- [ ] Test on page with both featured and regular restaurants
- [ ] Verify regular restaurants are preferred when available
- [ ] Test fallback when no regular restaurants exist

#### Featured Content Removal

- [ ] Test with "Remove featured restaurants" enabled
- [ ] Verify featured sections are removed before selection
- [ ] Test with option disabled (featured content should remain)

### 5. User Interface Testing

#### Popup Design

- [ ] Verify popup opens with correct size (250-300px width)
- [ ] Check that all text is readable
- [ ] Verify button styling and hover effects
- [ ] Test options toggle animation
- [ ] Check status message styling (success, error, warning)

#### Responsive Behavior

- [ ] Test popup at different screen resolutions
- [ ] Verify text doesn't overflow
- [ ] Check that all elements are accessible

### 6. Performance Testing

#### Speed Tests

- [ ] Measure time from button click to completion
- [ ] Test with large number of restaurants (50+)
- [ ] Verify no memory leaks during repeated use
- [ ] Check CPU usage during aggressive loading

#### Reliability Tests

- [ ] Run 10 consecutive spins (should work every time)
- [ ] Test after browser restart
- [ ] Test after extension reload
- [ ] Verify consistent random distribution

## 🔧 Debugging Tools

### Console Logging

The extension provides detailed console logs:

```javascript
// Enable verbose logging
console.log("[GrubhubRoulette] Starting wheel spin with options:", options);
```

### Chrome DevTools

1. Right-click extension popup → "Inspect"
2. Check Console tab for errors
3. Use Network tab to monitor requests
4. Check Application tab for storage data

### Extension Debugging

1. Go to `chrome://extensions/`
2. Click "Details" on Grubhub Roulette
3. Click "Inspect views: popup.html"
4. Use DevTools to debug popup issues

## 🐛 Common Issues & Solutions

### Extension Not Working

- **Issue**: Extension icon not clickable
- **Solution**: Reload extension in chrome://extensions/

### No Restaurants Found

- **Issue**: "No restaurant cards found" error
- **Solution**: Check if page has loaded completely, try different selectors

### Options Not Saving

- **Issue**: Preferences reset after browser restart
- **Solution**: Check chrome.storage permissions in manifest

### Random Selection Not Working

- **Issue**: Same restaurant selected repeatedly
- **Solution**: Verify Math.random() is working, check array length

## 📊 Test Results Template

```
Date: ___________
Tester: ___________
Chrome Version: ___________

✅ Installation: PASS/FAIL
✅ Page Compatibility: PASS/FAIL
✅ Core Functionality: PASS/FAIL
✅ Options Menu: PASS/FAIL
✅ Error Handling: PASS/FAIL
✅ UI/UX: PASS/FAIL
✅ Performance: PASS/FAIL

Notes:
_________________________________
_________________________________
```

## 🎯 Success Criteria

The extension passes testing if:

- ✅ All automated tests pass
- ✅ Works on all supported Grubhub page types
- ✅ Successfully selects random restaurants
- ✅ Options menu functions correctly
- ✅ Error handling works gracefully
- ✅ UI is responsive and accessible
- ✅ No console errors during normal operation
- ✅ Performance is acceptable (< 5 seconds for selection)

## 📞 Reporting Issues

When reporting bugs, include:

1. Chrome version
2. Extension version
3. Grubhub page URL
4. Steps to reproduce
5. Expected vs actual behavior
6. Console error messages
7. Screenshots if applicable
