#!/bin/bash

MASTER_PORT=10001
NODE_PORT=10002
SENTINEL_PORT=10003

if [ $(docker network ls | grep -c "mynetwork") -gt 1 ]; then
  docker network create --subnet=172.10.0.0/16 mynetwork
else
  echo network exists
fi

dir="/data/redis/${MASTER_PORT} /data/redis/${NODE_PORT} /data/redis/${SENTINEL_PORT}"
for d in ${dir}; do
  if [ ! -d $d ]; then
    mkdir -p $d
  else
    echo $d exist
  fi
done

docker rm -f redis-sentinel redis-slave redis-master

# 主redis，该容器命名为redis-master 使用mynetwork网络 端口映射10001 对应容器内部端口的6379 指定容器固定IP:172.10.0.2 使用redis镜像来生成容器并在后台运行
docker run -it  --name redis-master -v ${PWD}/master/redis.conf:/etc/redis.conf \
  -v /data/redis/${MASTER_PORT}:/data \
  -d -p ${MASTER_PORT}:6379 --net mynetwork --restart=always --ip 172.10.0.2 redis redis-server /etc/redis.conf
# 从redis，该容器命名为redis-slave  使用mynetwork网络 端口映射10002对应容器内部端口的6379 指定容器固定IP:172.10.0.3 使用redis镜像来生成容器并在后台运行
docker run -it  --name redis-slave -v ${PWD}/slave/redis.conf:/etc/redis.conf \
  -v /data/redis/${NODE_PORT}:/data \
  -d -p ${NODE_PORT}:6379 --net mynetwork --restart=always --ip 172.10.0.3 redis redis-server /etc/redis.conf
# 哨兵redis，该容器命名为redis-sentinel  使用mynetwork网络 端口映射10003对应容器内部端口的6379 指定容器固定IP:172.10.0.4 使用redis镜像来生成容器并在后台运行
docker run -it  --name redis-sentinel -v ${PWD}/sentinel/sentinel.conf:/etc/sentinel.conf \
  -v /data/redis/${SENTINEL_PORT}:/data \
  -d -p ${SENTINEL_PORT}:26379 --net mynetwork --restart=always --ip 172.10.0.4 redis redis-sentinel /etc/sentinel.conf
