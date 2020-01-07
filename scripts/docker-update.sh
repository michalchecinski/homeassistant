#!/bin/bash

docker-compose down --remove-orphans

docker-compose pull
docker-compose up --build -d

docker network prune -f
docker volume prune -f