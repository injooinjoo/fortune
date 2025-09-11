#!/bin/bash

# Android Keystore Setup Script
# This script helps create a secure keystore for Android app signing

echo "================================================"
echo "Fortune App - Android Keystore Setup"
echo "================================================"
echo ""
echo "This script will help you create a secure keystore for signing your Android app."
echo "Make sure to save the passwords you enter in a secure location!"
echo ""

# Prompt for keystore password
read -s -p "Enter keystore password (min 6 characters): " STORE_PASSWORD
echo ""
read -s -p "Confirm keystore password: " STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "Passwords don't match. Please try again."
    exit 1
fi

# Prompt for key password
read -s -p "Enter key password (min 6 characters): " KEY_PASSWORD
echo ""
read -s -p "Confirm key password: " KEY_PASSWORD_CONFIRM
echo ""

if [ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]; then
    echo "Passwords don't match. Please try again."
    exit 1
fi

# Prompt for certificate information
echo "Enter certificate information:"
read -p "Your name (CN): " CN
read -p "Organizational Unit (OU): " OU
read -p "Organization (O): " O
read -p "City (L): " L
read -p "State (ST): " ST
read -p "Country Code (C, e.g., KR): " C

# Generate keystore
echo ""
echo "Generating keystore..."
keytool -genkey -v \
    -keystore android/app/fortune-release.keystore \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias fortune \
    -dname "CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully!"
    echo ""
    echo "Creating key.properties file..."
    
    cat > android/key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=fortune
storeFile=fortune-release.keystore
EOF
    
    echo "✅ key.properties file created!"
    echo ""
    echo "================================================"
    echo "IMPORTANT: Security Instructions"
    echo "================================================"
    echo "1. BACKUP the keystore file to a secure location"
    echo "2. NEVER commit the keystore or key.properties to Git"
    echo "3. Store passwords in a password manager"
    echo "4. For CI/CD, use environment variables:"
    echo "   - ANDROID_KEYSTORE_PASSWORD"
    echo "   - ANDROID_KEY_PASSWORD"
    echo ""
    echo "The following files have been created:"
    echo "  - android/app/fortune-release.keystore"
    echo "  - android/key.properties"
    echo ""
    echo "These files are already in .gitignore"
    echo "================================================"
else
    echo "❌ Failed to create keystore"
    exit 1
fi