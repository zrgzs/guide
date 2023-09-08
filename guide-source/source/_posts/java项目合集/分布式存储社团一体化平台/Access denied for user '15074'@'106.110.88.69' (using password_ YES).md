---
title: Access denied for user '15074'@'106.110.88.69' (using password_ YES)
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 分布式存储社团一体化平台
author: wspstart
comment: false
---

```java
二月 22, 2023 8:24:18 下午 com.alibaba.druid.support.logging.JakartaCommonsLoggingImpl info
信息: {dataSource-1} inited
二月 22, 2023 8:24:18 下午 com.alibaba.druid.support.logging.JakartaCommonsLoggingImpl error
严重: create connection SQLException, url: jdbc:mysql://43.142.113.254:1103/club_manager_server, errorCode 1045, state 28000
java.sql.SQLException: Access denied for user '15074'@'106.110.88.69' (using password: YES)
	at com.mysql.cj.jdbc.exceptions.SQLError.createSQLException(SQLError.java:129)
	at com.mysql.cj.jdbc.exceptions.SQLExceptionsMapping.translateException(SQLExceptionsMapping.java:122)
	at com.mysql.cj.jdbc.ConnectionImpl.createNewIO(ConnectionImpl.java:828)
	at com.mysql.cj.jdbc.ConnectionImpl.<init>(ConnectionImpl.java:448)
	at com.mysql.cj.jdbc.ConnectionImpl.getInstance(ConnectionImpl.java:241)
	at com.mysql.cj.jdbc.NonRegisteringDriver.connect(NonRegisteringDriver.java:198)
	at com.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1678)
	at com.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1755)
	at com.alibaba.druid.pool.DruidDataSource$CreateConnectionThread.run(DruidDataSource.java:2825)
```
原因：properties 配置文件中的 username 被 spring 赋值为了计算机名。所以 properties 中的 username 需要添加前缀。
