---
title: SpringBoot 调用第三方接口时的公私钥管理
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---


# SpringBoot 调用第三方接口时的公私钥管理


## 前言

项目中或多或少的会使用到一些第三方的接口，而调用第三方接口一般会有密钥。例如微信小程序的 `appid`，`secret`。七牛云存储的 `accessKey`、`secretKey` 等。这些东西不能直接放在代码或配置文件中，否则会出现很大的安全隐患。

目前了解到最好的解决方案就是放在环境变量中。`Java` 程序可以通过 `System.getEnv(envName)` 去获取。

那么怎么把敏感数据放进环境变量呢？这里我们使用 `powershell` 脚本。


## 方法一：powershell 脚本设置环境变量


### 设置环境变量

语法：

`[Environment]::SetEnvironmentVariable("ENV_NAME", "ENV_VALUE", [EnvironmentVariableTarget]::User)`

- 第一个参数：环境变量名称
- 第二个参数：环境变量值
- 第三个参数：环境变量范围

   - 不写的话默认是当前程序，仅在当前程序生效
   - `[EnvironmentVariableTarget]::User` 表示设置为用户环境变量
   - `[EnvironmentVariableTarget]::Machine` 表示设置为系统环境变量


### 删除环境变量

设置的时候第二个参数为空串即可删除


### 代码中使用

使用 `System.getEnv(envName)` 即可


## 方法二：使用 [@PropertySource ](/PropertySource ) 

思路：总之不能把敏感数据放代码中，那么把它放在一个配置文件中，并且不纳入`Git`管理即可。

所以在启动类上面添加注解 `@PropertySource` ，参数写上包含环境变量名称的配置文件。

<a name="07775618-1"></a>
### 代码中使用

1. `@Value` 注解上直接使用 `${envName}`
2. `Environment#getProperty(Stirng)` 方法获取
