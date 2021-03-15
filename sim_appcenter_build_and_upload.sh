#!/usr/bin/env bash

set -eu -o pipefail

SIM_XCODE_DATA_PATH=/tmp/${SIM_XCODE_SCHEME}-$(uuidgen)
WALDO_CLI_BIN=$(unset CDPATH && cd "${0%/*}" &>/dev/null && pwd)

function cancel_appcenter_build() {
    [[ -n $SIM_APPCENTER_API_TOKEN ]] || return
    [[ -n $SIM_APPCENTER_APP_NAME ]] || return
    [[ -n $SIM_APPCENTER_OWNER_NAME ]] || return

    curl --data "{\"status\":\"cancelling\"}"               \
         --header 'Content-Type: application/json'          \
         --header "X-API-Token: $SIM_APPCENTER_API_TOKEN"   \
         --include                                          \
         --request PATCH                                    \
         "https://appcenter.ms/api/v0.1/apps/${SIM_APPCENTER_OWNER_NAME}/${SIM_APPCENTER_APP_NAME}/builds/${APPCENTER_BUILD_ID}"
}

function create_sim_build() {
    local _xcode_project_suffix=${SIM_XCODE_PROJECT##*.}

    if [[ $_xcode_project_suffix == "xcworkspace" ]]; then
        xcodebuild -workspace "$SIM_XCODE_PROJECT"                  \
                   -scheme "$SIM_XCODE_SCHEME"                      \
                   -configuration "$SIM_XCODE_CONFIGURATION"        \
                   -destination 'generic/platform=iOS Simulator'    \
                   -derivedDataPath "$SIM_XCODE_DATA_PATH"          \
                   clean build || exit
    else
        xcodebuild -project "$SIM_XCODE_PROJECT"                    \
                   -scheme "$SIM_XCODE_SCHEME"                      \
                   -configuration "$SIM_XCODE_CONFIGURATION"        \
                   -destination 'generic/platform=iOS Simulator'    \
                   -derivedDataPath "$SIM_XCODE_DATA_PATH"          \
                   clean build || exit
    fi
}

function upload_sim_build() {
    local _build_path="$SIM_XCODE_DATA_PATH"/Build/Products/"$SIM_XCODE_CONFIGURATION"-iphonesimulator/"$SIM_XCODE_APP_NAME"

    ${WALDO_CLI_BIN}/waldo "$_build_path" --include_symbols
}

create_sim_build || exit
upload_sim_build || exit
cancel_appcenter_build || exit

exit
