---
title: Nacos注册中心
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## 一、配置

### 下载安装
自我感觉哈，Nacos注册中心的使用比Eureka注册中心要简单一些。简要说明一下Nacos注册中心的配置以及使用：首先需要安装Nacos，这里为了方便使用，在本地安装了Nacos。去Nacos官方网址去下载Nacos![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220738.jpg)window下载zip版本，linux下载tar版本。当前推荐下载安装2.1.1稳点版本	。（注意路径不能存在中文）下载解压后![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220740.jpg)在conf目录下中找到application.properties可配置端口号，默认端口号为8848然后打开bin目录，bin目录下为执行脚本，在当前目录下执行cmd打开命令行窗口，执行 startup.cmd -m standlone 可单模式下启动，集群配置后面再搞吧。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220743.jpg)随后我们可以访问给的网址，我们输入账号密码即可登录可视化工具，账号密码初始值都为：nacos。

### 服务配置
我们在idea中继续来配置服务。我们需要在父工程中引入管理依赖：
```java
 <!--nacos管理依赖-->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>2.2.5.RELEASE</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```
然后再其服务模块中引入：
```java
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
```
之后，我们再服务模块的application.yml文件中配置：
```yaml
# 配置nacos
spring:
  cloud:
      nacos:
        server-addr: localhost:8848 # nacos服务地址,其实默认的也是localhost:8848
```
启动项目，我们打开nacos可视化界面中，查看服务：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220745.jpg)可见，我们的配置成功了。

## 二、Nacos服务分级存储模型

### 概念
一个服务可包含多个实例服务 --> 集群  --> 实例![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220747.jpg)服务跨集群调用问题服务调用尽可能选择本地集群的服务，跨集群调用延迟较高本地集群不可访问时，再去访问其它集群。因为本地访问速度相对较快。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220750.jpg)

### 服务集群配置：
1、修改application.yml，添加如下内容：
```yaml
  # 配置nacos
spring:
  cloud:
    nacos:
      server-addr: localhost:8848 # nacos服务地址
      discovery:
        cluster-name: JS # 配置集群地址(可自定义)
```
2、可在nacos控制台查看![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220753.jpg)

Nacos服务分级存储模型

- 一级是服务，例如userservice
- 二级是集群，例如杭州或上海
- 三级是实例，例如杭州机房的某台部署了userservice的服务器

如何设置实例的集群属性

- 修改application.yml文件，添加spring.cloud.nacos.discovery.cluster-name属性即可


### 服务集群属性配置：
我们可以在集群为XZ的配置多个实例，在集群为LYG的配置一个实例作为服务者，我们在一个消费者，当前消费者在LYG,我们如何能做到让消费者访问服务优先访问LYG集群内的实例而不访问集群为XZ的实例呢？这时我们就需要在消费者中配置Nacos的服务访问规则。（设置负载均衡的IRule为NacosRule，这个规则优先会寻找与自己同集群的服务）
```yaml
#  配置服务访问规则
userservice: # 消费者服务
  ribbon:
    NFLoadBalancerRuleClassName: com.alibaba.cloud.nacos.ribbon.NacosRule
```
这里的配置并非全局配置，只针对userservice服务有效，访问的是同一个集群下的实例，但如果当前集群下有多个实例，则按照随机的方式来访问。如果当前集群下的服务全部宕机，当前消费者还是得访问其他集群下的服务，但是这样会报一个警告。为跨集群访问，以便运维人员来重启服务。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220756.jpg)

### NacosRule负载均衡策略

- 优先选择同集群服务实例列表
- 本地集群找不到提供者，才去其它集群寻找，并且会报警告
- 确定了可用实例列表后，再采用随机负载均衡挑选实例

## 三、Naco权重负载均衡
实际部署中会出现这样的场景：服务器设备性能有差异，部分实例所在机器性能较好，另一些较差，我们希望性能好的机器承担更多的用户请求Nacos提供了权重配置来控制访问频率，权重越大则访问频率越高。那么，我们如何来配置权重呢？简单的是，这一步根部不需要写代码就可以来实现，因为运维人员他们可以在nacos控制台来进行配置权重。

### 配置
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220758.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220800.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220804.jpg)权重范围是  0~1 ，权重为0的，就相当于等于停机了，用户请求无法访问到当前服务上来，配置为1，使用请求都能打过来，相较于其他的服务，1是最大的才能满足所以请求都打到本台服务上来。

### 总结：（实例的权重控制）

- Nacos控制台可以设置实例的权重值，0~1之间
- 同集群内的多个实例，权重越高被访问的频率越高
- 权重设置为0则完全不会被访问


## 四、环境隔离-namespace

### 配置
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220806.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220809.jpg)复制命名空间的ID![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220811.jpg)在代码中配置：
```yaml
spring:
  cloud:
      nacos:
        server-addr: localhost:8848 # nacos服务地址
        discovery:
          cluster-name: XZ # 配置集群名称
          namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
```
重启服务后，观察控制台：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220813.jpg)可发现在dev命名空间中存在该服务了。继续访问的话，报错500![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220815.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220817.jpg)报错为：没有可用服务，相当于两个服务被隔离起来，要相访问必须在同一个命名空间下。

### 总结：（Nacos环境隔离）

-  每个namespace都有唯一id
- 服务设置namespace时要写id而不是名称
- 不同namespace下的服务互相不可见


## Nacos和Eureka的区别以及共同点

### Nacos与eureka的共同点

- 都支持服务注册和服务拉取
- 都支持服务提供者心跳方式做健康检测

### Nacos与Eureka的区别

- Nacos支持服务端主动检测提供者状态：临时实例采用心跳模式，非临时实例采用主动检测模式
- 临时实例心跳不正常会被剔除，非临时实例则不会被剔除
- Nacos支持服务列表变更的消息推送模式，服务列表更新更及时
- Nacos集群默认采用AP方式，当集群中存在非临时实例时，采用CP模式；Eureka采用AP方式

Nacos配置非临时实例：
```yaml
spring:
	cloud:
		nacos:
			discovery:
				 ephemeral: false # 设置为非临时实例
```
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220819.jpg)

