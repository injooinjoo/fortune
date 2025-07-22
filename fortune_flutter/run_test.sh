#!/bin/bash

echo "Fortune Flutter Test Suite"
echo "========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test configuration
TEST_PARALLEL=false
TEST_CONCURRENCY=4
COVERAGE_THRESHOLD=85
GENERATE_REPORT=true
VERBOSE=false

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
            
            if (( $(echo "$COVERAGE >= $COVERAGE_THRESHOLD" | bc -l) )); then
                echo -e "${GREEN}✓ Coverage goal of ${COVERAGE_THRESHOLD}% achieved!${NC}"
            else
                echo -e "${YELLOW}⚠ Coverage is below ${COVERAGE_THRESHOLD}% target${NC}"
                if [ "$CI" = "true" ]; then
                    exit 1  # Fail CI if coverage is below threshold
                fi
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

# Function to run tests in parallel
run_tests_parallel() {
    local test_type=$1
    local test_dirs=$2
    
    echo -e "${PURPLE}Running $test_type tests in parallel (concurrency: $TEST_CONCURRENCY)...${NC}"
    
    find $test_dirs -name "*_test.dart" | \
    xargs -P $TEST_CONCURRENCY -I {} bash -c '
        echo -e "Running test: {}"
        flutter test {} --no-pub
        if [ $? -ne 0 ]; then
            echo -e "\033[0;31m✗ Test failed: {}\033[0m"
            exit 1
        else
            echo -e "\033[0;32m✓ Test passed: {}\033[0m"
        fi
    '
}

# Function to generate test report
generate_test_report() {
    echo -e "${BLUE}Generating test report...${NC}"
    
    # Create report directory
    mkdir -p test_reports
    
    # Generate JSON report
    flutter test --reporter json > test_reports/test_results.json
    
    # Generate HTML report if tool is available
    if command -v allure &> /dev/null; then
        allure generate test_reports -o test_reports/html
        echo -e "${GREEN}HTML test report generated at: test_reports/html/index.html${NC}"
    fi
    
    # Summary statistics
    local total_tests=$(grep -c '"testID"' test_reports/test_results.json)
    local passed_tests=$(grep -c '"result":"success"' test_reports/test_results.json)
    local failed_tests=$(grep -c '"result":"error"' test_reports/test_results.json)
    local skipped_tests=$(grep -c '"result":"skip"' test_reports/test_results.json)
    
    echo ""
    echo -e "${BLUE}Test Summary:${NC}"
    echo -e "Total Tests: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo -e "${YELLOW}Skipped: $skipped_tests${NC}"
}

# Function to run specific test files
run_specific_tests() {
    local pattern=$1
    
    echo -e "${YELLOW}Running tests matching pattern: $pattern${NC}"
    
    local test_files=$(find test -name "*$pattern*_test.dart")
    
    if [ -z "$test_files" ]; then
        echo -e "${RED}No test files found matching pattern: $pattern${NC}"
        exit 1
    fi
    
    echo "Found test files:"
    echo "$test_files"
    echo ""
    
    for file in $test_files; do
        echo -e "${BLUE}Running: $file${NC}"
        flutter test $file
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Test failed: $file${NC}"
            exit 1
        fi
    done
}

# Function to run performance benchmarks
run_benchmarks() {
    echo -e "${PURPLE}Running performance benchmarks...${NC}"
    
    # Run benchmark tests if they exist
    if [ -d "test/benchmarks" ]; then
        flutter test test/benchmarks --reporter expanded
    else
        echo -e "${YELLOW}No benchmark tests found in test/benchmarks/${NC}"
    fi
}

# Function to check test quality
check_test_quality() {
    echo -e "${BLUE}Checking test quality...${NC}"
    
    # Count assertions per test file
    for file in $(find test -name "*_test.dart"); do
        local assertions=$(grep -c "expect\|verify" "$file")
        local tests=$(grep -c "test\|testWidgets" "$file")
        
        if [ $tests -gt 0 ]; then
            local avg_assertions=$((assertions / tests))
            if [ $avg_assertions -lt 2 ]; then
                echo -e "${YELLOW}⚠ Low assertion density in $file (avg: $avg_assertions per test)${NC}"
            fi
        fi
    done
    
    # Check for focused tests
    local focused=$(grep -r "ftest\|ftestWidgets\|solo:" test/)
    if [ ! -z "$focused" ]; then
        echo -e "${RED}✗ Found focused tests (remove before committing):${NC}"
        echo "$focused"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --parallel)
            TEST_PARALLEL=true
            shift
            ;;
        --concurrency)
            TEST_CONCURRENCY="$2"
            shift 2
            ;;
        --threshold)
            COVERAGE_THRESHOLD="$2"
            shift 2
            ;;
        --no-report)
            GENERATE_REPORT=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./run_test.sh [command] [options]"
            echo ""
            echo "Commands:"
            echo "  unit            - Run unit tests only"
            echo "  widget          - Run widget tests only"
            echo "  integration     - Run all integration tests"
            echo "  integration <file> - Run specific integration test file"
            echo "  coverage        - Run all tests with coverage report"
            echo "  watch           - Run tests in watch mode"
            echo "  ci              - Run tests for CI/CD pipeline"
            echo "  specific <pattern> - Run tests matching pattern"
            echo "  benchmark       - Run performance benchmarks"
            echo "  quality         - Check test quality"
            echo "  help            - Show this help message"
            echo ""
            echo "Options:"
            echo "  --parallel      - Run tests in parallel"
            echo "  --concurrency N - Number of parallel test processes (default: 4)"
            echo "  --threshold N   - Coverage threshold percentage (default: 85)"
            echo "  --no-report     - Skip generating test report"
            echo "  --verbose       - Show detailed output"
            echo ""
            echo "Examples:"
            echo "  ./run_test.sh unit --parallel"
            echo "  ./run_test.sh coverage --threshold 90"
            echo "  ./run_test.sh specific auth"
            echo "  ./run_test.sh integration auth_flow_test.dart"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Main command processing
