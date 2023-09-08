---
title: Gateway网关
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## 一、为什么需要网关
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220713.jpg)在SpringCloud中网关的实现包括两种：

- gateway
- zuul

Zuul是基于Servlet的实现，属于阻塞式编程。而SpringCloudGateway则是基于Spring5中提供的WebFlux，属于响应式编程的实现，具备更好的性能。

总结：网关的作用：

- 对用户请求做身份认证、权限校验
- 将用户请求路由到微服务，并实现负载均衡
- 对用户请求做限流

## 二、gateway快速入门
网关配置通常是一个统一的模块

### 搭建网关服务的步骤如下：

#### 1、创建新的module，引入SpringCloudGateway的依赖和nacos的服务发现依赖：
```xml
 <!--nacos的服务注册发现依赖-->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>

        <!--网关依赖-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
```

#### 2、编写路由配置以及nacos地址
```yaml
server:
  port: 1313
spring:
  application:
    name: gateway
  cloud:
  # 配置nacos
    nacos:
      discovery:
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
      server-addr: localhost:8848
    gateway:
      routes: # 配置网关路由
         - id: user-service  # 路由id，自定义，只要唯一即可
           # uri: http://127.0.0.1:8081 # 路由的目标地址 http就是固定地址
           uri: lb://userservice # 路由的目标地址 lb就是负载均衡，后面跟服务名称
           predicates:  # 路由断言，也就是判断请求是否符合路由规则的条件
             - Path=/user/**  # 这个是按照路径匹配，只要以/user/开头就符合要求
```
我们在postman中访问当前网关端口，只要与网关路由配置断言匹配即可访问。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220716.jpg)执行流程如下：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220718.jpg)

### 总结：

#### 网关搭建步骤：
1、创建项目，引入nacos服务发现和gateway依赖2、配置application.yml，包括服务基本信息、nacos地址、路由

#### 路由配置包括：
1、路由id：路由的唯一标示2、路由目标（uri）：路由的目标地址，http代表固定地址，lb代表根据服务名负载均衡3、路由断言（predicates）：判断路由的规则，4、路由过滤器（filters）：对请求或响应做处理

## 三、断言工厂

### 网关路由可以配置的内容包括：

- 路由id：路由唯一标示
- uri：路由目的地，支持lb和http两种
- predicates：路由断言，判断请求是否符合要求，符合则转发到路由目的地
- filters：路由过滤器，处理请求或响应

