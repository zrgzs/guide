---
title: CentOS 环境安装
date: 2023-10-10 23：01：01
categories:
- Linux运维
author: lx0815
comment: false
---

# CentOS 环境安装

系统：CentOS 7.6

## 1 更新 yum

`yum update -y` 

## 2 安装 Java

**访问 Orcal 官网**

[Java Downloads | Oracle](https://www.oracle.com/java/technologies/downloads/)

**下载合适的版本**

`arch` 或 `uname -m` 命令可查看服务器架构类型

**通过 scp 命令将 jdk 上传到 服务器**

```bash
[12:46]  Shell                                                                                                             95ms
 ~\Downloads
❯ scp -i D:\developmentEnvironment\server\tencentcloud\zrgzs_root.pem .\jdk-8u381-linux-x64.tar.gz root@115.159.49.90:/root/jdk-8u381.tar.gz
jdk-8u381-linux-i586.tar.gz                                                                     100%  136MB  11.2MB/s   00:12
```

**然后把 jdk 移动到 `/usr` 下**

```bash
[root@VM-4-17-centos ~]# mv jdk-8u381.tar.gz /usr/local/java.tar.gz
```

**解压 jdk **

```bash
[root@VM-4-17-centos ~]# cd /usr/local
[root@VM-4-17-centos usr]# tar -xvzf java.tar.gz
[root@VM-4-17-centos usr]# mv jdk1.8.0_381/ java
```

**配置环境变量**

执行 `vim /etc/profile.d/java.sh` 

添加内容如下：

```sh
#!/bin/bash
# @description: Java 环境
# @author: Ding

export JAVA_HOME=/usr/local/java
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```

**然后重新加载环境变量并检查java版本**

```bash
[root@VM-4-17-centos java]# source /etc/profile
[root@VM-4-17-centos java]# java -version
java version "1.8.0_381"
Java(TM) SE Runtime Environment (build 1.8.0_381-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.381-b09, mixed mode)
```



## 3 安装 nvm

nvm：管理 node 环境

[nvm-sh/nvm: Node Version Manager](https://github.com/nvm-sh/nvm)

**下载 nvm install 脚本并运行**

`wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash`

```bash
[root@VM-4-17-centos ~]# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
=> Downloading nvm as script to '/root/.nvm'

=> nvm source string already in /root/.bashrc
=> bash_completion source string already in /root/.bashrc
=> Close and reopen your terminal to start using nvm or run the following to use it now:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

**重新加载环境变量**

```bash
[root@VM-4-17-centos ~]# source ~/.bashrc
```

**检查是否安装成功**

```bash
[root@VM-4-17-centos ~]# nvm -v
0.39.5
```

**安装需要的 node 版本**

```bash
[root@VM-4-17-centos ~]# nvm install 16
Downloading and installing node v16.20.2...
Downloading https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.xz...
######################################################################## 100.0%
Computing checksum with sha256sum
Checksums matched!
Now using node v16.20.2 (npm v8.19.4)
Creating default alias: default -> 16 (-> v16.20.2)
```

**查看 node、npm 版本**

```bash
[root@VM-4-17-centos ~]# node -v
v16.20.2
[root@VM-4-17-centos ~]# npm -v
8.19.4
```

到这一步就安装完成了！

但个人觉得把环境变量都以 sh 脚本的方式放到 `/etc/profile.d/` 目录下面会更合适，所以开始转移环境变量配置。

通过 vim 新增脚本文件

```bash
[root@VM-4-17-centos ~]# vim /etc/profile.d/nvm.sh
```

nvm.sh 内容如下：

```sh
#!/bin/bash
# @description: nvm 加载脚本
# @author: Ding

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
```



移除原来写在 `.bashrc` 文件中的内容

## 4 安装 Docker

 **查看版本**

```bash
[root@VM-4-17-centos java]# yum list docker-ce --showduplicates | sort -r
```

**下载一个版本**

```bash
yum -y install docker-ce-18.03.1.ce
```

**查看 docker 版本**

```bash
[root@VM-4-17-centos java]# docker -v
Docker version 18.03.1-ce, build 9ee9f40
```

**启动 docker**

```bash
[root@VM-4-17-centos ~]# systemctl start docker
```



## 5 安装 RustDesk

[Docker ：： RustDesk 的文档](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/)

**拉取镜像**

```bash
#=====================================拉取thtom/rustdesk-server镜像========================================
docker pull thtom/rustdesk-server

#===========================将rustdesk/rustdesk-server都替换成thtom/rustdesk-server======================
sudo docker run --name hbbs -p 21115:21115 -p 21116:21116 -p 21116:21116/udp -p 21118:21118 -v 'pwd':/root -td --net=host thtom/rustdesk-server hbbs -r XXX.XXX.XXX.XXX

sudo docker run --name hbbr -p 21117:21117 -p 21119:21119 -v `pwd`:/root -td --net=host thtom/rustdesk-server hbbr
```

**开启端口**

```bash
TCP(21115, 21116, 21117, 21118, 21119)
UDP(21116)
```

## 6 安装 Nginx

**安装依赖环境**

```bash
[root@VM-4-17-centos ~]# yum install gcc-c++ 
[root@VM-4-17-centos ~]# yum install -y openssl openssl-devel
[root@VM-4-17-centos ~]# yum install -y pcre pcre-devel
[root@VM-4-17-centos ~]# yum install -y zlib zlib-devel
```

[nginx：下载](https://nginx.org/en/download.html)

**下载 nginx**

```bash
[root@VM-4-17-centos ~]# wget https://nginx.org/download/nginx-1.24.0.tar.gz
--2023-10-11 22:08:33--  https://nginx.org/download/nginx-1.24.0.tar.gz
Resolving nginx.org (nginx.org)... 3.125.197.172, 52.58.199.22, 2a05:d014:edb:5702::6, ...
Connecting to nginx.org (nginx.org)|3.125.197.172|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1112471 (1.1M) [application/octet-stream]
Saving to: ‘nginx-1.24.0.tar.gz’

100%[========================================================================================>] 1,112,471   19.2KB/s   in 53s

2023-10-11 22:09:27 (20.6 KB/s) - ‘nginx-1.24.0.tar.gz’ saved [1112471/1112471]
```

**解压 nginx** **安装程序**

```bash
[root@VM-4-17-centos ~]# tar -xvzf nginx-1.24.0.tar.gz
```

**使用默认配置**

```bash
[root@VM-4-17-centos ~]# cd nginx-1.24.0/
[root@VM-4-17-centos nginx-1.24.0]# ./configure --prefix=/opt/nginx
checking for OS
 + Linux 3.10.0-1160.88.1.el7.x86_64 x86_64
。。。

Configuration summary
  + using system PCRE library
  + OpenSSL library is not used
  + using system zlib library

  nginx path prefix: "/opt/nginx"
  nginx binary file: "/opt/nginx/sbin/nginx"
  nginx modules path: "/opt/nginx/modules"
  nginx configuration prefix: "/opt/nginx/conf"
  nginx configuration file: "/opt/nginx/conf/nginx.conf"
  nginx pid file: "/opt/nginx/logs/nginx.pid"
  nginx error log file: "/opt/nginx/logs/error.log"
  nginx http access log file: "/opt/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"
```

**编译安装**

```bash
make
make install
```

**查看是否安装完成**

```bash
[root@VM-4-17-centos nginx-1.24.0]# ll /opt/ | grep nginx
drwxr-xr-x   6 root root 4096 Oct 11 22:16 nginx
```

**配置 nginx 服务**

```bash
[root@VM-4-17-centos nginx-1.24.0]# vim /usr/lib/systemd/system/nginx.service
```

内容如下：

```
[Unit]
Description=nginx web service
Documentation=http://nginx.org/en/docs/
After=network.target
 
[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PrivateTmp=true
 
[Install]
WantedBy=default.target
```

**设置权限**

```bash
chmod 755 /usr/lib/systemd/system/nginx.service
```

**启动 nginx**

```bash
[root@VM-4-17-centos nginx-1.24.0]# systemctl start nginx
[root@VM-4-17-centos nginx-1.24.0]# systemctl status nginx
● nginx.service - nginx web service
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-10-11 22:21:50 CST; 8s ago
     Docs: http://nginx.org/en/docs/
  Process: 24735 ExecStart=/usr/local/nginx/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 24733 ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 24737 (nginx)
    Tasks: 2
   Memory: 988.0K
   CGroup: /system.slice/nginx.service
           ├─24737 nginx: master process /usr/local/nginx/sbin/nginx
           └─24738 nginx: worker process

Oct 11 22:21:50 VM-4-17-centos systemd[1]: Starting nginx web service...
Oct 11 22:21:50 VM-4-17-centos nginx[24733]: nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
Oct 11 22:21:50 VM-4-17-centos nginx[24733]: nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
Oct 11 22:21:50 VM-4-17-centos systemd[1]: Started nginx web service.
```

## 7 安装 Redis

**docker 拉取镜像**

```bash
docker pull redis
```

**复制配置文件**

配置文件地址：[Redis 配置文件示例 |雷迪斯](https://redis.io/docs/management/config-file/)

**存放配置文件**

```bash
[root@VM-4-17-centos ~]# mkdir -p /opt/redis/conf
[root@VM-4-17-centos ~]# touch /opt/redis/conf/redis.conf
[root@VM-4-17-centos ~]# vim /opt/redis/conf/redis.conf
```

**修改配置文件**

```bash
requirepass 你的密码   #给redis设置密码
bind * -::* # 允许外部访问
```

**docker run**

```bash
[root@VM-4-17-centos ~]# docker run -d --name redis -p 5268:6379 -v /opt/redis/data:/data -v /opt/redis/conf/redis.conf:/etc/redis/redis.conf redis redis-server /etc/redis/redis.conf
[root@VM-4-17-centos ~]# docker start redis
redis
```

## 8 安装 Nacos

Nacos 版本：2.2.0

[Nacos Docker 快速开始](https://nacos.io/zh-cn/docs/quick-start-docker.html)

service 配置

```text
[Unit]
Description=nacos
After=network.target

[Service]
# java安装位置
Environment="JAVA_HOME=/usr/local/java"
Type=forking
#standalone 是单机，默认是集群cluster； nacos启动文件位置
ExecStart=/opt/nacos/bin/startup.sh -m standalone
ExecReload=/opt/nacos/bin/shutdown.sh && /opt/nacos/bin/startup.sh
ExecStop=/opt/nacos/bin/shutdown.sh
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