case "$1" in
    "unit")
        echo "Running unit tests only..."
        if [ "$TEST_PARALLEL" = true ]; then
            run_tests_parallel "Unit" "test/unit/"
        else
            run_test_type "Unit" "test/unit/"
        fi
        if [ "$GENERATE_REPORT" = true ]; then
            generate_test_report
        fi
        ;;
    "widget")
        echo "Running widget tests only..."
        if [ "$TEST_PARALLEL" = true ]; then
            run_tests_parallel "Widget" "test/widget/"
        else
            run_test_type "Widget" "test/widget/"
        fi
        if [ "$GENERATE_REPORT" = true ]; then
            generate_test_report
        fi
        ;;
    "integration")
        echo "Running integration tests..."
        echo -e "${YELLOW}Note: Integration tests require a device or emulator${NC}"
        
        # Check if specific test file is provided
        if [ -n "$2" ]; then
            echo -e "${YELLOW}Running specific integration test: $2${NC}"
            # Check if Chrome is available for web tests
            if flutter devices | grep -q "Chrome"; then
                flutter test integration_test/$2 -d chrome
            else
                echo -e "${RED}No Chrome device found. Please ensure Chrome is installed.${NC}"
                echo "Running on available device..."
                flutter test integration_test/$2
            fi
        else
            echo -e "${YELLOW}Running all integration tests...${NC}"
            # Check if Chrome is available for web tests
            if flutter devices | grep -q "Chrome"; then
                flutter test integration_test/ -d chrome
            else
                echo -e "${RED}No Chrome device found. Please ensure Chrome is installed.${NC}"
                echo "Running on available device..."
                flutter test integration_test/
            fi
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
            
            if (( $(echo "$COVERAGE < $COVERAGE_THRESHOLD" | bc -l) )); then
                echo -e "${RED}Coverage ${COVERAGE}% is below ${COVERAGE_THRESHOLD}% threshold${NC}"
                exit 1
            fi
        fi
        
        exit $TEST_RESULT
        ;;
    "specific")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please provide a pattern to match${NC}"
            echo "Usage: ./run_test.sh specific <pattern>"
            exit 1
        fi
        run_specific_tests "$2"
        ;;
    "benchmark")
        run_benchmarks
        ;;
    "quality")
        check_test_quality
        echo -e "${GREEN}✓ Test quality check passed${NC}"
        ;;
    "help"|"-h"|"--help")
        echo "Usage: ./run_test.sh [command]"
        echo ""
        echo "Commands:"
        echo "  unit            - Run unit tests only"
        echo "  widget          - Run widget tests only"
        echo "  integration     - Run all integration tests"
        echo "  integration <file> - Run specific integration test file"
        echo "  coverage        - Run all tests with coverage report"
        echo "  watch           - Run tests in watch mode"
        echo "  ci              - Run tests for CI/CD pipeline"
        echo "  help            - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./run_test.sh integration                      # Run all integration tests"
        echo "  ./run_test.sh integration auth_flow_test.dart  # Run specific test"
        echo ""
        echo "If no command is specified, all tests will be run."
        ;;
    *)
        echo "Running all tests..."
        echo ""
        
        # Check test quality first
        check_test_quality
        echo ""
        
        # Run unit tests
        if [ "$TEST_PARALLEL" = true ]; then
            run_tests_parallel "Unit" "test/unit/" || exit 1
        else
            run_test_type "Unit" "test/unit/" || exit 1
        fi
        echo ""
        
        # Run widget tests
        if [ "$TEST_PARALLEL" = true ]; then
            run_tests_parallel "Widget" "test/widget/" || exit 1
        else
            run_test_type "Widget" "test/widget/" || exit 1
        fi
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