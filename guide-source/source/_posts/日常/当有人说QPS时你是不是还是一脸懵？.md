---
title: 当有人说QPS时你是不是还是一脸懵？
date: 2023-09-07 17:59:14
categories:
- 日常
author: wspstart
comment: false
---


## **一、QPS是什么**
**QPS**QPS即每秒查询率，是对一个特定的查询服务器在规定时间内所处理流量多少的衡量标准。**每秒查询率**因特网上，经常用每秒查询率来衡量域名系统服务器的机器的性能，即为QPS。对应fetches/sec，即每秒的响应请求数，也即是最大吞吐能力。**计算关系：**QPS = 并发量 / 平均响应时间并发量 = QPS * 平均响应时间

## **二、** **TPS是什么**
TPS：Transactions Per Second（每秒传输的事物处理个数），即服务器每秒处理的事务数。TPS包括一条消息入和一条消息出，加上一次用户数据库访问。（业务TPS = CAPS × 每个呼叫平均TPS）TPS是软件测试结果的测量单位。一个事务是指一个客户机向服务器发送请求然后服务器做出反应的过程。客户机在发送请求时开始计时，收到服务器响应后结束计时，以此来计算使用的时间和完成的事务个数。一般的，评价系统性能均以每秒钟完成的技术交易的数量来衡量。系统整体处理能力取决于处理能力最低模块的TPS值。例如：天猫双十一，一秒完成多少订单

## **三、QPS与TPS的区别是什么呢？**
举个栗子：假如一个大胃王一秒能吃10个包子，一个女孩子0.1秒能吃1个包子，那么他们是不是一样的呢？答案是否定的，因为这个女孩子不可能在一秒钟吃下10个包子，她可能要吃很久。这个时候这个大胃王就相当于TPS，而这个女孩子则是QPS。虽然很相似，但其实是不同的。
