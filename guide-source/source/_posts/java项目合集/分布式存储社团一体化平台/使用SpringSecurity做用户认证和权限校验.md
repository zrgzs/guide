---
title: 使用SpringSecurity做用户认证和权限校验
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 分布式存储社团一体化平台
author: wspstart
comment: false
---


## 基础：
Spring Security 是一个专注于为 Java 应用程序提供身份认证和授权的框架。推荐使用权限认证方式配置：SSM + Shiro;Springboot+SpringSecurity

- 身份认证（authentication），即验证用户身份的合法性，以判断用户能否登录。
- 授权（authorization），即验证用户是否有权限访问某些资源或者执行某些操作。

## 实质：
实质上SpringSecurity在进行身份认证方面主要通过一系列的过滤器链来实现的，我们加入SpringSecurity项目的时候可以看到控制台会输出DefaultSecurityFilterChain打印出来默认的过滤器链。如果我们想要对相应的地方做修改，只需修改过滤器即可，在过滤器链完成过程中加入我们的业务代码逻辑即可。

## SpringSecurity核心过滤器链
我们看视频常会看到说有15个基本过滤器链(Filter)，但是我们常用的也就那几个。

## 浅要说一下：什么是过滤器链？
Filter 可以在服务器作出响应前拦截用户请求，并在拦截后修改 request 和 response，可实现一次编码、多处应用。Filter 主要有以下两点作用：

- 拦截请求：在 HttpServletRequest 到达 Servlet 之前进行拦截，查看和修改 HttpServletRequest 的 Header 和数据。
- 拦截响应：在 HttpServletResponse 到达客户端之前完成拦截，查看和修改 HttpServletResponse 的 Header 和数据。

过滤器链作为SpringSecurity的核心，我从网上找来一个图，可以很好的解释一下过滤器链的执行流程：![](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220233.jpg)

## SpringSecuity 部分过滤器的执行流程：

- **SecurityContextPersistenceFilter**：整个 Spring Security 过滤器链的开端。主要有两点作用：（1）当请求到来时，检查 Session中是否存在 SecurityContext，若不存在，则创建一个新的 SecurityContext；（2）在请求结束时，将 SecurityContext 放入 Session 中，并清空 SecurityContextHolder。
- **UsernamePasswordAuthenticationFilte**r：继承自抽象类 AbstractAuthenticationProcessingFilter。当进行表单登录时，该 Filter 将用户名和密码封装成UsernamePasswordAuthenticationToken 进行验证。
- **AnonymousAuthenticationFilter**：匿名身份过滤器，一般用于匿名登录。当前面的 Filter 认证后依然没有用户信息时，该Filter会生成一个匿名身份 AnonymousAuthenticationToken。
- **ExceptionTranslationFilter**：异常转换过滤器，用于处理 FilterSecurityInterceptor 抛出的异常。但是只会处理两类异常：AuthenticationException 和 AccessDeniedException，其它的异常它会继续抛出。

## 了解了SpringSecurity的执行流程之后，我们先来认识一下其中的核心组件：

- **SecurityContextHolder**：用于获取 **SecurityContext** 的静态工具类，是Spring Security 存储身份验证者详细信息的位置。
- **SecurityContext：** 上下文对象，Authentication 对象会放在里面。
- **Authentication：** 认证接口，定义了认证对象的数据形式。
- **AuthenticationManager：** 用于校验 Authentication，返回一个认证完成后的 Authentication 对象。

我们可以随时获取SecurityContext上下文对象，这样我们可以更改其中的权限认证信息，这是很重要的，当时写社团在线平台就不知道这个想了好久。离大谱。

