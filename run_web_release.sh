#!/bin/bash

# Flutter web release mode script for port 9002 (avoids Chrome debugging issues)
echo "Starting Fortune Flutter web in RELEASE mode on port 9002..."
echo "Note: This runs in release mode to avoid Chrome debugging crashes"

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  # Use set -a to export all variables and source the file directly
  set -a
  source .env
  set +a
fi

# Check if Google Web Client ID is set
if [ -z "$GOOGLE_WEB_CLIENT_ID" ]; then
  echo "WARNING: GOOGLE_WEB_CLIENT_ID is not set in .env file"
  echo "Google Sign-In will not work without a valid client ID"
fi

# Run Flutter web in release mode on port 9002 with dart-define parameters
flutter run -d chrome \
  --release \
  --web-port=9002 \
  --web-hostname=localhost \
  --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=$GOOGLE_ANDROID_CLIENT_ID