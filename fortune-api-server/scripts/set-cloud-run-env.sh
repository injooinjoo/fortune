#!/bin/bash

# Cloud Run 환경 변수 설정 스크립트
# Usage: ./scripts/set-cloud-run-env.sh

set -e

# Configuration
PROJECT_ID="fortune2-463710"
SERVICE_NAME="fortune-api"
REGION="asia-northeast3"

# Generate secure random strings for secrets
JWT_SECRET=$(openssl rand -hex 32)

echo "Setting environment variables for Cloud Run service: ${SERVICE_NAME}"

# Set environment variables
~/google-cloud-sdk/bin/gcloud run services update ${SERVICE_NAME} \
  --project ${PROJECT_ID} \
  --region ${REGION} \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "ALLOWED_ORIGINS=*" \
  --set-env-vars "SUPABASE_URL=https://hayjukwfcsdmppairazc.supabase.co" \
  --set-env-vars "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheWp1a3dmY3NkbXBwYWlyYXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxMDIyNzUsImV4cCI6MjA2MzY3ODI3NX0.nV--LlLk8VOUyz0Vmu_26dRn1vRD9WFxPg0BIYS7ct0" \
  --set-env-vars "SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheWp1a3dmY3NkbXBwYWlyYXpjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODEwMjI3NSwiZXhwIjoyMDYzNjc4Mjc1fQ.M1VQv6IhKnXF1lTGj7YgLwO5MIoBCLgI9Zz1p0HjRys" \
  --set-env-vars "OPENAI_API_KEY=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" \
  --set-env-vars "UPSTASH_REDIS_REST_URL=https://advanced-bengal-23958.upstash.io" \
  --set-env-vars "UPSTASH_REDIS_REST_TOKEN=AV2WAAIjcDEwMTA2ZjVmZmZjMjk0NzBmOTcwZjFjYTU0OTk5NWU4YXAxMA" \
  --set-env-vars "JWT_SECRET=${JWT_SECRET}" \
  --set-env-vars "INTERNAL_API_KEY=eb68fe1fbb8016f0473d9e37bcbf1db6214e665097dabb38caf4cc53b7a9729f" \
  --set-env-vars "CRON_SECRET=092dd8a5b1d11bb203f27c2987d121c9f733616b643f0fcff20acf3dbb81f8a0" \
  --set-env-vars "STRIPE_SECRET_KEY=sk_test_51234567890abcdefghijklmnopqrstuvwxyz" \
  --set-env-vars "STRIPE_WEBHOOK_SECRET=whsec_test1234567890abcdefghijklmnop" \
  --set-env-vars "APPLE_IAP_SHARED_SECRET=" \
  --set-env-vars "API_VERSION=v1" \
  --set-env-vars "LOG_LEVEL=info"

echo "Environment variables have been set successfully!"
echo "JWT_SECRET generated: ${JWT_SECRET}"
echo ""
echo "Note: The service will redeploy automatically with the new environment variables."
echo "Check the service status:"
echo "gcloud run services describe ${SERVICE_NAME} --region ${REGION} --project ${PROJECT_ID}"