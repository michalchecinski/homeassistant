#!/bin/bash

# build setting
BASE_API_PATH='https://dev.azure.com/michalchecinski/hassmch/_apis'
HASS_BUILD_PATH='build/builds?definitions=15&statusFilter=completed&resultFilter=partiallySucceeded,succeeded'
SERVER_BUILD_PATH='build/builds?definitions=16&statusFilter=completed&resultFilter=succeeded'

# pi settings
SERVER_PATH="/home/pi/rpi-server"
HASS_PATH="/home/pi/rpi-server/docker_files/homeassistant"

# not change
LAST_SERVER_BUILD_FILEPATH="/tmp/server_last_devops_build"
LAST_HASS_BUILD_FILEPATH="/tmp/hass_last_devops_build"

function remote_git_server() {
    git --git-dir "$SERVER_PATH"/.git --work-tree="$SERVER_PATH" "$@"
}

function remote_git_hass() {
    git --git-dir "$HASS_PATH"/.git --work-tree="$HASS_PATH" "$@"
}

function fetch_latest_hass_build_number() {
    curl \
        -s "$BASE_API_PATH/$HASS_BUILD_PATH" \
        | jq '.value[0].buildNumber'
}

function fetch_latest_server_build_number() {
    curl \
        -s "$BASE_API_PATH/$SERVER_BUILD_PATH" \
        | jq '.value[0].buildNumber'
}

function should_update_server() {
    local latest_build_number
    local saved_build_number

    # If the last build file doesn't exist, create it:
    [ ! -f "$LAST_SERVER_BUILD_FILEPATH" ] && touch "$LAST_SERVER_BUILD_FILEPATH"

    latest_build_number=$(fetch_latest_server_build_number)
    saved_build_number=$(cat "$LAST_SERVER_BUILD_FILEPATH")

    # If the build number is the same as the last one retrieved, don't trigger
    # a build:
    if [ "$latest_build_number" == "$saved_build_number" ]
    then
        echo "false"
        return
    fi

    echo "$latest_build_number" > "$LAST_SERVER_BUILD_FILEPATH"

    echo "true"
}

function should_update_hass() {
    local latest_build_number
    local saved_build_number

    # If the last build file doesn't exist, create it:
    [ ! -f "$LAST_HASS_BUILD_FILEPATH" ] && touch "$LAST_HASS_BUILD_FILEPATH"

    latest_build_number=$(fetch_latest_hass_build_number)
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

server_update="$(should_update_server)"
#if [ "$server_update" == "true" ]
#then
#    echo "Deploy server"
#    remote_git_server pull
#fi

hass_update="$(should_update_hass)"
#if [ "$hass_update" == "true" ]
#then
#    echo "Deploy hass"
#    remote_git_hass pull
#fi

if [ "$hass_update" == "true" ] || [ "$server_update" == "true" ]
then
    remote_git_server pull --recurse-submodules
    sleep 1
    bash "$SERVER_PATH"/build.sh
    echo "Build finished"
else
    echo "No deployment required"
fi
