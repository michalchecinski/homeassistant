#!/bin/bash

docker-compose pull

sleep 5

docker-compose down --remove-orphans

sleep 5

docker-compose up --build -d

docker network prune -f
docker volume prune -f