---
title: Nacos配置管理
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## 一、统一配置管理
配置更新热更新![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220821.jpg)

#### 在Nacos中添加配置信息：
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220824.jpg)

#### 在弹出的表单中填写配置信息
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220826.jpg)注意看，我上面的所以配置都是在dev环境下的，等会我会出一个错误。继续：原来我们读取配置是这样的：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220828.jpg)我们加入nacos的配置后，配置变成这样的：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220830.jpg)但是这样我们如何能做到，根本就不知道nacos的地址就去读取nacos中的配置文件信息呢？这就引出一个新的东西，我是才听说的，所以才说是新的，哈哈哈哈哈，那就是bootstrap.yml文件，我们来看一下bootstarp.yml与application.yml文件的区别。若application.yml 和bootstrap.yml 在同一目录下：bootstrap.yml 先加载 application.yml后加载bootstrap.yml 用于应用程序上下文的引导阶段。bootstrap.yml 由父Spring ApplicationContext加载。所以我们只需在bootstrap.yml文件中配置nacos地址就可用读取nacos配置文件中的信息，然后与本地application.yml文件配置文件信息合并，达到动态热更新咯。这波太神奇了。王某人直呼6666666.![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220832.jpg)配置完上述内容后，我们进入idea,添加配置管理依赖：
```xml
 <!--nacos的配置管理依赖(配置管理)-->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        </dependency>
```
在resource目录下添加，bootstrap.yml文件![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220835.jpg)内容如下;注意删除原本application.yml中的nacos配置信息
```yaml
# 服务名称 + 服务地址 + 后缀名  --> nacos中的配置dataID
spring:
  application:
    name: userservice
  profiles:
    active: dev # 环境
  cloud:
    nacos:
      server-addr: localhost:8848
      discovery:
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
      config:
        file-extension: yaml # 文件后缀名
 				# 因为刚才配置的管理命名空间是在dev环境下如果不添加这个读取内容会报错。不在同一个空间如何协作呢？
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c 
```
然后我们可以像正常读取配置文件中的内容一样来读取。


### 二、将配置交给Nacos管理的步骤

- 在Nacos中添加配置文件
- 在微服务中引入nacos的config依赖
- 在微服务中添加bootstrap.yml，配置nacos地址、当前环境、服务名称、文件后缀名。这些决定了程序启动时去nacos读取哪个文件

配置自动刷新Nacos中的配置文件变更后，微服务无需重启就可以感知。不过需要通过下面两种配置实现：方式一、通过@Value注解来实现  ，自动自动刷新使用@RefreshScope注解来实现 ![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220837.jpg)方式二、使用@ConfigurationProperties注解![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220839.jpg)推荐使用方式二。


#### 总结一波，Nacos配置更改后，微服务可以实现热更新，
方式：

- 通过@Value注解注入，结合@RefreshScope来刷新
- 通过@ConfigurationProperties注入，自动刷新

注意事项：不是所有的配置都适合放到配置中心，维护起来比较麻烦建议将一些关键参数，需要运行时调整的参数放到nacos配置中心，一般都是自定义配置


## 三、多环境配置共享
微服务启动时会从nacos读取多个配置文件：[spring.application.name]-[spring.profiles.active].yaml，例如：userservice-dev.yaml[spring.application.name].yaml，例如：userservice.yaml无论profile如何变化，[spring.application.name].yaml这个文件一定会加载，因此多环境共享配置可以写入这个文现在我的nacos的配置中有如下配置：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220841.jpg)我实际代码中的配置是这样的：
```yaml
# 服务名称 + 服务地址 + 后缀名  --> nacos中的配置dataID
spring:
  application:
    name: userservice
  profiles:
    active: dev # 环境
  cloud:
    nacos:
      server-addr: localhost:8848
      discovery:
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
      config:
        file-extension: yaml # 文件后缀名
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c
```
那我在userservice.yaml中配置的信息一定会被加载读取的到。现在来看看配置的优先级：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220843.jpg)总结一波：微服务会从nacos读取的配置文件：[服务名]-[spring.profile.active].yaml，环境配置[服务名].yaml，默认配置，多环境共享优先级：[服务名]-[环境].yaml >[服务名].yaml > 本地配置
