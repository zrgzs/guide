---
title: Gradle 的初步使用
date: 2023-09-07 17:59:14
categories:
- 构建工具
author: lx0815
comment: false

---

1. 首先到 [Gradle 官网](https://gradle.org/)下载压缩包，然后将其解压到合适位置。
2. 新建一个 本地依赖仓库。
3. 新增环境变量
   1. `GRADLE_HOME=你的解压路径`
   2. `GRADLE_USER_HOME=本地依赖仓库路径`
   3. `PATH`中新增 `%GRADLE_HOME%\bin` 即可
4. 在 `GRADLE_HOME` 目录下的 `init.d` 文件夹中新建一个名为 `init.gradle` 的文件（文件名可变，但必须以 gradle 为后缀），其中添加如下代码用于配置远程镜像仓库。
```java
allprojects {
    repositories {
        // 注意替换配置中的本地仓库路径
        maven { url 'file:///D:/developmentEnvironment/gradle-repository'}
        mavenLocal()
        maven { name "Alibaba" ; url "https://maven.aliyun.com/repository/public" }
        mavenCentral()
    }

    buildscript { 
        repositories { 
            maven { name "Alibaba" ; url 'https://maven.aliyun.com/repository/public' }
            maven { name "M2" ; url 'https://plugins.gradle.org/m2/' }
        }
    }
}
```

5. IDEA 中的配置如下图

![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220543.jpg)
