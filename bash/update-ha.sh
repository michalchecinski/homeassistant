#!/bin/bash

HASS_SERVICE=${HASS_SERVICE:-home-assistant@homeassistant.service}

sudo -u homeassistant -H -s
source /srv/homeassistant/bin/activate
pip3 install --upgrade homeassistant

sudo systemctl restart "$HASS_SERVICE"