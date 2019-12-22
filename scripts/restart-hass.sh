#!/bin/bash
set -euxo pipefail

docker-compose -f "$HASS_PATH"/docker-compose.yaml restart hass-