---
title: 在飞书中添加自定义指令监听 GitHub 事件
date: 2023-10-07
categories:
- 飞书
author: lx0815
comment: false
---

# 1 新建指令

在飞书机器人助手中，新建机器人指令。

![新建指令](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/202310071028295.png)

# 2 设置流程

## 2.1 设置触发器

1. 触发器选择 webhook
2. 复制 webhook 地址到 GitHub 仓库 -> setting -> webhook
3. 参数填写如下内容：
   ```text
   {
       "ref": "",
       "after": "",
       "pusher": {
           "name": "",
           "email": ""
       },
       "head_commit": {
           "id": "",
           "message": "",
           "timestamp": "",
           "url": ""
       }
   }
   ```

## 2.2 添加下一个操作：筛选

并在条件组1中添加一个条件：

`Webhook.触发.ref 等于 refs/heads/develop`

这是表示，获取 webhook 中的 json 参数中的 ref 字段的值，然后判断是否等于 `refs/heads/develop`

当 ref 字段的值为 `refs/heads/develop` 时，即 develop 分支上发生了事件

## 2.3 添加下一个操作：通过官方机器人发消息

发送的消息就可以根据情况自定义了，这里不再赘述。

# 3 GitHub 配置

刚刚复制了 webhook 地址过来之后

Content type 选择 application/json

Secret 不用填

监听的事件可以根据情况选择，这里只监听推送事件，所以就只选择了 `Just the push event.`

