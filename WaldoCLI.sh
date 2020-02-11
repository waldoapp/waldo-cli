#!/usr/bin/env bash

set -eu -o pipefail

waldo_api_build_endpoint=${WALDO_API_BUILD_ENDPOINT:-https://api.waldo.io/versions}
waldo_api_error_endpoint=${WALDO_API_ERROR_ENDPOINT:-https://api.waldo.io/uploadError}
waldo_cli_version="1.4.2"

waldo_build_flavor=""
waldo_build_path=""
waldo_build_suffix=""
waldo_current_commit=""
waldo_extra_args="--show-error --silent"
waldo_history=""
waldo_history_error=""
waldo_platform=""
waldo_upload_path=""
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
    waldo_build_suffix=${waldo_build_path##*.}

    case $waldo_build_suffix in
        apk)     waldo_build_flavor="Android" ;;
        app|ipa) waldo_build_flavor="iOS" ;;
        *)       fail "File extension of build at ‘${waldo_build_path}’ is not recognized" ;;
    esac
}

function check_history() {
    if [[ -z $(which base64) ]]; then
        waldo_history_error="noBase64CommandFound"
    elif [[ -z $(which cut) ]]; then
        waldo_history_error="noCutCommandFound"
    elif [[ -z $(which git) ]]; then
        waldo_history_error="noGitCommandFound"
    elif [[ -z $(which grep) ]]; then
        waldo_history_error="noGrepCommandFound"
    elif [[ -z $(which tr) ]]; then
        waldo_history_error="noTr64CommandFound"
    elif ! git rev-parse >& /dev/null; then
        waldo_history_error="notGitRepository"
    else
        waldo_current_commit=$(get_current_commit)
        waldo_history=$(get_history)
    fi
}

function check_platform() {
    if [[ -z $(which curl) ]]; then
        fail "No ‘curl’ command found"
    fi
}

