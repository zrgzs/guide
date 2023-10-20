---
title: springboottest ClassNotFoundException_ org.springframework.test.context.TestContextAnnotationUtils
date: 2023-09-07 17:59:14
categories:
- java项目合集
- ”宜优“
author: lx0815
comment: false
---

logs
```java
[ERROR] Tests run: 1, Failures: 0, Errors: 1, Skipped: 0, Time elapsed: 0.09 s <<< FAILURE! - in com.d.yiyouserver.userservicesmodule.UserServicesModuleApplicationTests
[ERROR] com.d.yiyouserver.userservicesmodule.UserServicesModuleApplicationTests  Time elapsed: 0.089 s  <<< ERROR!
java.lang.NoClassDefFoundError: org/springframework/test/context/TestContextAnnotationUtils
Caused by: java.lang.ClassNotFoundException: org.springframework.test.context.TestContextAnnotationUtils
[INFO] 
[INFO] Results:
[INFO] 
[ERROR] Errors: 
[ERROR]   UserServicesModuleApplicationTests » NoClassDefFound org/springframework/test/...
[INFO] 
[ERROR] Tests run: 1, Failures: 0, Errors: 1, Skipped: 0
```
原因：springboot和springboottest的版本不一样
