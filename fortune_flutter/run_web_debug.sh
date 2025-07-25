#!/bin/bash

# Flutter web debug mode script
echo "Starting Fortune Flutter web in DEBUG mode on port 9004..."
echo "Note: This may crash on Chrome if breakpoints are hit"

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  # Use set -a to export all variables and source the file directly
  set -a
  source .env
  set +a
fi

# Run Flutter web in debug mode on port 9004 with dart-define parameters
flutter run -d chrome \
  --web-port=9004 \
  --web-hostname=localhost \
  --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID \
  --dart-define=GOOGLE_ANDROID_CLIENT_ID=$GOOGLE_ANDROID_CLIENT_ID