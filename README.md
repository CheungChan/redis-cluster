redis集群搭建

启动方式
```bash
docker-compose up
```

更新代码
```bash
git pull
docker-compose restart
```




如果报错Cannot start service redis3: Address already in use
是因为容器是restart=always的, 容器删除之后, 容器的端口映射的端口不会回收, 需要手动断开

首先找到创建的network
docker network ls
```bash
NETWORK ID          NAME                      DRIVER              SCOPE
580321d19a7c        bridge                    bridge              local
5fc00d4f5e5b        host                      host                local
ba359d26f7a8        none                      null                local
cda5b77c0187        redis-cluster_mynetwork   bridge              local
```
然后找到网络关联的容器
docker network inspect redis-cluster_mynetwork
```bash
  "Internal": false,
        "Attachable": true,
        "Containers": {
            "b06e46316f486b44482fdf5589bbf031849d2bc248425845c9953308d893b028": {
                "Name": "b06e46316f48_redis-node-2",
                "EndpointID": "b58d8529f0f144b90b072117130f0093004feeace5c8ed66fdafa250d7fe4db3",
                "MacAddress": "02:42:ac:0a:00:03",
                "IPv4Address": "172.10.0.3/16",
                "IPv6Address": ""
            },
            "c5e67941a0e3421ea9961c70c504355689943b4f3255fa722a9df49c93c0fd59": {
                "Name": "c5e67941a0e3_redis-node-3",
                "EndpointID": "82c8c23cb98ba45dcf350db506b569443edc44912be431b4231f1fbc3a5c4751",
                "MacAddress": "02:42:ac:0a:00:04",
                "IPv4Address": "172.10.0.4/16",
                "IPv6Address": ""
            },
            "df854f209087a17f7a66214c449be753debfb08004c16521d17b2cb7f7e12066": {
                "Name": "df854f209087_redis-node-1",
                "EndpointID": "5616c9e1e6a94f4390338f1b582e8e3085c1811f45d683d4e7c4ba3c8818b2e5",
                "MacAddress": "02:42:ac:0a:00:02",
                "IPv4Address": "172.10.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "mynetwork",
            "com.docker.compose.project": "redis-cluster",
            "com.docker.compose.version": "1.24.1"
```
再把网络和每一个容器进行销毁
```bash
docker network disconnect -f redis-cluster_mynetwork b06e46316f48_redis-node-2
docker network disconnect -f redis-cluster_mynetwork c5e67941a0e3_redis-node-3
docker network disconnect -f redis-cluster_mynetwork df854f209087_redis-node-1
```


最后删除网络即可
```bash
docker network rm redis-cluster_mynetwork 
```
