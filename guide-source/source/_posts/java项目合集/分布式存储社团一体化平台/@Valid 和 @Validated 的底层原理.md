---
title: @Valid 和 @Validated 的底层原理
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 分布式存储社团一体化平台
author: lx0815
comment: false
---


# 1 环境
SpringBoot 2.7.6Java8

# 2 正文
首先我们在 `Controller` 层的方法参数中添加一个 `@Email`的注解用于校验单个参数是否为合法的邮箱格式。然后在 `Controller` 类上添加 `@Validated` 注解，让 `Springboot` 进行 **参数校验。**那么 `Sprinboot` 是如何完成参数校验的呢？这里就以 `@Email` 注解为例。

## 2.1 找到注解的处理器
进入 `@Email` 的源代码之后，使用 `Ctrl + 鼠标左键` 即可查看该注解的所有用法，在所有用法里可以看见一个类：`EmailValidator` ，从命名和该类所在的包可以断定：`org.hibernate.validator.internal.constraintvalidators.bv.EmailValidator` 即为校验被 `@Email` 所标注的参数的。![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220202.jpg)于是我们在其 `isValid()` 中打个断点，并调试启动本项目。![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220205.jpg)

## 2.2 调用接口，开始 Debug
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220207.jpg)从 `doDispatch()` 到校验参数的方法栈如图。![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220210.jpg)这是调用没有方法校验的接口时的方法栈信息。通过把两次调用不同接口的线程转储日志存放到文件中后进行对比（文件会放最后），如下图：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220212.jpg)可以看到两者的栈日志是从 `org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:xxx)` 开始的，两者的区别如下图：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220217.jpg)步入![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220221.jpg)步入![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220224.jpg) 画饼结束，看不懂。总结：

- 参数校验的方式是通过 AOP 切面









# 附件
```java
"http-nio-7476-exec-1@8561" 守护进程 prio=5 tid=0x43 nid=NA runnable
    java.lang.Thread.State: RUNNABLE
    at com.sgqn.clubonline.web.controller.UserController.register(UserController.java:23)
    at com.sgqn.clubonline.web.controller.UserController$$FastClassBySpringCGLIB$$175fa3ea.invoke(<generated>:-1)
    at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)
    at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.invokeJoinpoint(CglibAopProxy.java:793)
    at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:163)
    at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
    at org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:89)
    at com.sgqn.clubonline.web.aspect.GlobalRequestLoggerAspect.around(GlobalRequestLoggerAspect.java:40)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-1)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:498)
    at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:634)
    at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:624)
    at org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:72)
    at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
    at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
    at org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:97)
    at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
    at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
    at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:708)
    at com.sgqn.clubonline.web.controller.UserController$$EnhancerBySpringCGLIB$$b508e7de.register(<generated>:-1)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-1)
    at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at java.lang.reflect.Method.invoke(Method.java:498)
    at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
    at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:150)
    at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:117)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:895)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:808)
    at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87)
    at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1071)
```
```java
"http-nio-7476-exec-3@8562" 守护进程 prio=5 tid=0x45 nid=NA runnable
  java.lang.Thread.State: RUNNABLE
	  at org.hibernate.validator.internal.constraintvalidators.bv.EmailValidator.isValid(EmailValidator.java:55)
	  at org.hibernate.validator.internal.constraintvalidators.bv.EmailValidator.isValid(EmailValidator.java:26)
	  at org.hibernate.validator.internal.engine.constraintvalidation.ConstraintTree.validateSingleConstraint(ConstraintTree.java:180)
	  at org.hibernate.validator.internal.engine.constraintvalidation.SimpleConstraintTree.validateConstraints(SimpleConstraintTree.java:62)
	  at org.hibernate.validator.internal.engine.constraintvalidation.ConstraintTree.validateConstraints(ConstraintTree.java:75)
	  at org.hibernate.validator.internal.metadata.core.MetaConstraint.doValidateConstraint(MetaConstraint.java:130)
	  at org.hibernate.validator.internal.metadata.core.MetaConstraint.validateConstraint(MetaConstraint.java:123)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateMetaConstraint(ValidatorImpl.java:555)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateMetaConstraints(ValidatorImpl.java:537)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateParametersForSingleGroup(ValidatorImpl.java:991)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateParametersForGroup(ValidatorImpl.java:932)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateParametersInContext(ValidatorImpl.java:863)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateParameters(ValidatorImpl.java:283)
	  at org.hibernate.validator.internal.engine.ValidatorImpl.validateParameters(ValidatorImpl.java:235)
	  at org.springframework.validation.beanvalidation.MethodValidationInterceptor.invoke(MethodValidationInterceptor.java:110)
	  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
	  at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	  at org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:89)
	  at com.sgqn.clubonline.web.aspect.GlobalRequestLoggerAspect.around(GlobalRequestLoggerAspect.java:40)
	  at sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-1)
	  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	  at java.lang.reflect.Method.invoke(Method.java:498)
	  at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:634)
	  at org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:624)
	  at org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:72)
	  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
	  at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	  at org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:97)
	  at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
	  at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
	  at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:708)
	  at com.sgqn.clubonline.web.controller.PermissionController$$EnhancerBySpringCGLIB$$2fb37eaa.captcha(<generated>:-1)
	  at sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-1)
	  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	  at java.lang.reflect.Method.invoke(Method.java:498)
	  at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
	  at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:150)
	  at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:117)
	  at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:895)
	  at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:808)
	  at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87)
	  at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1071)
```
