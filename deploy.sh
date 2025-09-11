#!/bin/bash

# Fortune App Deployment Script
# This script helps deploy the app to both Android and iOS app stores

set -e

echo "=========================================="
echo "Fortune App - Deployment Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists flutter; then
    print_error "Flutter is not installed"
    exit 1
fi

if ! command_exists fastlane; then
    print_warning "Fastlane is not installed. Installing..."
    sudo gem install fastlane -NV
fi

# Security check
echo ""
echo "=========================================="
echo "SECURITY CHECK"
echo "=========================================="
echo ""

# Check for exposed keys in .env
if [ -f ".env" ]; then
    if grep -q "sk-proj-" .env 2>/dev/null; then
        print_error "CRITICAL: Exposed API keys detected in .env file!"
        print_error "Please rotate all API keys before deployment"
        echo "See SECURITY_CHECKLIST.md for details"
        exit 1
    fi
fi

# Check for keystore
ANDROID_KEYSTORE="android/app/fortune-release.keystore"
if [ ! -f "$ANDROID_KEYSTORE" ]; then
    print_warning "Android keystore not found"
    echo "Would you like to create one now? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        ./android/keystore-setup.sh
    else
        print_error "Cannot proceed without keystore"
        exit 1
    fi
fi

# Main menu
while true; do
    echo ""
    echo "=========================================="
    echo "SELECT DEPLOYMENT OPTION"
    echo "=========================================="
    echo "1) Build Android Release (AAB)"
    echo "2) Build Android Release (APK)"
    echo "3) Deploy to Google Play (Internal)"
    echo "4) Deploy to Google Play (Production)"
    echo "5) Build iOS Release"
    echo "6) Deploy to TestFlight"
    echo "7) Deploy to App Store"
    echo "8) Run Security Check"
    echo "9) Exit"
    echo ""
    echo -n "Enter your choice [1-9]: "
    read -r choice

    case $choice in
        1)
            echo "Building Android AAB..."
            flutter clean
            flutter pub get
            flutter build appbundle --release
            print_success "AAB built: build/app/outputs/bundle/release/app-release.aab"
            ;;
        
        2)
            echo "Building Android APK..."
            flutter clean
            flutter pub get
            flutter build apk --release
            print_success "APK built: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        
        3)
            echo "Deploying to Google Play (Internal)..."
            cd android
            fastlane internal
            cd ..
            print_success "Deployed to Internal Testing track"
            ;;
        
        4)
            print_warning "Deploying to Production!"
            echo "Are you sure you want to deploy to production? (yes/no)"
            read -r confirm
            if [[ "$confirm" == "yes" ]]; then
                cd android
                fastlane deploy
                cd ..
                print_success "Deployed to Production!"
            else
                echo "Deployment cancelled"
            fi
            ;;
        
        5)
            echo "Building iOS Release..."
            flutter clean
            flutter pub get
            flutter build ios --release
            print_success "iOS build complete"
            ;;
        
        6)
            echo "Deploying to TestFlight..."
            cd ios
            fastlane beta
            cd ..
            print_success "Deployed to TestFlight"
            ;;
        
        7)
            print_warning "Deploying to App Store!"
            echo "Are you sure you want to deploy to App Store? (yes/no)"
            read -r confirm
            if [[ "$confirm" == "yes" ]]; then
                cd ios
                fastlane release
                cd ..
                print_success "Deployed to App Store!"
            else
                echo "Deployment cancelled"
            fi
            ;;
        
        8)
            echo "Running Security Check..."
            echo ""
            
            # Check for exposed keys
            if [ -f ".env" ]; then
                echo "Checking .env file..."
                EXPOSED_KEYS=0
                
                if grep -q "sk-proj-" .env 2>/dev/null; then
                    print_error "OpenAI API key exposed!"
                    EXPOSED_KEYS=$((EXPOSED_KEYS + 1))
                fi
                
                if grep -q "figd_" .env 2>/dev/null; then
                    print_error "Figma token exposed!"
                    EXPOSED_KEYS=$((EXPOSED_KEYS + 1))
                fi
                
                if [ $EXPOSED_KEYS -eq 0 ]; then
                    print_success "No exposed keys found in .env"
                else
                    print_error "$EXPOSED_KEYS exposed keys found!"
                    echo "Please rotate these keys immediately"
                fi
            fi
            
            # Check keystore
            if [ -f "$ANDROID_KEYSTORE" ]; then
                print_success "Android keystore found"
            else
                print_warning "Android keystore not found"
            fi
            
            # Check key.properties
            if [ -f "android/key.properties" ]; then
                print_success "Android key.properties found"
            else
                print_warning "Android key.properties not found"
            fi
            
            echo ""
            echo "See SECURITY_CHECKLIST.md for full checklist"
            ;;
        
        9)
            echo "Exiting..."
            exit 0
            ;;
        
        *)
            print_error "Invalid option"
            ;;
    esac
done