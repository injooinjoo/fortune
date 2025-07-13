#!/bin/bash

# Fortune API Server Deployment Script
# Usage: ./scripts/deploy.sh [environment]
# Example: ./scripts/deploy.sh production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="fortune2-463710"
SERVICE_NAME="fortune-api"
REGION="asia-northeast3"  # Seoul
ENVIRONMENT="${1:-production}"

echo -e "${GREEN}🚀 Fortune API Server Deployment Script${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo ""

# Check if gcloud is installed
GCLOUD_PATH="$HOME/google-cloud-sdk/bin/gcloud"
if [ -f "$GCLOUD_PATH" ]; then
    # Use full path if gcloud is not in PATH
    GCLOUD="$GCLOUD_PATH"
elif command -v gcloud &> /dev/null; then
    GCLOUD="gcloud"
else
    echo -e "${RED}❌ Error: gcloud CLI is not installed${NC}"
    echo "Please install Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! $GCLOUD auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not authenticated with Google Cloud${NC}"
    echo "Running: gcloud auth login"
    $GCLOUD auth login
fi

# Set the project
echo -e "${GREEN}📋 Setting project to: ${PROJECT_ID}${NC}"
$GCLOUD config set project ${PROJECT_ID}

# Build TypeScript
echo -e "${GREEN}🔨 Building TypeScript...${NC}"
npm run build

# Deploy to Cloud Run
echo -e "${GREEN}☁️  Deploying to Cloud Run...${NC}"

if [ "$ENVIRONMENT" == "production" ]; then
    # Production deployment
    $GCLOUD run deploy ${SERVICE_NAME} \
        --source . \
        --region ${REGION} \
        --platform managed \
        --allow-unauthenticated \
        --memory 1Gi \
        --cpu 1 \
        --timeout 300 \
        --max-instances 10 \
        --min-instances 1 \
        --set-env-vars="NODE_ENV=production,API_VERSION=v1"
elif [ "$ENVIRONMENT" == "staging" ]; then
    # Staging deployment
    $GCLOUD run deploy ${SERVICE_NAME}-staging \
        --source . \
        --region ${REGION} \
        --platform managed \
        --allow-unauthenticated \
        --memory 512Mi \
        --cpu 1 \
        --timeout 300 \
        --max-instances 3 \
        --min-instances 0 \
        --set-env-vars="NODE_ENV=staging,API_VERSION=v1"
else
    echo -e "${RED}❌ Error: Unknown environment '${ENVIRONMENT}'${NC}"
    echo "Usage: ./scripts/deploy.sh [production|staging]"
    exit 1
fi

# Get the service URL
SERVICE_URL=$($GCLOUD run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🔗 Service URL: ${SERVICE_URL}${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Update environment variables in Cloud Console"
echo "2. Test the API endpoints: curl ${SERVICE_URL}/health"
echo "3. Update Flutter app with new API URL"
echo "4. Monitor logs: $GCLOUD logging read 'resource.type=cloud_run_revision'"