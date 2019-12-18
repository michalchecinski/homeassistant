#!/bin/bash

docker-compose rm -f --remove-orphans
docker-compose pull
docker-compose up --build -d