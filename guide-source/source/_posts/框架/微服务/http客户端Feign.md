---
title: http客户端Feign
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## old调用方式劣势？
以前写的RestTemplate调用有什么劣势？
```java
public Order queryOrderById(Long orderId) {
        // 1.查询订单
        Order order = orderMapper.findById(orderId);
        // 2. 利用RestTemplate发送http请求，查询用户信息
        // 2.1 设置url地址
        String url = "http://userservice/user/"+ order.getUserId();
        // 2.2 发送Http请求，实现远程调用
        User user = restTemplate.getForObject(url, User.class);
        // 2.3封装user到Order中
        order.setUser(user);
        // 4.返回
        return order;
    }
```
存在下面的问题：

- 代码可读性差,编程体验不统一
- 参数复杂URL难以维护

所以，我们使用一种http客户端FeginFeign是一个声明式的http客户端,其作用就是帮助我们优雅的实现http请求的发送.


## Feign的使用步骤

### 引入依赖
```xml
 <!--配置feign的客户端-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```

### 添加@EnableFeignClients注解（开关）
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220730.jpg)注意：在主类上开启EnableFeignClients注解，那么我们的程序将会自动扫描clsspath下面所有被Feignclient注解类，（value值为服务名称）打上该注解的bean（一般是接口，生成代理类当成bean）,会注入到spring的ioc容器中，最后通过处理器一系列复杂的操作，最后给我们的服务端发送一个http的请求。

### 编写FeignClient接口
例如：
```java
@FeignClient("userservice")
public interface UserClient {

    @GetMapping("/user/{id}")
    User findUser(@PathVariable("id") Long id);

}
```

### 使用FeignClient中定义的方法代替RestTemplate
```java
 @Autowired
private UserClient userClient; // 注入
public Order queryOrderById(Long orderId) {
        // 1.查询订单
        Order order = orderMapper.findById(orderId);
        User user = userClient.findUser(order.getUserId());    //  调用即可
        // 2.3封装user到Order中
        order.setUser(user);
        // 4.返回
        return order;
    }
```
正常的注入后，调用接口中的方法即可。


## Feign的配置
我们可以通过自动的配置，来覆盖Feign原本的配置。

| **类型** | **作用** | **说明** |
| --- | --- | --- |
| **feign.Logger.Level** | 修改日志级别 | 包含四种不同的级别：NONE、BASIC、HEADERS、FULL |
| feign.codec.Decoder | 响应结果的解析器 | http远程调用的结果做解析，例如解析json字符串为java对象 |
| feign.codec.Encoder | 请求参数编码 | 将请求参数编码，便于通过http请求发送 |
| feign. Contract | 支持的注解格式 | 默认是SpringMVC的注解 |
| feign. Retryer | 失败重试机制 | 请求失败的重试机制，默认是没有，不过会使用Ribbon的重试 |

**我们可配置日志等级：****例如：**全局生效：
```yaml
feign:
  client:
    config:
      default:  # 这里用default就是全局配置，如果是写服务名称，则是针对某个微服务的配置
        logger-level: full  # 配置为FULL格式的
```
局部生效：
```yaml
feign:
  client:
    config:
       userservice: # 这里用default就是全局配置，如果是写服务名称，则是针对某个微服务的配置
        logger-level: full  # 配置为FULL格式的
```
FULL格式：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220733.jpg)java代码的方式配置：首先创建一个配置类，来创建bean;
```java
public class FeignClientConfig {

    @Bean
    public Logger.Level feignLog(){
        return Logger.Level.BASIC;
    }
}

```
然后，在开启注解上声明当前为类为配置类，这样好管理一些：默认配置：
```java
@EnableFeignClients(defaultConfiguration = FeignClientConfig.class)
```
指定服务配置：
```java
@FeignClient(value = "userservice", configuration = FeignClientConfiguration.class)
```

### 总结一下：
Feign的日志配置:1、 方式一是配置文件，

- feign.client.config.xxx.loggerLevel
   - 如果xxx是default则代表全局
   - 如果xxx是服务名称，例如userservice则代表某服务

2、方式二是java代码配置Logger.Level这个Bean

- 如果在@EnableFeignClients注解声明则代表全局
- 如果在@FeignClient注解中声明则代表某服务

注意：如果我们每次请求都是新建一个连接，这样访问速度是不是会很慢，如果我们可以使用像durid连接池那样，连接宿舍是不是会很快。Feign底层的客户端实现：

- URLConnection：默认实现，不支持连接池
- Apache HttpClient ：支持连接池
- OKHttp：支持连接池


## 如何使用连接池呢？
引入依赖：
```xml
 <!--httpClient的依赖 -->
        <dependency>
            <groupId>io.github.openfeign</groupId>
            <artifactId>feign-httpclient</artifactId>
         </dependency>
```
配置连接池：
```yaml
# feign 连接至配置
feign:
  client:
    config:
      default:
        logger-level: full
  httpclient:
    enabled: true  # 开启feign对HttpClient的支持
    max-connections: 200  # 最大的连接数
    max-connections-per-route: 50  # 每个路径的最大连接数
```

### Feign的优化：
1、日志级别尽量用basic2、使用HttpClient或OKHttp代替URLConnection

- 引入feign-httpClient依赖配置文件
- 开启httpClient功能，设置连接池参数


## Feign的最佳实战（我感觉这样好一些）：
将FeignClient抽取为独立模块，并且把接口有关的POJO、默认的Feign配置都放到这个模块中，提供给所有消费者使用![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220735.jpg)

