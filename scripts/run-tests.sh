#!/bin/bash

# Insurance QA Automation - Test Execution Script
# This script runs Newman tests against the Insurance PAS API

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COLLECTION_FILE="./collections/insurance-enterprise.json"
ENVIRONMENT_FILE="./collections/insurance-env.json"
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_NAME="insurance-qa-report-${TIMESTAMP}"
HTML_REPORT="${REPORT_DIR}/${REPORT_NAME}.html"
JSON_REPORT="${REPORT_DIR}/${REPORT_NAME}.json"

# Exit codes
SUCCESS=0
FAILURE=1

# Print header
print_header() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  Insurance QA Automation Test Suite${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
}

# Print step
print_step() {
    echo -e "${YELLOW}► $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Validate files exist
validate_files() {
    print_step "Validating test files..."
    
    if [ ! -f "$COLLECTION_FILE" ]; then
        print_error "Collection file not found: $COLLECTION_FILE"
        exit $FAILURE
    fi
    print_success "Collection file found"
    
    if [ ! -f "$ENVIRONMENT_FILE" ]; then
        print_error "Environment file not found: $ENVIRONMENT_FILE"
        exit $FAILURE
    fi
    print_success "Environment file found"
}

# Create report directory
setup_reports() {
    print_step "Setting up report directory..."
    mkdir -p "$REPORT_DIR"
    print_success "Report directory ready: $REPORT_DIR"
}

# Run tests
run_tests() {
    print_step "Running API tests with Newman..."
    echo ""
    
    # Run Newman with comprehensive options
    # --collection: Specify the Postman collection
    # --environment: Specify the environment variables
    # --reporters: Use html and json reporters
    # --reporter-html-export: Export HTML report
    # --reporter-json-export: Export JSON report
    # --bail: Stop on first test failure (fail-fast)
    # --verbose: Detailed output
    
    if newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        --reporters cli,html,json \
        --reporter-html-export "$HTML_REPORT" \
        --reporter-json-export "$JSON_REPORT" \
        --bail \
        --verbose \
        --insecure \
        --timeout-request 30000 \
        --timeout 60000; then
        
        print_success "Tests completed successfully"
        return $SUCCESS
    else
        print_error "Tests failed"
        return $FAILURE
    fi
}

# Generate summary
generate_summary() {
    print_step "Generating test summary..."
    echo ""
    echo "Test Execution Summary:"
    echo "  Collection: $COLLECTION_FILE"
    echo "  Environment: $ENVIRONMENT_FILE"
    echo "  Timestamp: $TIMESTAMP"
    echo "  HTML Report: $HTML_REPORT"
    echo "  JSON Report: $JSON_REPORT"
    echo ""
}

# Display report location
display_report_info() {
    print_success "Test reports generated:"
    echo "  HTML Report: $HTML_REPORT"
    echo "  JSON Report: $JSON_REPORT"
    echo ""
    echo "To view the HTML report, open:"
    echo "  $HTML_REPORT"
}

# Main execution
main() {
    print_header
    
    # Validate prerequisites
    print_step "Checking prerequisites..."
    if ! command -v newman &> /dev/null; then
        print_error "Newman is not installed"
        echo "Install Newman with: npm install -g newman"
        exit $FAILURE
    fi
    print_success "Newman is installed"
    
    # Also check for HTML reporter
    if ! npm list -g newman-reporter-html &> /dev/null; then
        print_step "Installing Newman HTML reporter..."
        npm install -g newman-reporter-html
        print_success "HTML reporter installed"
    fi
    
    echo ""
    
    # Run test workflow
    validate_files
    echo ""
    
    setup_reports
    echo ""
    
    run_tests
    TEST_RESULT=$?
    echo ""
    
    generate_summary
    
    if [ $TEST_RESULT -eq $SUCCESS ]; then
        display_report_info
        print_success "Test execution completed successfully"
        exit $SUCCESS
    else
        display_report_info
        print_error "Test execution failed - see reports for details"
        exit $FAILURE
    fi
}

# Run main function
main "$@"
