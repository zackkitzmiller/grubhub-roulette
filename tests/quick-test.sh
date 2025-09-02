#!/bin/bash

# Quick Test for Grubhub Roulette Extension (Organized Structure)
echo "🎯 Grubhub Roulette - Quick Test"
echo "================================"

# Navigate to project root
cd "$(dirname "$0")/.."

# Test 1: Check required files
echo "📁 Checking files..."
files=("manifest.json" "popup.html" "css/popup.css" "js/popup.js" "js/content.js" "js/background.js")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
    fi
done

# Test 2: Check icons
echo -e "\n🖼️ Checking icons..."
icons=("icons/icon16.png" "icons/icon48.png" "icons/icon128.png")
for icon in "${icons[@]}"; do
    if [ -f "$icon" ]; then
        echo "✓ $icon exists"
    else
        echo "✗ $icon missing"
    fi
done

# Test 3: Check manifest.json
echo -e "\n📋 Checking manifest..."
if grep -q '"manifest_version": 3' manifest.json; then
    echo "✓ Manifest V3"
else
    echo "✗ Not Manifest V3"
fi

if grep -q '"name": "Grubhub Roulette"' manifest.json; then
    echo "✓ Extension name correct"
else
    echo "✗ Extension name incorrect"
fi

# Test 4: Check for search URL support
echo -e "\n🔍 Checking search support..."
if grep -q "grubhub.com/search" manifest.json; then
    echo "✓ Search URLs supported"
else
    echo "✗ Search URLs not supported"
fi

# Test 5: Check for family-friendly content
echo -e "\n👨‍👩‍👧‍👦 Checking family-friendly content..."
if grep -qi "spin the wheel" popup.html; then
    echo "✓ Family-friendly button text"
else
    echo "✗ Button text needs review"
fi

# Test 6: Check JavaScript syntax (if Node.js available)
echo -e "\n⚙️ Checking JavaScript..."
if command -v node >/dev/null 2>&1; then
    for js_file in js/popup.js js/content.js js/background.js; do
        if node -c "$js_file" 2>/dev/null; then
            echo "✓ $js_file syntax OK"
        else
            echo "✗ $js_file has syntax errors"
        fi
    done
else
    echo "⚠ Node.js not available, skipping JS syntax check"
fi

# Test 7: Check folder structure
echo -e "\n📂 Checking folder structure..."
folders=("js" "css" "icons" "tests" "docs")
for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        echo "✓ $folder/ directory exists"
    else
        echo "✗ $folder/ directory missing"
    fi
done

echo -e "\n🎉 Quick test complete!"
echo -e "\n📋 Manual Testing Steps:"
echo "1. Load extension in Chrome (chrome://extensions/)"
echo "2. Enable Developer mode"
echo "3. Click 'Load unpacked' and select this directory"
echo "4. Test on: https://grubhub.com/search?queryText=pizza"
echo "5. Click extension icon and try 'Spin the Wheel!'"
