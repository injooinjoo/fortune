#!/bin/bash

# Environment Variables Setup Script for Cloud Run
# Usage: ./scripts/setup-env.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="fortune-api"
REGION="asia-northeast3"

echo -e "${GREEN}🔐 Fortune API Environment Variables Setup${NC}"
echo ""

# Function to set environment variable
set_env_var() {
    local var_name=$1
    local var_description=$2
    local is_secret=$3
    
    echo -e "${BLUE}📝 ${var_description}${NC}"
    
    if [ "$is_secret" == "true" ]; then
        echo -n "Enter value for ${var_name} (hidden): "
        read -s var_value
        echo ""
    else
        echo -n "Enter value for ${var_name}: "
        read var_value
    fi
    
    if [ -z "$var_value" ]; then
        echo -e "${YELLOW}⚠️  Skipping ${var_name} (no value provided)${NC}"
    else
        ENV_VARS="${ENV_VARS} --update-env-vars=${var_name}=${var_value}"
        echo -e "${GREEN}✓ ${var_name} set${NC}"
    fi
    echo ""
}

# Function to set secret from Secret Manager
set_secret() {
    local secret_name=$1
    local env_var_name=$2
    local description=$3
    
    echo -e "${BLUE}🔒 ${description}${NC}"
    echo -n "Enter value for ${secret_name} (hidden): "
    read -s secret_value
    echo ""
    
    if [ -z "$secret_value" ]; then
        echo -e "${YELLOW}⚠️  Skipping ${secret_name} (no value provided)${NC}"
    else
        # Create or update secret in Secret Manager
        echo -n "$secret_value" | gcloud secrets create ${secret_name} --data-file=- 2>/dev/null || \
        echo -n "$secret_value" | gcloud secrets versions add ${secret_name} --data-file=-
        
        # Add to Cloud Run update command
        SECRETS="${SECRETS} --update-secrets=${env_var_name}=${secret_name}:latest"
        echo -e "${GREEN}✓ ${secret_name} stored in Secret Manager${NC}"
    fi
    echo ""
}

# Initialize variables
ENV_VARS=""
SECRETS=""

echo -e "${YELLOW}Choose setup method:${NC}"
echo "1) Quick setup (environment variables only)"
echo "2) Secure setup (using Secret Manager for sensitive data)"
echo -n "Select option (1-2): "
read setup_option
echo ""

if [ "$setup_option" == "2" ]; then
    # Secure setup with Secret Manager
    echo -e "${GREEN}🔒 Using Secret Manager for sensitive data${NC}"
    echo ""
    
    # Supabase
    set_env_var "SUPABASE_URL" "Supabase Project URL" "false"
    set_secret "supabase-anon-key" "SUPABASE_ANON_KEY" "Supabase Anonymous Key"
    set_secret "supabase-service-role" "SUPABASE_SERVICE_ROLE_KEY" "Supabase Service Role Key"
    
    # OpenAI
    set_secret "openai-api-key" "OPENAI_API_KEY" "OpenAI API Key"
    
    # Redis
    set_env_var "UPSTASH_REDIS_REST_URL" "Upstash Redis REST URL" "false"
    set_secret "upstash-redis-token" "UPSTASH_REDIS_REST_TOKEN" "Upstash Redis Token"
    
    # IAP
    set_secret "apple-iap-secret" "APPLE_IAP_SHARED_SECRET" "Apple IAP Shared Secret"
    set_env_var "GOOGLE_SERVICE_ACCOUNT_KEY_PATH" "Google Service Account Key Path" "false"
    
    # Security
    set_secret "jwt-secret" "JWT_SECRET" "JWT Secret Key"
    set_secret "internal-api-key" "INTERNAL_API_KEY" "Internal API Key"
    
else
    # Quick setup with environment variables only
    echo -e "${YELLOW}⚠️  Warning: This method stores sensitive data as plain text${NC}"
    echo -e "${YELLOW}   Consider using Secret Manager for production${NC}"
    echo ""
    
    # Supabase
    set_env_var "SUPABASE_URL" "Supabase Project URL" "false"
    set_env_var "SUPABASE_ANON_KEY" "Supabase Anonymous Key" "true"
    set_env_var "SUPABASE_SERVICE_ROLE_KEY" "Supabase Service Role Key" "true"
    
    # OpenAI
    set_env_var "OPENAI_API_KEY" "OpenAI API Key" "true"
    
    # Redis
    set_env_var "UPSTASH_REDIS_REST_URL" "Upstash Redis REST URL" "false"
    set_env_var "UPSTASH_REDIS_REST_TOKEN" "Upstash Redis Token" "true"
    
    # IAP
    set_env_var "APPLE_IAP_SHARED_SECRET" "Apple IAP Shared Secret" "true"
    set_env_var "GOOGLE_SERVICE_ACCOUNT_KEY_PATH" "Google Service Account Key Path" "false"
    
    # Security
    set_env_var "JWT_SECRET" "JWT Secret Key" "true"
    set_env_var "INTERNAL_API_KEY" "Internal API Key" "true"
fi

# Common environment variables
set_env_var "NODE_ENV" "Node Environment (production/staging)" "false"
set_env_var "API_VERSION" "API Version (e.g., v1)" "false"
set_env_var "ALLOWED_ORIGINS" "Allowed CORS Origins (comma-separated)" "false"

# Apply the configuration
if [ -n "$ENV_VARS" ] || [ -n "$SECRETS" ]; then
    echo -e "${GREEN}🚀 Applying configuration to Cloud Run...${NC}"
    
    UPDATE_CMD="gcloud run services update ${SERVICE_NAME} --region ${REGION}"
    
    if [ -n "$ENV_VARS" ]; then
        UPDATE_CMD="${UPDATE_CMD} ${ENV_VARS}"
    fi
    
    if [ -n "$SECRETS" ]; then
        UPDATE_CMD="${UPDATE_CMD} ${SECRETS}"
    fi
    
    eval $UPDATE_CMD
    
    echo ""
    echo -e "${GREEN}✅ Environment variables configured successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  No environment variables were set${NC}"
fi

echo ""
echo -e "${BLUE}📋 To view current configuration:${NC}"
echo "gcloud run services describe ${SERVICE_NAME} --region ${REGION}"
echo ""
echo -e "${BLUE}📋 To manually update a variable:${NC}"
echo "gcloud run services update ${SERVICE_NAME} --region ${REGION} --update-env-vars=KEY=VALUE"