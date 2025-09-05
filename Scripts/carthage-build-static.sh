#!/bin/sh -e

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

NEW_LD_PATH="$PWD/Scripts/ld.py"

echo "$NEW_LD_PATH"
echo "LD = $PWD/ld.py" >> $xcconfig
echo "DEBUG_INFORMATION_FORMAT = dwarf" >> $xcconfig
echo "MACH_O_TYPE = staticlib" >> $xcconfig
# echo "BUILD_LIBRARY_FOR_DISTRIBUTION = YES" >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"

carthage build "$@"