SecurityContextHolder 用于存储安全上下文（SecurityContext）的信息。而如何保证用户信息的安全，Spring Security 采用“用户信息和线程绑定”的策略，SecurityContextHolder 默认采用 ThreadLocal 机制保存用户的 SecurityContext，在使用中可以通过 SecurityContextHolder 工具轻松获取用户安全上下文。这意味着，只要是针对某个使用者的逻辑执行都是在同一个线程中进行，Spring Security 会在用户登录时自动绑定认证信息到当前线程，在用户退出时也会自动清除当前线程的认证信息。![](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220235.jpg)其中，getAuthentication() 返回认证信息，getPrincipal() 返回身份信息。 SecurityContext 是从 SecurityContextHolder 获得的。SecurityContext 包含一个 Authentication对象。

## SpringSecurity的认证流程![](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220237.jpg)
根据这张图，这样来看我的代码，就能很清晰了，我们需要实现UserDetailsSerivce的loadUserByUsername()方法，我们在这个方法里面进行查询数据库，判断用户是否存在来进行登录认证操作，同时我们的返回的UserDetails实体类是Security框架自带的，我们可以继承他，然后返回我们自己的实体类，注意返回的UserDetails.

### 官方话如下：
结合上面的时序图，让我们先熟悉下 Spring Security 的认证流程：

1. 用户进行认证，用户名和密码被 SecurityFilterChain 中的 UsernamePasswordAuthenticationFilter 过滤器拦截，并将请求封装为 Authentication，其默认实现类是 UsernamePasswordAuthenticationToken。
2. 将封装的 UsernamePasswordAuthenticationToken 提交至 AuthenticationManager（认证管理器）进行认证。
3. 认证成功后， AuthenticationManager（身份管理器）会返回一个包含用户身份信息的 Authentication 实例（包括身份信息，细节信息，但密码通常会被移除）。
4. SecurityContextHolder （安全上下文容器）将认证成功的 Authentication 存储到 SecurityContext（安全上下文）中。
> 其中，AuthenticationManager 接口是认证相关的核心接口，ProviderManager 是它的实现类。因为 Spring Security 支持多种认证方式，所以 ProviderManager 维护着一个List<AuthenticationProvider> 列表，包含多种认证方式，最终实际的认证工作就是由列表中的 AuthenticationProvider 完成的。其中最常见的 web 表单认证的对应的 AuthenticationProvider 实现类为 DaoAuthenticationProvider，它的内部又维护着一个 UserDetailsService负责获取 UserDetails。最终 AuthenticationProvider 将 UserDetails 填充至 Authentication。


## 用户密码过滤器（UsernamePasswordAuthenticationFilter）：
以用户名密码认证为例 ，请求被 UsernamePasswordAuthenticationFilter 过滤器拦截，UsernamePasswordAuthenticationFilter 根据Request 中提交的用户名和密码创建一个 Token(UsernamePasswordAuthenticationToken)。

## UsernamePasswordAuthenticationToken这玩意是啥？
实质上：UsernamePasswordAuthenticationToken 的核心就是两个构造方法，分别用于初始化未认证和认证的 Token。

### 官方话：
这一步是身份认证的核心，下面进行详细讲解：

1. 未认证的 UsernamePasswordAuthenticationToken（携带用户名、密码信息）被提交给 AuthenticationManager。AuthenticationManager 的实现类 ProviderManager 负责对认证请求链 AuthenticationProviders 进行管理。
2. ProviderManager 通过循环的方式，发现 DaoAuthenticationProvider 的类型符合，使用 DaoAuthenticationProvider 进行认证。
3. DaoAuthenticationProvider 从 UserDetailsService 中查找 UserDetails。
4. DaoAuthenticationProvider 使用 PasswordEncoder 验证上一步返回的 UserDetails 中的用户密码。
5. 当身份验证成功， Authentication 返回一个已认证的 UsernamePasswordAuthenticationToken ，其中包含 UserDetailsService 返回的 UserDetails 信息。最终，认证成功的 UsernamePasswordAuthenticationToken 添加到 SecurityContextHolder 完成账号密码的身份认证。

看下这图就了解差不多了：![](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220239.jpg)
