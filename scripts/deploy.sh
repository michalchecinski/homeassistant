#!/bin/bash

# build setting
BASE_API_PATH='https://dev.azure.com/michalchecinski/hassmch/_apis'
HASS_BUILD_PATH='build/builds?definitions=15&statusFilter=completed&resultFilter=partiallySucceeded,succeeded'

# pi settings
HASS_PATH="/home/pi/homeassistant"

# not change
LAST_BUILD_FILEPATH="/tmp/hass_last_devops_build"

SLACK_HOOK_URL=$(cat "$HASS_PATH/scripts/slack_webhook.txt")
COLOR_BLUE="#1539e0"
COLOR_GREEN="good"
COLOR_RED="danger"
#COLOR_YELLOW="warning"

function remote_git() {
    git --git-dir "$HASS_PATH"/.git --work-tree="$HASS_PATH" "$@"
}

function fetch_latest_build_number() {
    curl \
        -s "$BASE_API_PATH/$HASS_BUILD_PATH" \
        | jq '.value[0].buildNumber'
}

function should_update() {
    local latest_build_number
    local saved_build_number

    # If the last build file doesn't exist, create it:
    [ ! -f "$LAST_BUILD_FILEPATH" ] && touch "$LAST_BUILD_FILEPATH"

    latest_build_number=$(fetch_latest_build_number)
    saved_build_number=$(cat "$LAST_BUILD_FILEPATH")

    # If the build number is the same as the last one retrieved, don't trigger
    # a build:
    if [ "$latest_build_number" == "$saved_build_number" ]
    then
        echo "false"
        return
    fi

    echo "$latest_build_number" > "$LAST_BUILD_FILEPATH"

    echo "true"
}

function send_slack_message() {
   local color="$2"
   local text="$1"
   local message
   message="\`homeassistant/master\`: $text"

   curl \
       -X "POST" \
     -H 'Content-Type: application/json' \
     -d $'{ "attachments": [ { "color": "'"$color"'", "text": "'"$message"'" } ] }' \
    "$SLACK_HOOK_URL"
}

updated="$(should_update)"

if [ "$updated" == "true" ]
then
    git_pull_result="$(remote_git pull > /dev/null 2>&1)"
    if [ "$git_pull_result" == "1" ]; then
        send_slack_message \
            "Deployment failed due to failed Git pull on target host" \
            "$COLOR_RED"
        return
    fi

    saved_build_number=$(cat "$LAST_BUILD_FILEPATH")

    send_slack_message \
        "Deployment for build #$saved_build_number starting..." \
        "$COLOR_BLUE"

    bash "$HASS_PATH"/scripts/build.sh

    send_slack_message \
        "Deployment for build #$saved_build_number completed" \
        "$COLOR_GREEN"

    echo "Build finished"
else
    echo "No deployment required"
fi
