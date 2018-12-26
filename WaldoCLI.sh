#!/usr/bin/env bash

set -eu -o pipefail

waldo_cli_version="1.0.0"

waldo_api_key=""
waldo_application_id=""
waldo_build_path=""
waldo_build_flavor=""
waldo_config_path=""
waldo_extra_args="--show-error --silent"

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

function check_api_key() {
    [[ -n $waldo_api_key ]] || waldo_api_key=${WALDO_API_KEY:-}
    [[ -n $waldo_api_key ]] || fail_usage "Missing required option: ‘--key’"
}

function check_application_id() {
    [[ -n $waldo_application_id ]] || waldo_application_id=${WALDO_APPLICATION_ID:-}
    [[ -n $waldo_application_id ]] || fail_usage "Missing required option: ‘--application’"
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

function check_config_path() {
    local _ignore_missing
    local _search_path

    if [[ -z $waldo_config_path ]]; then
        _ignore_missing=true
        _search_path=$(pwd)
    elif [[ ! -d $waldo_config_path ]]; then
        waldo_config_path=$(abs_path "$waldo_config_path")
        return
    else
        _ignore_missing=false
        _search_path=$(abs_path "$waldo_config_path")
    fi

    for _path in "$_search_path"/.waldo.{yml,yaml}; do
        if [[ -e $_path ]]; then
            waldo_config_path=$_path
            return
        fi
    done

    $_ignore_missing || fail "Configuration not found in ‘${_search_path}’"
}

function check_status() {
    local _response=$1

    local _regex='"status":([0-9]+)'

    if [[ $_response =~ $_regex ]]; then
        local _status=${BASH_REMATCH[1]}

        if (( $_status == 401 )); then
            fail "API key is invalid or missing!"
        elif (( $_status < 200 || $_status > 299 )); then
            fail "Build failed to upload to Waldo: $_status"
        fi
    fi
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

  --application <value>   Waldo application ID
  --configuration <path>  Use configuration file
  --help                  Display available options
  --key <value>           Waldo API key
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
    echo "Upload-Token $waldo_api_key"
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
    echo "https://api.waldo.io/versions?variantName=manual"
}

function read_configuration() {
    [[ -n $waldo_config_path ]] || return 0     # NOT an error

    local _suffix=${waldo_config_path##*.}

    case $_suffix in
        yaml|yml)
            read_yaml_configuration || return
            ;;

        *)
            fail "File extension of configuration at ‘${waldo_config_path}’ is not recognized"
            ;;
    esac
}

function read_yaml_configuration() {
    ([[ -f $waldo_config_path ]] && [[ -r $waldo_config_path ]])    \
        || fail "Unable to read configuration at ‘${waldo_config_path}’"

    local _regex="^([a-zA-Z0-9_]+):[ \t]*(.*)[ \t]*$"

    while read _line; do
        if [[ $_line =~ $_regex ]]; then
            local _key=${BASH_REMATCH[1]}
            local _value=${BASH_REMATCH[2]}

            case $_key in
                api_key)        [[ -n $waldo_api_key ]] || waldo_api_key=$_value ;;
                application_id) [[ -n $waldo_application_id ]] || waldo_application_id=$_value ;;
                *)              ;;
            esac
        fi
    done < "$waldo_config_path"
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
        --application)
            if (( $# < 2 )) || [[ -z $2 || ${2:0:1} == "-" ]]; then
                fail_usage "Missing required value for option: ‘${1}’"
            else
                waldo_application_id=$2
                shift
            fi
            ;;

        --configuration)
            if (( $# < 2 )) || [[ -z $2 || ${2:0:1} == "-" ]]; then
                fail_usage "Missing required value for option: ‘${1}’"
            else
                waldo_config_path=$2
                shift
            fi
            ;;

        --help)
            display_usage
            exit
            ;;

        --key)
            if (( $# < 2 )) || [[ -z $2 || ${2:0:1} == "-" ]]; then
                fail_usage "Missing required value for option: ‘${1}’"
            else
                waldo_api_key=$2
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

check_config_path || exit

read_configuration || exit

check_build_path || exit
check_api_key || exit
check_application_id || exit

upload_build || exit

exit
