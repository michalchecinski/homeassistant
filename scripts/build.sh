#!/bin/bash
#set -euxo pipefail

#REPO_PATH="$( dirname "$( cd "$(dirname "$0")" ; pwd -P )" )"
REPO_PATH="/home/pi/rpi-server"

OLD_HEAD=$(git rev-parse HEAD)

git pull

NEW_HEAD=$(git rev-parse HEAD)

function docker_compose_changed() {
    local filechanged

    if [ "$OLD_HEAD" == "$NEW_HEAD" ]
    then
        echo "false"
        return
    fi

    filechanged=$(git diff --name-only "$OLD_HEAD" "$NEW_HEAD" | egrep 'docker-compose.yaml')

    if [ -f "$filechanged" ]
    then
        echo "true"
        return
    fi

    echo "false"
    return
}

docker_recreate=$(docker_compose_changed)

if [ "$docker_recreate" == "true" ]
then
    docker-compose -f "$REPO_PATH"/docker-compose.yaml down --remove-orphans
    sleep 5
    docker-compose -f "$REPO_PATH"/docker-compose.yaml up -d
else
    docker-compose -f "$REPO_PATH"/docker-compose.yaml restart
fi