#!/bin/bash

cd "/home/pi/homeassistant/"
git pull
sudo cp /home/pi/homeassistant/ /home/homeassistant/.homeassistant/ -rf