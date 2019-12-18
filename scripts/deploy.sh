#!/bin/bash

# build setting
BASE_API_PATH='https://dev.azure.com/michalchecinski/hassmch/_apis'
HASS_BUILD_PATH='build/builds?definitions=15&statusFilter=completed&resultFilter=partiallySucceeded,succeeded'

# pi settings
HASS_PATH="/home/pi/homeassistant"

# not change
LAST_HASS_BUILD_FILEPATH="/tmp/hass_last_devops_build"

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
    [ ! -f "$LAST_HASS_BUILD_FILEPATH" ] && touch "$LAST_HASS_BUILD_FILEPATH"

    latest_build_number=$(fetch_latest_build_number)
    saved_build_number=$(cat "$LAST_HASS_BUILD_FILEPATH")

    # If the build number is the same as the last one retrieved, don't trigger
    # a build:
    if [ "$latest_build_number" == "$saved_build_number" ]
    then
        echo "false"
        return
    fi

    echo "$latest_build_number" > "$LAST_HASS_BUILD_FILEPATH"

    echo "true"
}
updated="$(should_update)"

if [ "$updated" == "true" ]
then
    remote_git pull
    sleep 1
    bash "$HASS_PATH"/scripts/build.sh
    echo "Build finished"
else
    echo "No deployment required"
fi
