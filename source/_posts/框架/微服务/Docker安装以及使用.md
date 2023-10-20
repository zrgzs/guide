---
title: Docker安装以及使用
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---

本篇文章介绍在centos上安装docker。docker目前支持centos7,要求内核不低于3.10

## 一、保姆级安装教程

### 1、卸载之前安装的docker
```latex
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine \
                  docker-ce
```

### 2、配置yum工具
```latex
yum install -y yum-utils \
           device-mapper-persistent-data \
           lvm2 --skip-broken
```

### 3、更新本地镜像源
```latex
# 设置docker镜像源
yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    
sed -i 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo

yum makecache fast
```

### 4、安装docker
```latex
yum install -y docker-ce
```

### 5、启动docker
docker需要用到各种端口，为了方便学习，我直接把防火墙关了，并且不让开机自启。
```latex
# 关闭
systemctl stop firewalld
# 禁止开机启动防火墙
systemctl disable firewalld
```
启动docker
```latex
systemctl start docker  # 启动docker服务

systemctl stop docker  # 停止docker服务

systemctl restart docker  # 重启docker服务
```
查看是否启动成功
```latex
docker -v
```
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220620.jpg)显示如下内容即表示安装成功。

### 6、配置镜像加速器
docker官方镜像仓库网速较差，我们需要设置国内镜像服务：这玩意不是我能教的，你得看官网。参考阿里云的镜像加速文档：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220623.jpg)[阿里云登录 - 欢迎登录阿里云，安全稳定的云计算服务平台](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

配置mysql:
```java
docker run --name mysql -e MYSQL_ROOT_PASSWORD=wyr0307 -p 13306:3306 -v /tmp/mysql/conf/hmy.cnf:/etc/mysql/conf.d/hmy.cnf -v /tmp/mysql/data:/var/lib/mysql	--restart=always -d mysql
```

配置redis命令：
```java
docker run --name redis -p 6379:6379 -d redis redis-server --requirepass wyr0307

docker run -p 6379:6379 --privileged=true --name redis -v /usr/local/docker/redis.conf:/etc/redis/redis.conf -v /usr/local/docker/data:/data -d docker.io/redis:6.0 redis-server /etc/redis/redis.conf --appendonly yes
```

配置nacos命令
```java
docker run -d --name nacos  -p 8848:8848  -p 9848:9848 -p 9849:9849 --privileged=true -e JVM_XMS=256m -e JVM_XMX=256m -e MODE=standalone -v /tmp/nacos/conf/conf:/home/nacos/conf -v /tmp/nacos/logs:/home/nacos/logs --restart=always nacos/nacos-server:v2.1.0
```
配置rabbitMq命令
```java
docker run -e RABBITMQ_DEFAULT_USER=lyggwsp -e RABBITMQ_DEFAULT_PASS=wyr0307 --name mq --hostname mq1 -p 15672:15672  -p 5672:5672 -d rabbitmq:3-management
```
配置minio命令


## 二、Docker的基本操作

### 镜像相关命令
镜像名称一般分两部分组成：[repository]:[tag]。在没有指定tag时，默认是latest，代表最新版本的镜像![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220626.jpg)相关操作：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220628.jpg)使用如下网址可查看需要什么镜像。[Docker](https://hub.docker.com/_/redis)查看命名： docker XX --help拉取镜像：docker pull nginx移除镜像：docker rmi查看拉取到的镜像：docker images 导出镜像到磁盘 ：docker save加载镜像：docker load

docker 容器相关命令：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220631.jpg)创建运行一个nginx容器步骤一：去docker hub 查看nginx的容器运行命名docker run --name containerName -p 80:80 -d nginx参数解读:docker run : 创建并允许一个容器--name : 给容器起的名字-p：将宿主主机端口与容器端口映射，冒号左面是宿主主机端口，右侧是容器端口-d: 后台允许nginx : 镜像名称，例如nginx![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220633.jpg)docker run命令的常见参数有哪些？--name：指定容器名称-p：指定端口映射-d：让容器后台运行查看容器日志的命令：docker logs添加 -f 参数可以持续查看日志查看容器状态：docker ps

如何进入docker容器内部来修改指定的操作？步骤一、进入容器，进入我们创建的nginx容器的命令为docker exec -it mynginx bash命令解读：docker exec : 进入容器内部，执行一个命令-it : 给当前进入的容器创建一个标准输入、输出终端，允许我们与容器进行交互mn : 要进入的容器的名称bash : 进入容器后执行的命令，bash是一个linux终端交互命令步骤二、查看官网，查找文件存放的位置来进行指定的操作。 


#### 查看容器状态：
docker ps 添加-a参数查看所有状态的容器

#### 删除容器：
docker rm不能删除运行中的容器，除非添加 -f 参数

#### 进入容器：
命令是docker exec -it [容器名] [要执行的命令]exec命令可以进入容器修改文件，但是在容器内修改文件是不推荐的

退出容器：exit ctrl + p +q

docker 容器redis设置

启动 redis 命令:docker run --name myredis -p 6379:6379 -d redis --requirepass youpassword![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220636.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220639.jpg)进入容器docker exec -it myredis bash![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220641.jpg)执行redis-cli命令客户端命令redis-cli

认证密码：auth  yourpassword![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220644.jpg)即可进行正常在redis中的操作。可查看redis密码：config get requirepass![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220646.jpg)但是这样我们本机还是服务访问docker上的redis的，因为redis的配置文件中配置只有本地地址才能访问的，所以我们还需配置一波。在docker进行配置的redis会有些许麻烦：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220649.jpg)接下来，我们学习了数据卷之后再来配置一波redis:

### 数据卷
数据卷（volume）是一个虚拟目录，指向宿主机文件系统中的某个目录。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220651.jpg)


![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220654.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220656.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220658.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220701.jpg)

有关nacos的配置，这篇文章讲的很详细：[Docker启动安装nacos（详情讲解，全网最细）_docker 启动nacos_Color L的博客-CSDN博客](https://blog.csdn.net/ilvjiale/article/details/129417768)

## 三、Dockerfile自定义镜像

## 四、Docker-Compose

## 五、Docker镜像仓库



