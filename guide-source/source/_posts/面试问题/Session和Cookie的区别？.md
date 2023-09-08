---
title: Session和Cookie的区别？
date: 2023-09-07 17:59:14
categories:
- 面试问题
author: wspstart
comment: false
---


## 1、相同点：
**cookie**和**session**都是用来跟踪浏览器用户身份的会话方式。

## 2、工作原理

### Cookie的工作原理
（1）浏览器端第一次发送请求到服务器端（2）服务器端创建Cookie，该Cookie中包含用户的信息，然后将该Cookie发送到浏览器端（3）浏览器端再次访问服务器端时会携带服务器端创建的Cookie（4）服务器端通过Cookie中携带的数据区分不同的用户![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907221026.jpg)

补充:在服务器在HTTP响应中发送Cookie时，浏览器会解析响应头部的Set-Cookie信息，并自动将Cookie存储在本地。前端开发人员无需显示操作，可通过JS提供的API来操作当前页面的Cookie。

### Session的工作原理
（1）浏览器端第一次发送请求到服务器端，服务器端创建一个Session，同时会创建一个特殊的Cookie（name为JSESSIONID的固定值，value为session对象的ID），然后将该Cookie发送至浏览器端（2）浏览器端发送第N（N>1）次请求到服务器端,浏览器端访问服务器端时就会携带该name为JSESSIONID的Cookie对象（3）服务器端根据name为JSESSIONID的Cookie的value(sessionId),去查询Session对象，从而区分不同用户。

- 若name为JSESSIONID的Cookie不存在（关闭或更换浏览器），返回1中重新去创建Session与特殊的Cookie；
- 若name为JSESSIONID的Cookie存在，根据value中的SessionId去寻找session对象
   - value为SessionId不存在（Session对象默认存活30分钟），返回1中重新去创建Session与特殊的Cookie
   - value为SessionId存在，返回session对象。

![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907221028.jpg)

![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907221031.jpg)

### 区别
cookie数据保存在客户端，session数据保存在服务端。session:当你登陆一个网站的时候，如果web服务器端使用的是session，那么所有的数据都保存在服务器上，客户端每次请求服务器的时候会发送当前会话sessionid，服务器根据当前sessionid判断相应的用户数据标志，以确定用户是否登陆或具有某种权限。由于数据是存储在服务器上面，所以你不能伪造。传统的会话管理技术可以选择将会话数据存储在数据库中。这通常涉及将会话数据和用户登录信息存储在同一个数据库中的不同表中，并通过某种方式将它们关联起来。cookie：sessionid是服务器和客户端连接时候随机分配的，如果浏览器使用的是cookie，那么所有数据都保存在浏览器端，比如你登陆以后，服务器设置了cookie用户名，那么当你再次请求服务器的时候，浏览器会将用户名一块发送给服务器，这些变量有一定的特殊标记。服务器会解释cookie变量，所以只要不关闭浏览器，那么cookie变量一直是有效的，所以能够保证长时间不掉线。补充：当涉及到大量并发用户执行登录操作时，会话管理技术可能会增加服务器的负载，并降低性能。这是因为每个用户的登录请求都需要进行IO操作，包括数据库查询和写入操作。这可能对数据库和服务器的性能产生一定的影响。为了处理高并发情况，可以采用一些优化措施，如使用缓存机制、数据库连接池和分布式部署等来提高性能和扩展性。

### 区别对比
(1)cookie数据存放在客户的浏览器上，session数据放在服务器上(2)cookie不是很安全，别人可以分析存放在本地的COOKIE并进行COOKIE欺骗,如果主要考虑到安全应当使用session(3)Session数据会在一定时间内保存在服务器上，因此在访问量增加时，会占用服务器的内存和性能。如果关注服务器性能方面的考虑，可以使用Cookie来减轻服务器的负载。Cookie存储在客户端，不会占用服务器的内存资源。(4)单个cookie在客户端的限制是4KB，每个域名在客户端存储的Cookie数量也是有限制的，通常是几十个或几百个。因此，需要注意Cookie的大小和数量，以避免超出限制。(5)所以：将登陆信息等重要信息存放为SESSION;其他信息如果需要保留，可以放在COOKIE中

