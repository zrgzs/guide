---
title: MySQL建表报错Invalid default value for ‘begin_time‘
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---

我在建表的时候：
```sql
DROP TABLE IF EXISTS `tb_blog`;
CREATE TABLE `tb_blog`  (
                            `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
                            `shop_id` bigint(20) NOT NULL COMMENT '商户id',
                            `user_id` bigint(20) UNSIGNED NOT NULL COMMENT '用户id',
                            `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
                            `images` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '探店的照片，最多9张，多张以\",\"隔开',
                            `content` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '探店的文字描述',
                            `liked` int(8) UNSIGNED NULL DEFAULT 0 COMMENT '点赞数量',
                            `comments` int(8) UNSIGNED NULL DEFAULT NULL COMMENT '评论数量',
                            `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;
```
执行这段语句报错,报错信息为：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220353.jpg)这个报错是由于MySQL的严格模式导致的，解决方式：在命令行中执行sql_mode:
```sql
SET SESSION sql_mode ='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
```
这样再执行SQL语句就不会报错了。
