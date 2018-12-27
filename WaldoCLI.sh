#!/usr/bin/env bash

set -eu -o pipefail

waldo_cli_version="1.1.0"

waldo_build_path=""
waldo_build_flavor=""
waldo_extra_args="--show-error --silent"
waldo_upload_token=""
waldo_variant_name=""

function abs_path() {
    local _rel_path=$1

    [[ -n $_rel_path ]] || _rel_path="."

    case "$_rel_path" in
        .)  pwd ;;
        ..) (unset CDPATH && cd .. &>/dev/null && pwd) ;;
        /*) echo $_rel_path ;;
        *)  local _dirname=$(dirname "$_rel_path")

            _dirname=$(unset CDPATH && cd "$_dirname" &>/dev/null && pwd)

            if [[ -n $_dirname ]]; then
                echo ${_dirname}/$(basename "$_rel_path")
            else
                echo $_rel_path
            fi
            ;;
    esac
}

function check_build_path() {
    [[ -n $waldo_build_path ]] || fail_usage "Missing required argument: ‘path’"

    waldo_build_path=$(abs_path "$waldo_build_path")

    local _suffix=${waldo_build_path##*.}

    case $_suffix in
        apk) waldo_build_flavor="Android" ;;
        ipa) waldo_build_flavor="iOS" ;;
        *)   fail "File extension of build at ‘${waldo_build_path}’ is not recognized" ;;
    esac
}

function check_status() {
    local _response=$1

    local _regex='"status":([0-9]+)'

    if [[ $_response =~ $_regex ]]; then
        local _status=${BASH_REMATCH[1]}

        if (( $_status == 401 )); then
            fail "Upload token is invalid or missing!"
        elif (( $_status < 200 || $_status > 299 )); then
            fail "Build failed to upload to Waldo: $_status"
        fi
    fi
}

function check_upload_token() {
    [[ -n $waldo_upload_token ]] || waldo_upload_token=${WALDO_UPLOAD_TOKEN:-}
    [[ -n $waldo_upload_token ]] || fail_usage "Missing required option: ‘--upload_token’"
}

function check_variant_name() {
    [[ -n $waldo_variant_name ]] || waldo_variant_name=${WALDO_VARIANT_NAME:-}
}

function curl_upload_build() {
    local _authorization=$(get_authorization)
    local _content_type="application/octet-stream"
    local _user_agent=$(get_user_agent)
    local _url=$(make_url)

    curl $waldo_extra_args                          \
        --data-binary @"$waldo_build_path"          \
        --header "Authorization: $_authorization"   \
        --header "Content-Type: $_content_type"     \
        --header "User-Agent: $_user_agent"         \
        "$_url" || fail "Build failed to upload to Waldo: $?"
}

function display_usage() {
    cat <<EOF

OVERVIEW: Upload build to Waldo

USAGE: waldo [options] <path>

OPTIONS:

  --help                  Display available options
  --upload_token <value>  Waldo upload token
  --variant_name <value>  Waldo variant name
  --verbose               Display extra verbiage
EOF
}

function display_version() {
    local _platform=$(get_platform)

    echo "Waldo CLI $waldo_cli_version ($_platform)"
}

function fail() {
    echo ""                 # flush stdout
    echo "waldo: $1" 1>&2
    exit 1
}

function fail_usage() {
    echo ""                 # flush stdout
    echo "waldo: $1" 1>&2
    display_usage
    exit 1
}

function get_authorization() {
    echo "Upload-Token $waldo_upload_token"
}

function get_platform() {
    local _os_name=$(uname -s)

    case $_os_name in
        Darwin) echo "macOS" ;;
        *)      echo "$_os_name" ;;
    esac
}

function get_user_agent() {
    echo "Waldo CLI/$waldo_build_flavor v$waldo_cli_version"
}

function make_url() {
    if [[ -z $waldo_variant_name ]]; then
        echo "https://api.waldo.io/versions"
    else
        echo "https://api.waldo.io/versions?variantName=$waldo_variant_name"
    fi
}

function upload_build() {
    ([[ -f $waldo_build_path ]] && [[ -r $waldo_build_path ]])  \
        || fail "Unable to read build at ‘${waldo_build_path}’"

    echo "Uploading the build to Waldo. This could take a while…"

    [[ $waldo_extra_args == "--verbose" ]] && echo ""

    local _response=$(curl_upload_build)

    check_status "$_response"

    [[ $waldo_extra_args == "--verbose" ]] && echo "$_response"

    local _build_name=$(basename "$waldo_build_path")

    [[ $waldo_extra_args == "--verbose" ]] && echo ""

    echo "Build ‘${_build_name}’ successfully uploaded to Waldo!"
}

display_version

while (( $# )); do
    case $1 in
        --help)
            display_usage
            exit
            ;;

        --upload_token)
            if (( $# < 2 )) || [[ -z $2 || ${2:0:1} == "-" ]]; then
                fail_usage "Missing required value for option: ‘${1}’"
            else
                waldo_upload_token=$2
                shift
            fi
            ;;

        --variant_name)
            if (( $# < 2 )) || [[ -z $2 || ${2:0:1} == "-" ]]; then
                fail_usage "Missing required value for option: ‘${1}’"
            else
                waldo_variant_name=$2
                shift
            fi
            ;;

        --verbose)
            waldo_extra_args="--verbose"
            ;;

        -*)
            fail_usage "Unknown option: ‘${1}’"
            ;;

        *)
            if [[ -n $waldo_build_path ]]; then
                fail_usage "Unknown argument: ‘${1}’"
            else
                waldo_build_path=$1
            fi
            ;;
    esac

    shift
done

check_build_path || exit
check_upload_token || exit
check_variant_name || exit

upload_build || exit

exit
