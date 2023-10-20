---
title: SpringBoot logback-spring.xml
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---

网上CV的一个配置，感觉很不错，收藏一下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
scan：当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true。
scanPeriod：设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒当scan为true时，此属性生效。默认的时间间隔为1分钟。
debug：当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false。
-->
<configuration scan="true" scanPeriod="60 seconds" debug="false">
    <!--自定义颜色配置 此处converterClass引用的是日志颜色类的路径， 此匹配的是第二种控制台色彩输出方式-->
    <conversionRule conversionWord="customcolor" converterClass="com.xiaozhao.xiaozhaoserver.common.config.LogbackColorConfig"/>
    <!-- 定义日志文件名称 -->
    <property name="APP_NAME" value="xiaozhao"/>
    <!-- 定义日志的要保存的根目录 -->
    <property name="LOG_HOME" value="${user.home}/${APP_NAME}/logs"/>

    <!--第二种控制台色彩输出方式-->
    <appender name="CONSLOG" class="ch.qos.logback.core.ConsoleAppender">
        <!--
        日志输出格式：
            %d表示日期时间，
            %thread表示线程名，
            %-5level：级别从左显示5个字符宽度
            %logger{50} 表示logger名字最长50个字符，否则按照句点分割。
            %msg：日志消息，
            %n是换行符
        -->
        <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
            <pattern>%red(%d{yyyy-MM-dd HH:mm:ss.SSS}) %green([%thread]) %customcolor(%-5level) %boldMagenta(%logger) -
                %msg%n
            </pattern>
        </encoder>
        <!-- 如果线上log日志出现中文乱码,下面这句有关编码设置的要删除或注释掉,原因不明-->
<!--        <charset>UTF-8</charset>-->
    </appender>
    <!-- 滚动记录文件，先将日志记录到指定文件，当符合某个条件时，将日志记录到其他文件   -->
    <!--该配置表示每天生成一个日志文件，保存30天的日志文件。-->
    <appender name="appLogAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- 指定日志文件的名称 -->
        <file>${LOG_HOME}/${APP_NAME}.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <fileNamePattern>${LOG_HOME}/${APP_NAME}-%d{yyyy-MM-dd}-%i.zip</fileNamePattern>
            <MaxHistory>120</MaxHistory>
            <maxFileSize>100MB</maxFileSize>
            <totalSizeCap>5GB</totalSizeCap>
        </rollingPolicy>
        <!-- 日志输出格式： -->
        <layout class="ch.qos.logback.classic.PatternLayout">
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [ %thread ] - [ %-5level ] [ %logger{50} : %line ] - %msg%n</pattern>
        </layout>
    </appender>
    <!-- 开发、测试环境 -->
    <springProfile name="dev,test">
        <logger name="org.springframework.web" level="INFO"/>
        <logger name="org.springboot.sample" level="INFO"/>
        <!-- com.xiaozhao.xiaozhaoserver.mapper 是本项目的dao层的包，日志级别调成 DEBUG级别可以看到sql执行-->
        <logger name="com.xiaozhao.xiaozhaoserver.*" level="DEBUG"/>
    </springProfile>

    <!-- 生产环境 -->
    <springProfile name="prod">
        <!--logger用来设置某一个包或者具体的某一个类的日志打印级别-->
        <!--name用来指定受此loger约束的某一个包或者具体的某一个类-->
        <logger name="org.springframework.web" level="ERROR"/>
        <logger name="org.springboot.sample" level="ERROR"/>
        <!--com.fristapp 为项目类的全路径  日志级别调成 DEBUG级别可以看到sql执行-->
        <logger name="com.xiaozhao.xiaozhaoserver.*" level="ERROR"/>
    </springProfile>

    <!-- level用来设置打印级别，大小写无关-->
    <root level="info">
        <!-- 控制台输出日志-->
        <appender-ref ref="CONSLOG"/>
        <!-- 打印错误日志 每天-->
        <appender-ref ref="appLogAppender"/>
    </root>
</configuration>

        <!-- ch.qos.logback.core.ConsoleAppender 表示控制台输出
            第一种控制台色彩输出方式：这种控制台输出不用方式不用去引用日志颜色类
        <appender name="CONSLOG" class="ch.qos.logback.core.ConsoleAppender">
            <encoder>
                <pattern>%red(%d{yyyy-MM-dd HH:mm:ss.SSS}) %green([%thread]) %highlight(%-5level) %boldMagenta(%logger) -
                    %msg%n
                </pattern>
        -->
                <!--如果线上log日志出现中文乱码,下面这句有关编码设置的要删除或注释掉,原因不明-->
        <!--
                <charset>UTF-8</charset>
            </encoder>
        </appender>
        -->
```
