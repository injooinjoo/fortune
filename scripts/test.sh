#!/bin/bash
# Test execution script for ZPZG Flutter App
# Usage: ./scripts/test.sh [flutter|playwright|all]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

# Set test environment variables
setup_test_env() {
    log_info "Setting up test environment variables..."
    export FLUTTER_TEST_MODE=true
    export TEST_MODE=true
    export BYPASS_AUTH=true
    export TEST_ACCOUNT_EMAIL="test@zpzg.com"
    export TEST_ACCOUNT_PASSWORD="Test123!@#"
    export TEST_USER_ID="test-user-id-12345"
    export TEST_PROFILE_COMPLETE=true
    log_success "Test environment configured"
}

# Check if Flutter is available
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi

    log_info "Flutter version: $(flutter --version | head -n1)"
}

# Check if Node.js is available (for Playwright)
check_node() {
    if ! command -v npm &> /dev/null; then
        log_error "Node.js/npm is not installed or not in PATH"
        exit 1
    fi

    log_info "Node.js version: $(node --version)"
    log_info "npm version: $(npm --version)"
}

# Install Playwright if needed
setup_playwright() {
    log_info "Setting up Playwright..."

    if [ ! -f "package.json" ]; then
        log_error "package.json not found. Run this script from the project root."
        exit 1
    fi

    # Install dependencies
    npm install

    # Install Playwright browsers
    npx playwright install

    log_success "Playwright setup completed"
}

# Run Flutter integration tests
run_flutter_tests() {
    log_info "Running Flutter integration tests..."

    # Clean and get dependencies
    flutter clean
    flutter pub get

    # Check for available devices
    log_info "Available devices:"
    flutter devices

    # Try to run integration tests on available device
    if flutter devices | grep -q "iPhone"; then
        DEVICE="iPhone"
    elif flutter devices | grep -q "chrome"; then
        DEVICE="chrome"
    else
        log_warning "No suitable device found for integration tests"
        return 1
    fi

    log_info "Running integration tests on $DEVICE..."

    # Run with test environment variables
    flutter test integration_test/ -d "$DEVICE" \
        --dart-define=FLUTTER_TEST_MODE=true \
        --dart-define=TEST_MODE=true \
        --dart-define=BYPASS_AUTH=true || {
        log_warning "Integration tests failed or had issues"
        return 1
    }

    log_success "Flutter integration tests completed"
}

# Run Playwright E2E tests
run_playwright_tests() {
    log_info "Running Playwright E2E tests..."

    # Ensure Flutter web is available
    if ! flutter config | grep -q "enable-web: true"; then
        log_info "Enabling Flutter web..."
        flutter config --enable-web
    fi

    # Run Playwright tests
    npm run test || {
        log_warning "Playwright tests failed or had issues"
        return 1
    }

    log_success "Playwright E2E tests completed"
}

# Run unit tests (if they exist)
run_unit_tests() {
    if [ -d "test" ] && [ "$(ls -A test)" ]; then
        log_info "Running unit tests..."
        flutter test --coverage || {
            log_warning "Unit tests failed or had issues"
            return 1
        }
        log_success "Unit tests completed"
    else
        log_warning "No unit tests found (test directory empty or missing)"
    fi
}

# Generate test report
generate_report() {
    log_info "Generating test reports..."

    # Create reports directory
    mkdir -p reports

    # Playwright report
    if [ -d "test-results" ]; then
        npm run test:report || log_warning "Failed to generate Playwright report"
    fi

    # Coverage report
    if [ -f "coverage/lcov.info" ]; then
        log_info "Coverage report available at coverage/html/index.html"
    fi

    log_success "Test reports generated"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up test artifacts..."

    # Remove temporary test files
    rm -rf .dart_tool/test/

    # Keep test results for analysis
    # rm -rf test-results/

    log_success "Cleanup completed"
}

# Main execution
main() {
    log_info "🚀 Fortune Flutter App Test Runner"
    log_info "=================================="

    # Setup
    setup_test_env
    check_flutter

    case "${1:-all}" in
        "flutter")
            log_info "Running Flutter tests only..."
            run_unit_tests
            run_flutter_tests
            ;;
        "playwright")
            log_info "Running Playwright tests only..."
            check_node
            setup_playwright
            run_playwright_tests
            ;;
        "all"|"")
            log_info "Running all tests..."
            run_unit_tests
            run_flutter_tests

            # Only run Playwright if Node.js is available
            if command -v npm &> /dev/null; then
                setup_playwright
                run_playwright_tests
            else
                log_warning "Skipping Playwright tests (Node.js not available)"
            fi
            ;;
        "help")
            echo "Usage: $0 [flutter|playwright|all|help]"
            echo ""
            echo "Commands:"
            echo "  flutter    - Run only Flutter integration tests"
            echo "  playwright - Run only Playwright E2E tests"
            echo "  all        - Run all tests (default)"
            echo "  help       - Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac

    generate_report

    log_success "🎉 Test execution completed!"
    log_info "Check the reports/ directory for detailed results"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"
