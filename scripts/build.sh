#!/bin/bash
set -euxo pipefail


REPO_PATH="/home/pi/homeassistant"


function remote_git() {
    git --git-dir "$HASS_PATH"/.git --work-tree="$HASS_PATH" "$@"
}

function docker_compose_changed() {
    local filechanged

    if [ "$OLD_HEAD" == "$NEW_HEAD" ]
    then
        echo "false"
        return
    fi

    filechanged=$(remote_git diff --name-only "$OLD_HEAD" "$NEW_HEAD" | egrep 'docker-compose.yaml|build.sh')

    if [ -f "$filechanged" ]
    then
        echo "true"
        return
    fi

    echo "false"
    return
}

OLD_HEAD="$(remote_git rev-parse HEAD)"

remote_git pull

NEW_HEAD="$(remote_git rev-parse HEAD)"

docker_recreate=$(docker_compose_changed)

if [ "$docker_recreate" == "true" ]
then
    docker-compose -f "$REPO_PATH"/docker-compose.yaml down --remove-orphans
    sleep 5
    docker-compose -f "$REPO_PATH"/docker-compose.yaml up -d
    docker network prune -f
    docker volume prune -f
else
    docker-compose -f "$REPO_PATH"/docker-compose.yaml restart hass
fi