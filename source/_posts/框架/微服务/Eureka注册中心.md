---
title: Eureka注册中心
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---

原来的远程调用出现的问题：
```java
 public Order queryOrderById(Long orderId) {
        // 1.查询订单
        Order order = orderMapper.findById(orderId);
        // 2. 利用RestTemplate发送http请求，查询用户信息
        // 2.1 设置url地址
        String url = "http://localhost:9091/user/"+ order.getUserId();
        // 2.2 发送Http请求，实现远程调用
        User user = restTemplate.getForObject(url, User.class);
        // 2.3封装user到Order中
        order.setUser(user);
        // 4.返回
        return order;
    }
```
每次的服务地址端口会都是相同的，但是如果以后我们使用集群的话，这样就会产生问题。如果有多个服务提供者，消费者该如何选择？消费者如何得知服务提供者的健康状况？![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220703.jpg)

## Eureka详解
eurekaService:服务端，注册中心

- 记录服务信息
- 心跳监控

eurekaClient:客户端

- Provider:服务提供者，例如上图中 user-service
   - 注册自己的信息到EurekaService
   - 每隔30秒向EurekaService发送心跳
- consumer:服务消费者，例如上图中order-service
   - 根据服务名称从EurekaService拉取服务列表
   - 基于服务列表做负载均衡，选中一个微服务后发起远程调用

搭建EurekaService环境1、创建项目引入依赖
```java
 <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
    </dependencies>
```
2、编写启动类，添加**@EnableEurekaService**注解
```java
@EnableEurekaServer // 开启Eureka服务
@SpringBootApplication
public class EurekaApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaApplication.class,args);
    }
}
```
3、添加application.yml文件，编写配置

```yaml
server:
  port: 9092 # 服务端口
#  服务注册
spring:
  application:
    name: eurekaserver
eureka:
  client:
    service-url:
      defaultZone: http://localhost:9092/eureka/
```

##  报错
同样的配置，这样我们启动时会报错，报错原因是连接被拒绝。**原因：是因为eureka默认会去检索服务，当我们只写了这么一个注册中心（eureka）而没有其他服务的时候，它去检索服务就会出现上述错误。所以需要添加配置 fetch-registry: false。当我们配置多个服务时，我们要去掉这个。****我们点击**![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220706.jpg)跳转的界面是：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220708.jpg)这里显示注册到Eureka中的实例。服务注册：1、创建项目引入依赖
```java
 <!--注册eureka的客户端-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
```
2、在application.yml中配置eureka地址(注意端口号与服务端端口号一致)
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:9092/eureka/
```
服务发现：我们只需在RestTempleate的bean上加上负载均衡注解即可完成负载均衡
```java
@Bean
@LoadBalanced // 添加负载均衡注解
public RestTemplate restTemplate(){
    return new RestTemplate();
}
```
在拉取时，我们的url不能写死，我们需要写服务名称即可![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220710.jpg)这样我们配置多个服务时，我们依靠Eureka注册中心就能拉取相应的服务了

总结一波：1、搭建EurekaServer

- 引入eureka-server依赖
- 添加@EnableEurekaServer注解
- 在application.yml中配置eureka地址

2、服务注册

- 引入eureka-client依赖
- 在application.yml中配置eureka地址

3、服务发现

- 引入eureka-client依赖
- 在application.yml中配置eureka地址
- 给RestTemplate添加@LoadBalanced注解 
- 给服务提供者的服务名称远程调用
