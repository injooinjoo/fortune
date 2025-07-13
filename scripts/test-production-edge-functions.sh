#!/bin/bash

# Production Edge Functions Testing Script

echo "🚀 Testing Production Supabase Edge Functions..."

# Production configuration
SUPABASE_URL="https://hayjukwfcsdmppairazc.supabase.co"
FUNCTIONS_URL="$SUPABASE_URL/functions/v1"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheWp1a3dmY3NkbXBwYWlyYXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxMDIyNzUsImV4cCI6MjA2MzY3ODI3NX0.nV--LlLk8VOUyz0Vmu_26dRn1vRD9WFxPg0BIYS7ct0"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Using Production Functions URL: $FUNCTIONS_URL"
echo ""

# Test CORS preflight
echo "=== Testing CORS Preflight ==="
echo -n "Testing OPTIONS request... "
response=$(curl -s -w "\n%{http_code}" -X OPTIONS \
    -H "Origin: http://localhost:3000" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: authorization,content-type" \
    "$FUNCTIONS_URL/token-balance")

http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ CORS OK${NC}"
else
    echo -e "${RED}✗ CORS Failed${NC} (HTTP $http_code)"
fi
echo ""

# Test token balance without auth (should fail)
echo "=== Testing Authentication ==="
echo -n "Testing without auth token... "
response=$(curl -s -w "\n%{http_code}" -X GET \
    "$FUNCTIONS_URL/token-balance")

http_code=$(echo "$response" | tail -n1)
if [ "$http_code" = "401" ]; then
    echo -e "${GREEN}✓ Correctly rejected${NC} (HTTP 401)"
else
    echo -e "${YELLOW}⚠ Unexpected response${NC} (HTTP $http_code)"
fi

# Test with anon key
echo -n "Testing with anon key... "
response=$(curl -s -w "\n%{http_code}" -X GET \
    -H "Authorization: Bearer $ANON_KEY" \
    -H "apikey: $ANON_KEY" \
    "$FUNCTIONS_URL/token-balance")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ] || [ "$http_code" = "401" ]; then
    echo -e "${GREEN}✓ Response received${NC} (HTTP $http_code)"
    echo "Response: $body" | jq '.' 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Failed${NC} (HTTP $http_code)"
    echo "Error: $body"
fi
echo ""

# Test daily fortune
echo "=== Testing Fortune Generation ==="
echo -n "Testing daily fortune endpoint... "
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Authorization: Bearer $ANON_KEY" \
    -H "apikey: $ANON_KEY" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "테스트 사용자",
        "birthDate": "1990-01-01"
    }' \
    "$FUNCTIONS_URL/fortune-daily")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ] || [ "$http_code" = "401" ] || [ "$http_code" = "402" ]; then
    echo -e "${GREEN}✓ Response received${NC} (HTTP $http_code)"
    echo "Response preview:" 
    echo "$body" | jq '.' 2>/dev/null | head -20 || echo "$body" | head -20
else
    echo -e "${RED}✗ Failed${NC} (HTTP $http_code)"
    echo "Error: $body"
fi
echo ""

echo "=== Function Status ==="
echo "View logs at: https://supabase.com/dashboard/project/hayjukwfcsdmppairazc/functions"
echo ""
echo "To check logs via CLI:"
echo "  supabase functions logs token-balance --tail"
echo "  supabase functions logs fortune-daily --tail"
echo ""

echo "✅ Production testing complete!"