#!/bin/bash

docker-compose down
docker rm -f redis-node-1 redis-node-2 redis-node-3
docker network disconnect -f redis-cluster_mynetwork redis-node-1
docker network disconnect -f redis-cluster_mynetwork redis-node-2
docker network disconnect -f redis-cluster_mynetwork redis-node-3
docker-compose down