### 路由断言工厂Route Predicate Factory
我们在配置文件中写的断言规则只是字符串，这些字符串会被Predicate Factory读取并处理，转变为路由判断的条件例如Path=/user/**是按照路径匹配，这个规则是由org.springframework.cloud.gateway.handler.predicate.PathRoutePredicateFactory类来处理的像这样的断言工厂在SpringCloudGateway还有十几个![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220720.jpg)总结：PredicateFactory的作用是什么？

- 读取用户定义的断言条件，对请求做出判断

Path=/user/**是什么含义？

- 路径是以/user开头的就认为是符合的

## 四、过滤器工厂
GatewayFilter是网关中提供的一种过滤器，可以对进入网关的请求和微服务返回的响应做处理：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220723.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220726.jpg)如果要对所有的路由都生效，则可以将过滤器工厂写到default下。格式如下：(注意default-filters)
```yaml
server:
  port: 1313
spring:
  application:
    name: gateway
  cloud:
  # 配置nacos
    nacos:
      discovery:
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
      server-addr: localhost:8848
    gateway:
      routes: # 配置网关路由
         - id: user-service  # 路由id，自定义，只要唯一即可
           # uri: http://127.0.0.1:8081 # 路由的目标地址 http就是固定地址
           uri: lb://userservice # 路由的目标地址 lb就是负载均衡，后面跟服务名称
           predicates:  # 路由断言，也就是判断请求是否符合路由规则的条件
             - Path=/user/**  # 这个是按照路径匹配，只要以/user/开头就符合要求
      default-filters: # 默认过滤器，会对所有的路由请求都生效
        - AddRequestHeader= Truth, Itcast is freaking awesome! # 添加请求头
```

### 总结：

#### 过滤器的作用是什么？
对路由的请求或响应做加工处理，比如添加请求头配置在路由下的过滤器只对当前路由的请求生效

### defaultFilters的作用是什么？
对所有路由都生效的过滤器

## 五、全局过滤器
全局过滤器 GlobalFilter全局过滤器的作用也是处理一切进入网关的请求和微服务响应，与GatewayFilter的作用一样。区别在于GatewayFilter通过配置定义，处理逻辑是固定的。而GlobalFilter的逻辑需要自己写代码实现。定义方式是实现GlobalFilter接口。
```java
public class AuthorizeFilter  implements GatewayFilter {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        /*
        方法体内，可做用户认证操作
         */
        return null;
    }
}
```

### 总结：

#### 全局过滤器的作用是什么？
对所有路由都生效的过滤器，并且可以自定义处理逻辑

#### 实现全局过滤器的步骤？
实现GlobalFilter接口添加@Order注解或实现Ordered接口编写处理逻辑


### 过滤器执行顺序
请求进入网关会碰到三类过滤器：当前路由的过滤器、DefaultFilter、GlobalFilter请求路由后，会将当前路由过滤器和DefaultFilter、GlobalFilter，合并到一个过滤器链（集合）中，排序后依次执行每个过滤器

![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220728.jpg)过滤器执行顺序每一个过滤器都必须指定一个int类型的order值，order值越小，优先级越高，执行顺序越靠前。GlobalFilter通过实现Ordered接口，或者添加@Order注解来指定order值，由我们自己指定路由过滤器和defaultFilter的order由Spring指定，默认是按照声明顺序从1递增。当过滤器的order值一样时，会按照 defaultFilter > 路由过滤器 > GlobalFilter的顺序执行。

## 六、跨域问题
跨域：域名不一致就是跨域，主要包括：

- 域名不同： www.taobao.com 和 www.taobao.org 和 www.jd.com 和 miaosha.jd.com域名相同，
- 端口不同：localhost:8080和localhost8081
- 跨域问题：浏览器禁止请求的发起者与服务端发生跨域ajax请求，请求被浏览器拦截的问题解决方案：CORS

网关处理跨域采用的同样是CORS方案，并且只需要简单配置即可实现：
```yaml
server:
  port: 1313
spring:
  application:
    name: gateway
  cloud:
  # 配置nacos
    nacos:
      discovery:
        namespace: fe5ad009-268c-46e7-8d90-968f160e850c  # dev环境
      server-addr: localhost:8848
    gateway:
      # 配置跨域请求
      globalcors:  # 全局的跨域处理
        add-to-simple-url-handler-mapping: true  # 解决options请求被拦截问题
        cors-configurations:'[/**]':
          allowedOrigins:  # 允许哪些网址的跨域请求
            - 'http://loaclhost:8090'
            - 'http://loaclhost:8090'
          allowedMethods:  # 允许跨域ajax的请求方式
            - "GET"
            - "POST"
            - "DELETE"
            - "OPTIONS"
          allowedHeaders: "*"   # 允许在请求头中携带的头部信息
          allowCredentials: true  # 是否允许携带cookie
          maxAge: 360000  # 这次跨域检测的有效期
      routes: # 配置网关路由
         - id: user-service  # 路由id，自定义，只要唯一即可
           # uri: http://127.0.0.1:8081 # 路由的目标地址 http就是固定地址
           uri: lb://userservice # 路由的目标地址 lb就是负载均衡，后面跟服务名称
           predicates:  # 路由断言，也就是判断请求是否符合路由规则的条件
             - Path=/user/**  # 这个是按照路径匹配，只要以/user/开头就符合要求
      default-filters: # 默认过滤器，会对所有的路由请求都生效
        - AddRequestHeader= Truth, Itcast is freaking awesome! # 添加请求头

```

### CORS跨域要配置的参数包括哪几个？
允许哪些域名跨域？允许哪些请求头？允许哪些请求方式？是否允许使用cookie？有效期是多久？
