#!/bin/bash

# Ensure the script exits on any error
set -e

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define the output folder
OUTPUT_FOLDER="$(pwd)/instrument-output"
APP_DERIVED_DATA="$(find ~/Library/Developer/Xcode/DerivedData/Splitza-**/Build/Products -name Release-iphonesimulator)"
APP_PATH="$(find $APP_DERIVED_DATA -name "*Splitza.app" -print | head -n 1)"
DSYM_PATH="$(find $APP_DERIVED_DATA -name '*Splitza.*.dSYM' -print | head -n 1)"
TRACE_OUTPUT="$OUTPUT_FOLDER/Splitza.trace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"

# Debugging information
# Get relative paths (trimmed for readability)
APP_PATH_REL="${APP_PATH#$APP_DERIVED_DATA}"
DSYM_PATH_REL="${DSYM_PATH#$APP_DERIVED_DATA}"

# Header
echo -e "${BOLD}${CYAN}📱 Starting iOS Instrumentation Script...${NC}\n"

# Use printf for aligned output
printf "${YELLOW}%-25s${NC} ${GREEN}%s${NC}\n" "📁 App Derived Data:" "$APP_DERIVED_DATA"
printf "${YELLOW}%-25s${NC} ${GREEN}...%s${NC}\n" "📦 App Path:" "$APP_PATH_REL"
printf "${YELLOW}%-25s${NC} ${GREEN}...%s${NC}\n" "🐞 dSYM Path:" "$DSYM_PATH_REL"
printf "${YELLOW}%-25s${NC} ${GREEN}%s${NC}\n" "🗂  Output Folder:" "$OUTPUT_FOLDER"
printf "${YELLOW}%-25s${NC} ${GREEN}%s${NC}\n" "📊 Trace Output:" "$TRACE_OUTPUT"

# Footer
echo -e "\n${BOLD}${BLUE}✅ Initialization complete. Ready to run instrumentation.${NC}\n"

# Clean up the output folder for a fresh start
if [ -d "$OUTPUT_FOLDER" ]; then
  echo -e "${BOLD}${YELLOW}Cleaning up the output folder:${NC} $OUTPUT_FOLDER"
  rm -rf "$OUTPUT_FOLDER"
fi
mkdir -p "$OUTPUT_FOLDER"

RESULT=$("$SCRIPT_DIR/run-test-case.sh" "$OUTPUT_FOLDER")

# Parse line-by-line
while IFS='=' read -r key value; do
  case "$key" in
    status) STATUS="$value" ;;
    path) PATH="$value" ;;
    count) COUNT="$value" ;;
  esac
done <<< "$RESULT"

echo "Status 1: $STATUS"
echo "Path 2 : $PATH"
echo "Count 3: $COUNT"

exit 0

if [ -z "$APP_PATH" ]; then
  echo -e "${BOLD}${RED}Error:${NC} No built app found. Please run ./run-test-case.sh first."
  exit 1
fi

# Launch xctrace with the System Trace template and specified options
xctrace record \
  --template "System Trace" \
  --device-name "87C1C12E-30FB-44F5-A114-CE0B87E32428" \
  --window 5s \
  --time-limit 5s \
  --output "$TRACE_OUTPUT" \
  --launch "$APP_PATH"

# Check if the trace file was created
if [ -d "$TRACE_OUTPUT" ]; then
  echo -e "\n${BOLD}${GREEN}✅ Trace file generated successfully!${NC}"

  # Find and copy the dSYM file to the output folder
  if [ -n "$DSYM_PATH" ]; then
    cp -R "$DSYM_PATH" "$OUTPUT_FOLDER"
    
    printf "${GREEN}📦 Copied dSYM to output folder:${NC} %s\n" "$OUTPUT_FOLDER"
  else
    echo -e "${RED}⚠️  Warning: No dSYM file found.${NC}"
  fi
else
  echo -e "\n${RED}❌ Error: Trace file was not created.${NC}"
  exit 1
fi

# Notify the user about the final output status
if [ $? -eq 0 ]; then
  printf "\n${BOLD}${CYAN}📁 All outputs saved to:${NC} %s\n" "$OUTPUT_FOLDER"
else
  echo -e "${RED}❌ Error: Failed to save outputs.${NC}"
fi

echo -e "\n${BOLD}${BLUE}🏁 Instrumentation completed.${NC}\n"