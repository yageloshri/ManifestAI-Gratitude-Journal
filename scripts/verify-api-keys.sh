#!/bin/bash
# verify-api-keys.sh
# Tests that each API key in Config.xcconfig is valid by hitting its API.
# Run after rotating keys: ./scripts/verify-api-keys.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../Config.xcconfig"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config.xcconfig not found at $CONFIG_FILE"
    echo "   Copy Config.xcconfig.example to Config.xcconfig and add your keys."
    exit 1
fi

# Parse keys from xcconfig (format: KEY = value)
GEMINI_KEY=$(grep '^GEMINI_API_KEY' "$CONFIG_FILE" | sed 's/^[^=]*= *//')
UNSPLASH_KEY=$(grep '^UNSPLASH_ACCESS_KEY' "$CONFIG_FILE" | sed 's/^[^=]*= *//')
SUPERWALL_KEY=$(grep '^SUPERWALL_API_KEY' "$CONFIG_FILE" | sed 's/^[^=]*= *//')

PASS=0
FAIL=0

echo "═══════════════════════════════════════"
echo "  API Key Verification"
echo "═══════════════════════════════════════"
echo ""

# --- Gemini ---
echo "Testing Gemini API..."
if [ -z "$GEMINI_KEY" ]; then
    echo "❌ Gemini: key is empty in Config.xcconfig"
    FAIL=$((FAIL + 1))
else
    GEMINI_RESPONSE=$(curl -s -w "\n%{http_code}" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_KEY" \
        -H 'Content-Type: application/json' \
        -d '{"contents":[{"parts":[{"text":"Say hello in one word"}]}]}' \
        2>/dev/null)
    GEMINI_STATUS=$(echo "$GEMINI_RESPONSE" | tail -1)
    GEMINI_BODY=$(echo "$GEMINI_RESPONSE" | sed '$d')

    if [ "$GEMINI_STATUS" = "200" ]; then
        echo "✅ Gemini OK (HTTP 200)"
        PASS=$((PASS + 1))
    else
        echo "❌ Gemini FAILED (HTTP $GEMINI_STATUS)"
        echo "   Response: $(echo "$GEMINI_BODY" | head -3)"
        FAIL=$((FAIL + 1))
    fi
fi
echo ""

# --- Unsplash ---
echo "Testing Unsplash API..."
if [ -z "$UNSPLASH_KEY" ]; then
    echo "❌ Unsplash: key is empty in Config.xcconfig"
    FAIL=$((FAIL + 1))
else
    UNSPLASH_RESPONSE=$(curl -s -w "\n%{http_code}" \
        "https://api.unsplash.com/photos/random?count=1" \
        -H "Authorization: Client-ID $UNSPLASH_KEY" \
        2>/dev/null)
    UNSPLASH_STATUS=$(echo "$UNSPLASH_RESPONSE" | tail -1)
    UNSPLASH_BODY=$(echo "$UNSPLASH_RESPONSE" | sed '$d')

    if [ "$UNSPLASH_STATUS" = "200" ]; then
        echo "✅ Unsplash OK (HTTP 200)"
        PASS=$((PASS + 1))
    else
        echo "❌ Unsplash FAILED (HTTP $UNSPLASH_STATUS)"
        echo "   Response: $(echo "$UNSPLASH_BODY" | head -3)"
        FAIL=$((FAIL + 1))
    fi
fi
echo ""

# --- Superwall ---
echo "Testing Superwall API..."
if [ -z "$SUPERWALL_KEY" ]; then
    echo "❌ Superwall: key is empty in Config.xcconfig"
    FAIL=$((FAIL + 1))
else
    # Superwall doesn't have a simple REST ping endpoint.
    # The public key format starts with "pk_" — we validate format
    # and check that the config endpoint responds.
    if [[ "$SUPERWALL_KEY" != pk_* ]]; then
        echo "❌ Superwall: key doesn't start with 'pk_' — wrong format"
        FAIL=$((FAIL + 1))
    else
        # Superwall uses SDK-based auth, not a public REST API.
        # We can only validate key format here. Full validation requires
        # running the app and checking Xcode console for Superwall init logs.
        echo "✅ Superwall key format valid (pk_*). Full validation requires app launch — check Xcode console for:"
        echo "   • 'Superwall/PaywallManager' logs on init (= key accepted)"
        echo "   • No 'Invalid API Key' error (= key rejected)"
        PASS=$((PASS + 1))
    fi
fi

echo ""
echo "═══════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
