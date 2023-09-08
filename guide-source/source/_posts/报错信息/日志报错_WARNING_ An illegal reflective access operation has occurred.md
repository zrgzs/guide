---
title: 日志报错_WARNING_ An illegal reflective access operation has occurred
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---


## 1、问题描述
  在起项目的时候遇到代码段的问题,但是不影响我们的程序启动,和调试,但是居然有错误那就应该好好找找看看是问题了。日志信息：
```java
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by com.baomidou.mybatisplus.core.toolkit.SetAccessibleAction (file:/D:/development_toops/maven/maven-repository/com/baomidou/mybatis-plus-core/3.4.3/mybatis-plus-core-3.4.3.jar) to field java.lang.invoke.SerializedLambda.capturingClass
WARNING: Please consider reporting this to the maintainers of com.baomidou.mybatisplus.core.toolkit.SetAccessibleAction
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
```
意思是：这是一个警告信息，表示在程序中发生了非法的反射访问操作。反射是Java中的一种机制，允许程序在运行时获取类的信息并操作它们。但是，在某些情况下，反射可能会导致安全问题，因为它可以让程序访问类的私有成员和方法，从而可能导致程序的安全漏洞。因此，为了避免这种情况，Java引入了安全管理器，用于限制程序对反射的访问权限。如果程序中出现了非法的反射访问操作，就会触发这个警告信息。

## 2、出错原因
在JDK 8之前(包括java8) ，Java允许通过反射机制访问所有的成员，这些成员的类型包括私有(private)，公共(public)，包(< package >)和受保护(protected)。JDK9新增的功能之一 —— 模块系统对反射的行为做出了一定的限制。从JDK9开始，对于非公有的成员、成员方法和构造方法，模块不能通过反射直接去访问，但是JDK9提供了一个可选的修饰符open来声明一个开放模块，可以从一个开放模块中导出所有的包，以便在运行时对该模块中的所有包中的所有类型进行深层反射来访问。


## 3、解决问题：

### 1、方案一
降低项目使用的JDK版本，从jdk11->jdk8就可以了。![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220427.jpg)

### 2、方案二
 **使用 --illegal-access 参数****通过阅读控制的警告信息，我们能发现：	**
```java
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
```
他已经说明了使用Use --illegal -access参数信息了常见的参数信息为：   其常用的参数值如下：
> permit 默认行为，允许通过反射进行访问。当第一次尝试通过反射进行非法访问时会生成一个警告，之后不会再进行警告。
> warn 与permit相同，但每次非法访问时都会产生警告。其大致等效于 “–permit-illegal-access”。
> debug 每次非法访问产生警告的同时打印非法访问的堆栈跟踪信息。
> deny 不允许所有的非法访问操作，除了启用其它命令行参数排除的模块，例如"–add-opens"，这个参数可以参数将某些模块排除出来，让它们能够通过非法反射进行访问

书写方式：
```java
参数 --add-opens  java.base/java.base模块内的jar包名 = ALL-UNNAMED 
```
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220430.jpg)这样修改并不是长久之计：这仅是一种临时解决方案，不建议在生产环境中长期使用。

3、方案三按照模块化开发的方案来解决，等我学会了模块化开发我再来补充 // TODO

