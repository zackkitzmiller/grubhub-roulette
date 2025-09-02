#!/bin/bash

# Grubhub Roulette Extension Test Suite
# This script tests the extension files and provides manual testing instructions

set -e  # Exit on any error

# Navigate to project root if we're in the tests directory
if [[ $(basename "$PWD") == "tests" ]]; then
    cd ..
fi

echo "🎯 Grubhub Roulette Extension Test Suite"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"

    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        ((TESTS_PASSED++)) || true
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name: $message"
        ((TESTS_FAILED++)) || true
    fi
}

# Test 1: Check if all required files exist
echo -e "\n${BLUE}📁 Testing File Existence${NC}"
echo "-------------------------"

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

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_test_result "File exists: $file" "PASS"
    else
        print_test_result "File exists: $file" "FAIL" "File not found"
    fi
done

# Test 2: Validate JSON files
echo -e "\n${BLUE}📋 Testing JSON Validity${NC}"
echo "------------------------"

if command -v jq >/dev/null 2>&1; then
    if jq empty manifest.json 2>/dev/null; then
        print_test_result "manifest.json is valid JSON" "PASS"
    else
        print_test_result "manifest.json is valid JSON" "FAIL" "Invalid JSON syntax"
    fi
else
    echo -e "${YELLOW}⚠ Warning: jq not installed, skipping JSON validation${NC}"
fi

# Test 3: Check manifest.json structure
echo -e "\n${BLUE}🔧 Testing Manifest Structure${NC}"
echo "-----------------------------"

# Check if manifest has required fields
if grep -q '"manifest_version": 3' manifest.json; then
    print_test_result "Manifest version 3" "PASS"
else
    print_test_result "Manifest version 3" "FAIL" "Not using Manifest V3"
fi

if grep -q '"name": "Grubhub Roulette"' manifest.json; then
    print_test_result "Extension name present" "PASS"
else
    print_test_result "Extension name present" "FAIL" "Name not found"
fi

if grep -q '"permissions"' manifest.json; then
    print_test_result "Permissions defined" "PASS"
else
    print_test_result "Permissions defined" "FAIL" "No permissions found"
fi

# Test 4: Check URL patterns
echo -e "\n${BLUE}🌐 Testing URL Patterns${NC}"
echo "-----------------------"

required_patterns=(
    "grubhub.com/lets-eat"
    "grubhub.com/search"
    "grubhub.com/delivery"
    "grubhub.com/takeout"
)

for pattern in "${required_patterns[@]}"; do
    if grep -q "$pattern" manifest.json; then
        print_test_result "URL pattern: $pattern" "PASS"
    else
        print_test_result "URL pattern: $pattern" "FAIL" "Pattern not found in manifest"
    fi
done

# Test 5: Check HTML structure
echo -e "\n${BLUE}📄 Testing HTML Structure${NC}"
echo "-------------------------"

if grep -q 'id="spinWheelButton"' popup.html; then
    print_test_result "Spin button present" "PASS"
else
    print_test_result "Spin button present" "FAIL" "Button not found"
fi

if grep -q 'id="optionsToggle"' popup.html; then
    print_test_result "Options toggle present" "PASS"
else
    print_test_result "Options toggle present" "FAIL" "Options toggle not found"
fi

if grep -q 'id="status"' popup.html; then
    print_test_result "Status element present" "PASS"
else
    print_test_result "Status element present" "FAIL" "Status element not found"
fi

# Test 6: Check JavaScript syntax (basic)
echo -e "\n${BLUE}⚙️ Testing JavaScript Syntax${NC}"
echo "----------------------------"

js_files=("js/popup.js" "js/content.js" "js/background.js")

for js_file in "${js_files[@]}"; do
    if command -v node >/dev/null 2>&1; then
        if node -c "$js_file" 2>/dev/null; then
            print_test_result "JavaScript syntax: $js_file" "PASS"
        else
            print_test_result "JavaScript syntax: $js_file" "FAIL" "Syntax error detected"
        fi
    else
        echo -e "${YELLOW}⚠ Warning: Node.js not installed, skipping JS syntax check for $js_file${NC}"
    fi
done

# Test 7: Check for family-friendly content
echo -e "\n${BLUE}👨‍👩‍👧‍👦 Testing Family-Friendly Content${NC}"
echo "--------------------------------"

inappropriate_words=("bitch" "damn" "shit" "hell")
files_to_check=("popup.html" "js/popup.js" "js/content.js" "js/background.js" "README.md")

all_clean=true
for word in "${inappropriate_words[@]}"; do
    for file in "${files_to_check[@]}"; do
        if [ -f "$file" ] && grep -qi "$word" "$file"; then
            print_test_result "Family-friendly content" "FAIL" "Found '$word' in $file"
            all_clean=false
        fi
    done
done

if $all_clean; then
    print_test_result "Family-friendly content" "PASS"
fi

# Test 8: Check CSS classes exist
echo -e "\n${BLUE}🎨 Testing CSS Classes${NC}"
echo "---------------------"

css_classes=("spin-button" "options" "status-message" "option-label")

for class in "${css_classes[@]}"; do
    if grep -q "\.$class" css/popup.css; then
        print_test_result "CSS class: .$class" "PASS"
    else
        print_test_result "CSS class: .$class" "FAIL" "Class not found in CSS"
    fi
done

# Test Summary
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "==============="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Extension is ready for testing.${NC}"
    exit_code=0
else
    echo -e "\n${RED}❌ Some tests failed. Please fix the issues above.${NC}"
    exit_code=1
fi

# Manual Testing Instructions
echo -e "\n${BLUE}📋 Manual Testing Instructions${NC}"
echo "==============================="
echo "1. Load the extension in Chrome:"
echo "   - Open chrome://extensions/"
echo "   - Enable 'Developer mode'"
echo "   - Click 'Load unpacked' and select this directory"
echo ""
echo "2. Test on different Grubhub pages:"
echo "   - https://grubhub.com/lets-eat"
echo "   - https://grubhub.com/search?queryText=pizza"
echo "   - https://grubhub.com/delivery"
echo ""
echo "3. Test extension functionality:"
echo "   - Click extension icon"
echo "   - Toggle options menu"
echo "   - Try different option combinations"
echo "   - Click 'Spin the Wheel!' button"
echo "   - Verify random restaurant selection"
echo ""
echo "4. Test error handling:"
echo "   - Try on non-Grubhub pages"
echo "   - Test with no restaurants loaded"
echo "   - Test with network issues"

exit $exit_code
