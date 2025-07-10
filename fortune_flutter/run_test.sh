#!/bin/bash

echo "Fortune Flutter Test Suite"
echo "========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run tests with coverage
run_tests_with_coverage() {
    echo -e "${YELLOW}Running all tests with coverage...${NC}"
    flutter test --coverage
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        
        # Generate coverage report
        if command -v lcov &> /dev/null; then
            echo -e "${YELLOW}Generating coverage report...${NC}"
            
            # Generate HTML coverage report
            genhtml coverage/lcov.info -o coverage/html
            
            # Calculate coverage percentage
            COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep -E "lines\.+:" | sed -E 's/.*lines\.+:\ +([0-9.]+)%.*/\1/')
            
            echo -e "${GREEN}Test Coverage: ${COVERAGE}%${NC}"
            
            if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
                echo -e "${GREEN}✓ Coverage goal of 80% achieved!${NC}"
            else
                echo -e "${YELLOW}⚠ Coverage is below 80% target${NC}"
            fi
            
            echo -e "${YELLOW}Coverage report generated at: coverage/html/index.html${NC}"
        else
            echo -e "${YELLOW}Install lcov for detailed coverage reports: brew install lcov${NC}"
        fi
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

# Function to run specific test type
run_test_type() {
    local test_type=$1
    local test_path=$2
    
    echo -e "${YELLOW}Running ${test_type} tests...${NC}"
    flutter test ${test_path}
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${test_type} tests passed!${NC}"
    else
        echo -e "${RED}✗ ${test_type} tests failed${NC}"
        return 1
    fi
}

# Parse command line arguments
case "$1" in
    "unit")
        echo "Running unit tests only..."
        run_test_type "Unit" "test/unit_test/"
        ;;
    "widget")
        echo "Running widget tests only..."
        run_test_type "Widget" "test/widget_test/"
        ;;
    "integration")
        echo "Running integration tests..."
        echo -e "${YELLOW}Note: Integration tests require a device or emulator${NC}"
        
        # Check if Chrome is available for web tests
        if flutter devices | grep -q "Chrome"; then
            flutter test integration_test/app_test.dart -d chrome
        else
            echo -e "${RED}No Chrome device found. Please ensure Chrome is installed.${NC}"
            echo "Running on available device..."
            flutter test integration_test/app_test.dart
        fi
        ;;
    "coverage")
        run_tests_with_coverage
        ;;
    "watch")
        echo "Running tests in watch mode..."
        echo -e "${YELLOW}Tests will re-run automatically when files change${NC}"
        echo "Press Ctrl+C to stop"
        
        # Use fswatch if available, otherwise fall back to basic loop
        if command -v fswatch &> /dev/null; then
            fswatch -o lib/ test/ | xargs -n1 -I{} flutter test
        else
            echo -e "${YELLOW}Install fswatch for better file watching: brew install fswatch${NC}"
            while true; do
                flutter test
                echo -e "${YELLOW}Waiting for changes... Press Ctrl+C to stop${NC}"
                sleep 5
            done
        fi
        ;;
    "ci")
        echo "Running CI test suite..."
        
        # Run all tests with coverage
        flutter test --coverage
        TEST_RESULT=$?
        
        # Generate machine-readable test report
        flutter test --machine > test-results.json
        
        # Check coverage threshold
        if [ $TEST_RESULT -eq 0 ] && command -v lcov &> /dev/null; then
            COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep -E "lines\.+:" | sed -E 's/.*lines\.+:\ +([0-9.]+)%.*/\1/')
            
            if (( $(echo "$COVERAGE < 80" | bc -l) )); then
                echo -e "${RED}Coverage ${COVERAGE}% is below 80% threshold${NC}"
                exit 1
            fi
        fi
        
        exit $TEST_RESULT
        ;;
    "help"|"-h"|"--help")
        echo "Usage: ./run_test.sh [command]"
        echo ""
        echo "Commands:"
        echo "  unit        - Run unit tests only"
        echo "  widget      - Run widget tests only"
        echo "  integration - Run integration tests"
        echo "  coverage    - Run all tests with coverage report"
        echo "  watch       - Run tests in watch mode"
        echo "  ci          - Run tests for CI/CD pipeline"
        echo "  help        - Show this help message"
        echo ""
        echo "If no command is specified, all tests will be run."
        ;;
    *)
        echo "Running all tests..."
        echo ""
        
        # Run unit tests
        run_test_type "Unit" "test/unit_test/" || exit 1
        echo ""
        
        # Run widget tests
        run_test_type "Widget" "test/widget_test/" || exit 1
        echo ""
        
        # Run all tests together for final verification
        echo -e "${YELLOW}Running all tests together...${NC}"
        flutter test
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ All tests passed successfully!${NC}"
            echo ""
            echo "Run './run_test.sh coverage' to generate coverage report"
            echo "Run './run_test.sh integration' to run integration tests"
        else
            echo -e "${RED}✗ Test suite failed${NC}"
            exit 1
        fi
        ;;
esac