function check_status() {
    local _response=$1

    local _regex='"status":([0-9]+)'

    if [[ $_response =~ $_regex ]]; then
        local _status=${BASH_REMATCH[1]}

        if (( $_status == 401 )); then
            fail "Upload token is invalid or missing!"
        elif (( $_status < 200 || $_status > 299 )); then
            fail "Unable to upload build to Waldo, HTTP status: $_status"
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

function convert_sha() {
    local _full_sha=$1
    local _full_name=$(git name-rev --refs='heads/*' --name-only "$_full_sha")
    local _abbr_sha=${_full_sha:0:7}
    local _abbr_name=$_full_name
    local _prefix="remotes/origin/"

    if [[ ${_full_name:0:${#_prefix}} == $_prefix ]]; then
        _abbr_name=${_full_name#$_prefix}
    else
        _abbr_name="local:${_full_name}"
    fi

    echo "${_abbr_sha}-${_abbr_name}"
}

function convert_shas() {
    local _list=

    while (( $# )); do
        local _item=$(convert_sha "$1")

        _list+=",\"${_item}\""

        shift
    done

    echo ${_list#?}
}

function curl_upload_build() {
    local _output_path="$1"
    local _authorization=$(get_authorization)
    local _content_type=$(get_build_content_type)
    local _user_agent=$(get_user_agent)
    local _url=$(make_build_url)

    curl $waldo_extra_args                          \
        --data-binary @"$waldo_upload_path"         \
        --header "Authorization: $_authorization"   \
        --header "Content-Type: $_content_type"     \
        --header "User-Agent: $_user_agent"         \
        --output "$_output_path"                    \
        "$_url"

    local _curl_status=$?

    if (( $_curl_status != 0 )); then
        fail "Unable to upload build to Waldo, curl error: ${_curl_status}, url: ${_url}"
    fi
}

function curl_upload_error() {
    local _message=$(json_escape "$1")
    local _ci=$(get_ci)
    local _authorization=$(get_authorization)
    local _content_type=$(get_error_content_type)
    local _user_agent=$(get_user_agent)
    local _url=$(make_error_url)

    curl --silent                                                   \
        --data "{\"message\":\"${_message}\",\"ci\":\"${_ci}\"}"    \
        --header "Authorization: $_authorization"                   \
        --header "Content-Type: $_content_type"                     \
        --header "User-Agent: $_user_agent"                         \
        "$_url" &>/dev/null
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
    waldo_platform=$(get_platform)

    echo "Waldo CLI $waldo_cli_version ($waldo_platform)"
}

function fail() {
    local _message="waldo: $1"

    if [[ -n $waldo_upload_token ]]; then
        curl_upload_error "$1"

        local _curl_status=$?

        if (( $_curl_status == 0)); then
            _message+=" -- Waldo team has been informed"
        fi
    fi

    echo ""                 # flush stdout
    echo "$_message" 1>&2
    exit 1
}

function fail_usage() {
    [[ -z $waldo_upload_token ]] || curl_upload_error "$1"

    echo ""                 # flush stdout
    echo "waldo: $1" 1>&2
    display_usage
    exit 1
}

function get_authorization() {
    echo "Upload-Token $waldo_upload_token"
}

function get_build_content_type() {
    case $waldo_build_suffix in
        app) echo "application/zip" ;;
        *)   echo "application/octet-stream" ;;
    esac
}

function get_ci() {
    if [[ ${BITRISE_IO:-false} == true ]]; then
        echo "bitrise"
    else
        echo "unknown"
    fi
}

function get_current_commit() {
    git log --decorate=full --format='%H %D' -50 | grep -F -m1 refs/remotes | cut -d' ' -f1
}

function get_error_content_type() {
    echo "application/json"
}

function get_history() {
    local _shas=$(git log --format='%H' -50)
    local _history=$(convert_shas $_shas)

    echo "[${_history}]" | websafe_base64_encode
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

function json_escape() {
    local _result=${1//\\/\\\\} # \

    _result=${_result//\//\\\/} # /
    _result=${_result//\'/\\\'} # '
    _result=${_result//\"/\\\"} # "

    echo "$_result"
}

function make_build_url() {
    local _query=

    if [[ -n $waldo_current_commit ]]; then
        _query+="&currentCommit=$waldo_current_commit"
    fi

    if [[ -n $waldo_history ]]; then
        _query+="&history=$waldo_history"
    fi

    if [[ -n $waldo_history_error ]]; then
        _query+="&historyError=$waldo_history_error"
    fi

    if [[ -n $waldo_variant_name ]]; then
        _query+="&variantName=$waldo_variant_name"
    fi

    if [[ -n $_query ]]; then
        echo "${waldo_api_build_endpoint}?${_query:1}"
    else
        echo "${waldo_api_build_endpoint}"
    fi
}

function make_error_url() {
    echo "${waldo_api_error_endpoint}"
}

function upload_build() {
    local _parent_path=$(dirname "$waldo_build_path")
    local _build_name=$(basename "$waldo_build_path")
    local _working_path=/tmp/WaldoCLI-$$

    rm -rf "$_working_path"
    mkdir -p "$_working_path"

    case $waldo_build_suffix in
        app)
            ([[ -d $waldo_build_path ]] && [[ -r $waldo_build_path ]])  \
                || fail "Unable to read build at ‘${waldo_build_path}’"

            if [[ -z $(which zip) ]]; then
                fail "No ‘zip’ command found"
            fi

            waldo_upload_path=$_working_path/$_build_name.zip

            (cd "$_parent_path" &>/dev/null && zip -qry "$waldo_upload_path" "$_build_name") || exit
            ;;

        *)
            ([[ -f $waldo_build_path ]] && [[ -r $waldo_build_path ]])  \
                || fail "Unable to read build at ‘${waldo_build_path}’"

            waldo_upload_path=$waldo_build_path
            ;;
    esac

    local _response_path=$_working_path/response.json

    echo "Uploading the build to Waldo. This could take a while…"

    [[ $waldo_extra_args == "--verbose" ]] && echo ""

    curl_upload_build "$_response_path"

    local _curl_status=$?
    local _response=$(cat "$_response_path" 2>/dev/null)

    [[ $waldo_extra_args == "--verbose" ]] && echo "$_response"

    [[ $waldo_extra_args == "--verbose" ]] && echo ""

    if [[ -n $_working_path ]]; then
        rm -rf "$_working_path"
    fi

    check_status "$_response"

    if (( $_curl_status == 0 )); then
        echo "Build ‘${_build_name}’ successfully uploaded to Waldo!"
    fi
}

function websafe_base64_encode() {
    base64 | tr -d '=\n' | tr '/+' '_-'
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

check_platform || exit
check_build_path || exit
check_history || exit
check_upload_token || exit
check_variant_name || exit

upload_build || exit

exit
