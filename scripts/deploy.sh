#!/bin/bash
set -euxo pipefail

# pi settings
HASS_PATH="/home/pi/homeassistant"

SLACK_HOOK_URL=$(cat "$HASS_PATH/scripts/slack_webhook.txt")
COLOR_BLUE="#1539e0"
COLOR_GREEN="good"
COLOR_RED="danger"
#COLOR_YELLOW="warning"

function remote_git() {
    git --git-dir "$HASS_PATH"/.git --work-tree="$HASS_PATH" "$@"
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

function docker_compose_changed() {
    local filechanged
    local OLD_HEAD="$1"
    local NEW_HEAD="$2"

    if [ "$OLD_HEAD" == "$NEW_HEAD" ]
    then
        echo "false"
        return
    fi

    filechanged=$(remote_git diff --name-only "$OLD_HEAD" "$NEW_HEAD" | egrep 'docker-compose.yaml|build.sh|restart-hass.sh')

    if [ -f "$filechanged" ]
    then
        echo "true"
        return
    fi

    echo "false"
    return
}

OLD_HEAD="$(remote_git rev-parse HEAD)"

git_pull_result="$(remote_git pull > /dev/null 2>&1)"
if [ "$git_pull_result" == "1" ]; then
    send_slack_message \
        "Deployment failed due to failed Git pull on target host" \
        "$COLOR_RED"
    return
fi

NEW_HEAD="$(remote_git rev-parse HEAD)"

# saved_build_number="$1"

send_slack_message \
    "Deployment for build starting..." \
    "$COLOR_BLUE"

docker_recreate=$(docker_compose_changed "$OLD_HEAD" "$NEW_HEAD")

if [ "$docker_recreate" == "true" ]
then
    bash "$HASS_PATH"/scripts/build.sh
else
    bash "$HASS_PATH"/scripts/restart-hass.sh
fi

send_slack_message \
    "Deployment for build completed" \
    "$COLOR_GREEN"

echo "Build finished"
