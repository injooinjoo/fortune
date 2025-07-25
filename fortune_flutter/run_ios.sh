#!/bin/bash

# Flutter iOS simulator development script
echo "Starting Fortune Flutter on iOS Simulator..."

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  # Use set -a to export all variables and source the file directly
  set -a
  source .env
  set +a
fi

# Check if Google iOS Client ID is set
if [ -z "$GOOGLE_IOS_CLIENT_ID" ]; then
  echo "WARNING: GOOGLE_IOS_CLIENT_ID is not set in .env file"
  echo "Google Sign-In will not work without a valid client ID"
fi

# Find available iOS simulators
echo "Available iOS simulators:"
flutter devices | grep -E "iPhone|iPad"

# Run Flutter on iOS simulator with dart-define parameters
flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=$GOOGLE_ANDROID_CLIENT_ID