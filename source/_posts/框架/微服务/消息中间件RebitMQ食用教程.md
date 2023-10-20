---
title: 消息中间件RebitMQ食用教程
date: 2023-09-07 17:59:14
categories:
- 框架
- 微服务
author: wspstart
comment: false
---


## 一、初识MQ
同步调用的问题微服务间基于Feign的调用就属于同步方式，存在一些问题。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220922.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220926.jpg)

### 同步调用的优点：
时效性较强，可以立即得到结果

### 同步调用的问题：
耦合度高性能和吞吐能力下降有额外的资源消耗有级联失败问题

故此异步调用方案产生：异步调用常见实现就是事件驱动模式![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220931.jpg)

### 事件驱动的优势：
优势一：服务解耦![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220936.jpg)优势二：性能提升，吞吐量提高![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220940.jpg)优势三：服务没有强依赖，不担心级联失败问题![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220944.jpg)优势四：流量削峰![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220949.jpg)

### 异步通信的优点：
耦合度低吞吐量提升故障隔离流量削峰

#### 异步通信的缺点：
依赖于Broker的可靠性、安全性、吞吐能力架构复杂了，业务没有明显的流程线，不好追踪管理![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220953.jpg)		

## 二、RabbitMQ快速入门

### 安装RabbitMQ
在线拉取：docker pull rabbitmq:3-management

启动命令： （注释去掉）docker run \ -e RABBITMQ_DEFAULT_USER=lyggwsp \ -e RABBITMQ_DEFAULT_PASS=wyr0307 \ --name mq \ --hostname mq1 \ -p 15672:15672 \  # 管理访问端口 -p 5672:5672 \  # 通讯端口 -d \ rabbitmq:3-management

我们访问主机地址+15672端口任然无效，是因为我们插件没开：进入容器内部：docker exec -it mq bash修改插件：rabbitmq-plugins enable rabbitmq_management这样我们访问就有效了。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220957.jpg)

rabbitmq的结构和概念：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221001.jpg)

### RabbitMQ中的几个概念：
channel：操作MQ的工具exchange：路由消息到队列中queue：缓存消息virtual host：虚拟主机，是对queue、exchange等资源的逻辑分组

常见的消息模型：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221005.jpg)官方的HelloWorld是基于最基础的消息队列模型来实现的，只包括三个角色：

- publisher：消息发布者，将消息发送到队列
- queuequeue：消息队列，负责接受并缓存消息
- consumer：订阅队列，处理队列中的消息

![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221009.jpg)


### 基本消息队列的消息发送流程：
建立connection创建channel利用channel声明队列利用channel向队列发送消息基本消息队列的消息接收流程：建立connection创建channel利用channel声明队列定义consumer的消费行为handleDelivery()利用channel将消费者与队列绑定

## 三、SpringAMQP
步骤1：引入AMQP依赖因为publisher和consumer服务都需要amqp依赖，因此这里把依赖直接放到父工程mq-demo中：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221013.jpg)步骤2：在publisher中编写测试方法，向simple.queue发送消息
```yaml
spring:
  rabbitmq:
    # 主机名
    host: 101.42.152.244
    port: 5672
    #虚拟主机
    virtual-host: "/"
    # 用户名
    username: lyggwsp
    # 密码
    password: wyr0307
```

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class SpringAMOPTest {

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @Test
    public void testS(){
        String queueName = "simple.queue";
        String message = "hello,my name is publisher";
        rabbitTemplate.convertAndSend(queueName,message);
    }

}

```


#### 什么是AMQP？
应用间消息通信的一种协议，与语言和平台无关。

#### SpringAMQP如何发送消息？
引入amqp的starter依赖配置RabbitMQ地址利用RabbitTemplate的convertAndSend方法

步骤3：在consumer中编写消费逻辑，监听simple.queue

```yaml
spring:
  rabbitmq:
    # 主机名
    host: 101.42.152.244
    port: 5672
    #虚拟主机
    virtual-host: "/"
    # 用户名
    username: lyggwsp
    # 密码
    password: wyr0307
```
这是一个组件一个组件！！！！
```java
@Component
public class SpringAMOPA {

    @RabbitListener(queues = "simple.queue")
    public void t(String msg){
        System.out.println("接收到的消息是：" + msg);
    }
}	
```

SpringAMQP如何接收消息？引入amqp的starter依赖配置RabbitMQ地址定义类，添加@Component注解类中声明方法，添加@RabbitListener注解，方法参数就时消息注意：消息一旦消费就会从队列删除，RabbitMQ没有消息回溯功能

Work Queue 工作队列Work queue，工作队列，可以提高消息处理速度，避免队列消息堆积![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221016.jpg)模拟WorkQueue，实现一个队列绑定多个消费者

基本思路如下：在publisher服务中定义测试方法，每秒产生50条消息，发送到simple.queue在consumer服务中定义两个消息监听者，都监听simple.queue队列消费者1每秒处理50条消息，消费者2每秒处理10条消息

这玩意讲的也就是一个重点：（在监听者yml配置文件中多配置一下prefetch：）
```yaml
spring:
  rabbitmq:
    # 主机名
    host: 101.42.152.244
    port: 5672
    #虚拟主机
    virtual-host: "/"
    # 用户名
    username: lyggwsp
    # 密码
    password: wyr0307
    # 控制预取消息的上限
    listener:
      simple:
        prefetch: 1 # 每次只能获取一条消息，处理完成之后才能获取下一条
```

### Work模型的使用：
多个消费者绑定到一个队列，同一条消息只会被一个消费者处理通过设置prefetch来控制消费者预取的消息数量

发布（ Publish ）、订阅（ Subscribe ）发布订阅模式与之前案例的区别就是允许将同一消息发送给多个消费者。实现方式是加入了exchange（交换机）。常见exchange类型包括：Fanout：广播Direct：路由Topic：话题![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221020.jpg)注意：exchange负责消息路由，而不是存储，路由失败则消息丢失


#### 发布订阅-Fanout Exchange
Fanout Exchange 会将接收到的消息广播到每一个跟其绑定的queue![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907221024.jpg)

### Basic Queue 简单队列模型

### Work Queue 工作队列模型

### 发布、订阅模型-Fanout

### 发布、订阅模型-Direct

### 发布、订阅模型-Topic

### 消息转换器
