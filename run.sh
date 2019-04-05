#!/bin/bash

docker ps -aq | xargs docker stop | xargs docker rm; docker volume rm -f $(docker volume ls -q);

docker-compose build

docker-compose up
