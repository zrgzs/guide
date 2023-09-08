---
title: @SuppressWarnings
date: 2023-09-07 17:59:14
categories:
- java基础
- 注解
author: lx0815
comment: false
---

例如：抑制多类型的警告：@SuppressWarnings("unchecked","rawtypes")

| **all** | **抑制所有警告** |
| --- | --- |
| boxing | 抑制装箱、拆箱操作时候的警告 |
| cast | 抑制映射相关的警告 |
| **ConstantConditions** | **抑制返回值可能为 null 的警告** |
| dep-ann | 抑制启用注释的警告 |
| **deprecation** | **抑制过期方法警告** |
| fallthrough | 抑制在 switch 中缺失 breaks 的警告 |
| finally | 抑制 finally 模块没有返回的警告 |
| hiding | 抑制相对于隐藏变量的局部变量的警告 |
| incomplete-switch | 忽略不完整的 switch 语句 |
| nls | 忽略非 nls 格式的字符 |
| null | 忽略对 null 的操作 |
| path | 在类路径、源文件路径等中有不存在的路径时的警告 |
| rawtypes | 使用 generics 时忽略没有指定相应的类型 |
| resource | 忽略泛型未指定类型的警告 |
| restriction | 忽略制禁止使用劝阻或禁止引用的警告 |
| serial | 忽略在 serializable 类中没有声明 serialVersionUID 变量 |
| static-access | 抑制不正确的静态访问方式警告 |
| synthetic-access | 抑制子类没有按最优方法访问内部类的警告 |
| try | 没有catch时的警告 |
| **unchecked** | **抑制没有进行类型检查操作的警告** |
| unqualified-field-access | 抑制没有权限访问的域的警告 |
| unused | 抑制没被使用过的代码的警告 |

