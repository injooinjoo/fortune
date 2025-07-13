#!/bin/bash

# Health Check Script for Fortune API
# Usage: ./scripts/health-check.sh [service-url]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get service URL from argument or Cloud Run
if [ -n "$1" ]; then
    SERVICE_URL="$1"
else
    SERVICE_NAME="fortune-api"
    REGION="asia-northeast3"
    SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)' 2>/dev/null)
    
    if [ -z "$SERVICE_URL" ]; then
        echo -e "${RED}❌ Error: Could not get service URL${NC}"
        echo "Usage: ./scripts/health-check.sh [service-url]"
        exit 1
    fi
fi

echo -e "${GREEN}🏥 Fortune API Health Check${NC}"
echo -e "${BLUE}Service URL: ${SERVICE_URL}${NC}"
echo ""

# Function to check endpoint
check_endpoint() {
    local endpoint=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -n "Checking ${description}... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "${SERVICE_URL}${endpoint}")
    
    if [ "$response" == "$expected_status" ]; then
        echo -e "${GREEN}✓ OK (${response})${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed (${response})${NC}"
        return 1
    fi
}

# Function to check authenticated endpoint
check_auth_endpoint() {
    local endpoint=$1
    local description=$2
    local token=$3
    
    echo -n "Checking ${description}... "
    
    if [ -z "$token" ]; then
        echo -e "${YELLOW}⚠️  Skipped (no auth token)${NC}"
        return 0
    fi
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer ${token}" "${SERVICE_URL}${endpoint}")
    
    if [ "$response" == "200" ]; then
        echo -e "${GREEN}✓ OK (${response})${NC}"
        return 0
    elif [ "$response" == "401" ]; then
        echo -e "${YELLOW}⚠️  Unauthorized (check token)${NC}"
        return 1
    else
        echo -e "${RED}✗ Failed (${response})${NC}"
        return 1
    fi
}

# Start health checks
echo -e "${BLUE}🔍 Running health checks...${NC}"
echo ""

# Basic connectivity
check_endpoint "/health" "Health endpoint"
check_endpoint "/api/v1" "API root"
check_endpoint "/api/v1/docs" "API documentation"

echo ""
echo -e "${BLUE}🔍 Checking public endpoints...${NC}"
echo ""

# Public endpoints
check_endpoint "/api/v1/auth/session" "Auth session check" "401"
check_endpoint "/nonexistent" "404 error handling" "404"

echo ""
echo -e "${BLUE}🔍 Checking authenticated endpoints...${NC}"
echo ""

# Check if auth token is provided
if [ -n "$AUTH_TOKEN" ]; then
    check_auth_endpoint "/api/v1/user/profile" "User profile" "$AUTH_TOKEN"
    check_auth_endpoint "/api/v1/token/balance" "Token balance" "$AUTH_TOKEN"
    check_auth_endpoint "/api/v1/fortune/daily" "Daily fortune" "$AUTH_TOKEN"
else
    echo -e "${YELLOW}ℹ️  Set AUTH_TOKEN environment variable to test authenticated endpoints${NC}"
    echo "   Example: AUTH_TOKEN=your-jwt-token ./scripts/health-check.sh"
fi

echo ""
echo -e "${BLUE}📊 Performance check...${NC}"
echo ""

# Measure response time
echo -n "Measuring response time... "
response_time=$(curl -s -o /dev/null -w "%{time_total}" "${SERVICE_URL}/health")
response_time_ms=$(echo "$response_time * 1000" | bc | cut -d. -f1)

if [ "$response_time_ms" -lt 200 ]; then
    echo -e "${GREEN}✓ Excellent (${response_time_ms}ms)${NC}"
elif [ "$response_time_ms" -lt 500 ]; then
    echo -e "${YELLOW}⚠️  Good (${response_time_ms}ms)${NC}"
else
    echo -e "${RED}✗ Slow (${response_time_ms}ms)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Health check completed!${NC}"
echo ""

# Additional information
echo -e "${BLUE}📋 Additional commands:${NC}"
echo "View logs: gcloud logging read 'resource.type=cloud_run_revision' --limit 50"
echo "View metrics: gcloud monitoring dashboards list"
echo "Test with curl: curl -H 'Authorization: Bearer YOUR_TOKEN' ${SERVICE_URL}/api/v1/user/profile"