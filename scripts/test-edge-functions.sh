#!/bin/bash

# Edge Functions Testing Script
# This script tests all Edge Functions locally

echo "🧪 Testing Supabase Edge Functions..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get local Supabase URL and anon key
SUPABASE_URL="http://localhost:54321"
FUNCTIONS_URL="$SUPABASE_URL/functions/v1"

# You'll need to set this to your local anon key
# Run 'supabase status' to get it
ANON_KEY="${SUPABASE_ANON_KEY:-your-local-anon-key}"

# Test user token (you'll need a valid JWT token)
AUTH_TOKEN="${TEST_AUTH_TOKEN:-$ANON_KEY}"

echo "Using Functions URL: $FUNCTIONS_URL"
echo ""

# Function to test an endpoint
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    
    echo -n "Testing $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X GET \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            "$FUNCTIONS_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X POST \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$FUNCTIONS_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Success${NC} (HTTP $http_code)"
        echo "Response: $body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}✗ Failed${NC} (HTTP $http_code)"
        echo "Error: $body"
    fi
    echo ""
}

echo "=== Token Management Tests ==="
test_endpoint "Token Balance" "GET" "/token-balance" ""
test_endpoint "Daily Token Claim" "POST" "/token-daily-claim" "{}"

echo "=== Fortune Generation Tests ==="
test_endpoint "Daily Fortune" "POST" "/fortune-daily" '{
    "name": "테스트 사용자",
    "birthDate": "1990-01-01"
}'

test_endpoint "MBTI Fortune" "POST" "/fortune-mbti" '{
    "name": "테스트 사용자",
    "mbtiType": "INTJ"
}'

test_endpoint "Zodiac Fortune" "POST" "/fortune-zodiac" '{
    "name": "테스트 사용자",
    "zodiacSign": "Aries"
}'

echo "=== Payment Tests ==="
test_endpoint "Verify Purchase" "POST" "/payment-verify-purchase" '{
    "platform": "ios",
    "productId": "com.beyond.fortune.tokens10",
    "transactionId": "test-transaction-123",
    "transactionReceipt": "dummy-receipt"
}'

echo ""
echo "🎯 Testing complete!"
echo ""
echo "Next steps:"
echo "1. Check the logs: supabase functions logs --tail"
echo "2. Fix any failing tests"
echo "3. Deploy to production: supabase functions deploy"