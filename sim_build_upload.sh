#!/usr/bin/env bash

SIM_DATA_PATH=/tmp/YourApp-$(uuidgen)

SIM_WORKSPACE=YourApp.xcworkspace
#SIM_PROJECT=YourApp.xcodeproj          # see comment below
SIM_SCHEME=YourApp
SIM_CONFIGURATION=Release
SIM_APP_NAME=YourApp.app

#
# If your app’s Xcode project does NOT use a workspace, replace
# `-workspace "$SIM_WORKSPACE"` with `-project "$SIM_PROJECT"` below:
#
xcodebuild -workspace "$SIM_WORKSPACE"                      \
           -scheme "$SIM_SCHEME"                            \
           -configuration "$SIM_CONFIGURATION"              \
           -destination 'generic/platform=iOS Simulator'    \
           -derivedDataPath "$SIM_DATA_PATH"                \
           clean build || exit

WALDO_CLI_BIN=/usr/local/bin

export WALDO_UPLOAD_TOKEN=0123456789abcdef0123456789abcdef

BUILD_PATH="$SIM_DATA_PATH"/Build/Products/"$SIM_CONFIGURATION"-iphonesimulator/"$SIM_APP_NAME"

${WALDO_CLI_BIN}/waldo "$BUILD_PATH" --include_symbols

exit
