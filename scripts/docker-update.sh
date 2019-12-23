#!/bin/bash

docker-compose rm -f --remove-orphans

docker container prune -f
docker network prune -f
docker volume prune -f

docker-compose pull
docker-compose up --build -d

docker network prune -f
docker volume prune -f