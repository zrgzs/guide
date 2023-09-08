---
title: Ribbon负载均衡
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## 为何Ribbon可以做到负载均衡（原理）？
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220847.jpg)发送请求：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220850.jpg)继续debug会进入到LoadBalancerInterceptor拦截器中，我们会发现在拦截请求中实质上是获取了URI，获取了主机名称，后将主机名称传给了RibbonLoadBalanceIacerClient,负载均衡客户端会继续执行![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220852.jpg)之后进入到execute方法中，通过服务ID，会在Eureka中找到ID相同的服务封装成List。（RibbonLoadBalancerClient）getLoadBalancer是在根据服务名称找Eureka的服务名称来拉取服务的，继续进入getServer方法中，![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220855.jpg)![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220859.jpg)到这里一步，我们已经拉取到服务列表了，这样我们就可以开始做负载均衡了，我们可以看到使用了一个叫rule的choose方法来选择![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220901.jpg)rule是什么呢？![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220903.jpg)通过IRule来决定选择负载均衡![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220906.jpg)执行完成rule的choose之后，我们就找到了这个服务的ip和端口号了![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220908.jpg)

实质上，我们的请求会被一个叫做LoadBalanceInterceptor负载均衡拦截器拦截，后将服务的名称交给RibbonLoadBalcaneClient，然后将url的服务ID交给DynamicServiceListLoadBalance去拉取服务信息，然后通过IRule来做负载均衡。![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220910.jpg)


## 配置Ribbon负载均衡

### Ribbon负载均衡策略
Ribbon的负载均衡规则是一个叫做IRule的接口来定义的，每一个子接口都是一种规则：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220913.jpg)


### 负载均衡策略
| **内置负载均衡规则类** | **规则描述** |
| --- | --- |
| RoundRobinRule | 简单轮询服务列表来选择服务器。它是Ribbon默认的负载均衡规则。 |
| AvailabilityFilteringRule | 对以下两种服务器进行忽略：（1）在默认情况下，这台服务器如果3次连接失败，这台服务器就会被设置为“短路”状态。短路状态将持续30秒，如果再次连接失败，短路的持续时间就会几何级地增加。（2）并发数过高的服务器。如果一个服务器的并发连接数过高，配置了AvailabilityFilteringRule规则的客户端也会将其忽略。并发连接数的上限，可以由客户端的<clientName>.<clientConfigNameSpace>.ActiveConnectionsLimit属性进行配置。 |
| WeightedResponseTimeRule | 为每一个服务器赋予一个权重值。服务器响应时间越长，这个服务器的权重就越小。这个规则会随机选择服务器，这个权重值会影响服务器的选择。 |
| ZoneAvoidanceRule | 以区域可用的服务器为基础进行服务器的选择。使用Zone对服务器进行分类，这个Zone可以理解为一个机房、一个机架等。而后再对Zone内的多个服务做轮询。 |
| BestAvailableRule | 忽略那些短路的服务器，并选择并发数较低的服务器。 |
| RandomRule | 随机选择一个可用的服务器。 |
| RetryRule | 重试机制的选择逻辑 |

**这样我们完全可以自己配置一个bean来实现自定义负载均衡策略。**

### 配置方式：

#### 全局配置：
```java
@Bean
public IRule randomRule(){
    return new RandomRule();
}
```
这样配置,会导致我们选择任何服务者都是使用我们自己配置的RandomRule方式来选择服务的。即选择调用任何服务接口都是随机的。配置文件方式（非全局，需自己选择）：
```yaml
userservice:  # 服务名称
   ribbon:
     NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule  # 负载均衡规则
# 可配置其他的服务负载均衡规则
```


小提示：我们自己手动配置的bean会注入到Spring容器中，这样在给其他类添加属性bean时会将Spring容器中的bean注入到该对象上去。所以我们的配置的bean才会生效，走我们自己配置信息。


## Ribbon默认是懒加载模式：
默认第一次请求的时候，才会去创建LoadBalanceClient,请求时间会很长。

### 饥饿加载
我们配置饥饿加载会在项目启动时创建，降低第一次访问的耗时，我们可以通过下面的配置来开启饥饿加载：
```java
ribbon:
  eager-load:
    enabled: true # 开启饥饿加载
    clients: userservice  # 我们针对那个服务做的饥饿加载
```
```yaml
ribbon:
  eager-load:
    enabled: true # 开启饥饿加载
    clients:  # 配置针对多个
      - userservice
      - xxservice
```


## 稍作总结：
1、Ribbon负载均衡规则

- 默认接口是 IRule
- 默认选择是ZoneAvoidanceRule,根据zone选择服务列表，然后轮询

2、负载均衡自定义方式

- 代码方式：配置灵活，但修改时需要重新打包发布
- 配置方式：直观，方便，无需重新打包发布，但是无法做到全局配置

3、饥饿加载

- 开启饥饿加载
- 指定饥饿加载的微服务名称
