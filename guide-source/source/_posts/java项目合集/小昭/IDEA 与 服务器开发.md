---
title: IDEA 与 服务器开发
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---


# IDEA 与 服务器 Linux 开发

最终效果：服务器上有一份与本地相同的代码。

目的：

- 可随时更新项目并将其运行起来测试。
- 避免了一个小更新也要在本地打包然后上传并运行的重复操作


## 0. 要求

-  得有脑子 
-  得有一台服务器 
-  得有一个 IDEA 


## 1. Linux 上安装 JDK

此处省略一万字


## 2. Linux 上安装 Maven

此处省略一万字


## 3. 将代码打包上传到 Linux 并解压

此处省略一万字


## 4. 本地 IDEA 的配置（正文开始）

首先添加远程主机

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220242.jpg)

点击右上角三个点新建：

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220244.jpg)

然后新建SSH配置

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220246.jpg)

然后填写被挡住的地方：

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220248.jpg)

然后填写映射路径

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220251.jpg)

然后工具中勾选自动上传

![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220253.jpg)
