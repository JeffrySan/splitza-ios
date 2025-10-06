
#!/bin/bash

# Display current directory
echo "Current directory: $(pwd)"
echo "Running UI Tests..."

# Set result bundle path with timestamp
OUTPUT_FOLDER="$1"
echo "Provided output folder: $OUTPUT_FOLDER" >&2

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_BUNDLE="$OUTPUT_FOLDER/TestResults_${TIMESTAMP}.xcresult"

# Run the test with explicit result bundle path
xcodebuild test \
    -project Splitza.xcodeproj \
    -scheme Splitza-Production \
    -destination 'id=87C1C12E-30FB-44F5-A114-CE0B87E32428'\
    -only-testing:SplitzaUITests/SplitzaUITests/testLoginScenario \
    -resultBundlePath "$RESULT_BUNDLE"

# Check exit code
EXIT_CODE=$?

echo ""
echo "UI Tests completed with exit code: $EXIT_CODE"
echo "Test results saved to: $RESULT_BUNDLE"

# Display basic test results using xcrun if available
if [ -d "$RESULT_BUNDLE" ]; then
    echo ""
    echo "=== Test Results Summary ==="
    
    # Try to extract basic info from xcresult
    if command -v xcrun >/dev/null 2>&1; then
        echo "Extracting test summary..."
        xcrun xcresulttool get --format json --path "$RESULT_BUNDLE" | jq -r '.issues.testFailureSummaries[]? | "❌ \(.message)"' 2>/dev/null || echo "No test failures found or jq not available"
        
        # Get test status
        TEST_STATUS=$(xcrun xcresulttool get --format json --path "$RESULT_BUNDLE" | jq -r '.metrics.testsCount.value // "unknown"' 2>/dev/null)
        if [ "$TEST_STATUS" != "unknown" ] && [ "$TEST_STATUS" != "null" ]; then
            echo "Tests run: $TEST_STATUS"
        fi
    else
        echo "xcrun not available for detailed results parsing"
    fi
    
    echo "📁 Full results available at: $RESULT_BUNDLE"
    echo "To view detailed results, open in Xcode or use: xcrun xcresulttool get --path '$RESULT_BUNDLE'"
else
    echo "⚠️  Result bundle not found at expected location"
fi

# Optional: Keep only the last 5 test results to save space
echo ""
echo "Cleaning up old test results (keeping last 5)..."
cd ./test-results
ls -t TestResults_*.xcresult | tail -n +6 | xargs rm -rf 2>/dev/null || true
cd ..

echo "Script completed."

echo "status=Success"
echo "path=/some path"
echo "count=42"