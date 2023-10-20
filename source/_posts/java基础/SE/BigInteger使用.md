---
title: BigInteger使用
date: 2023-09-07 17:59:14
categories:
- java基础
- SE
author: lx0815
comment: false
---

基本使用
```java
// 如果我们没有指定当前是几进制的，默认是10进制的
BigInteger integer = new BigInteger("100000");
System.out.println(integer);
// 将二进制将转换为10进制
BigInteger to16 = new BigInteger("1011100111",2);
System.out.println(to16);

BigInteger a = new BigInteger("13");
BigInteger b = new BigInteger("4");
// 加
BigInteger add = a.add(b);
// 减
BigInteger subtract = a.subtract(b);
// 乘
BigInteger multiply = a.multiply(b);
// 除
BigInteger divide = a.divide(b);
// 取模
BigInteger mod = a.mod(b);
// 取余
BigInteger remainder = a.remainder(b);
// 平方
BigInteger pow = a.pow(4);
// 绝对值
BigInteger abs = a.abs();
// 取相反数
BigInteger negate = a.negate();
```
比较大小
```java
BigInteger bigNum1 = new BigInteger("52");
BigInteger bigNum2 = new BigInteger("27");
// 1.compareTo()：返回一个int型数据（1 大于； 0 等于； -1 小于）
int num = bigNum1.compareTo(bigNum2); // 1
System.out.println("52与27谁大？" + (num > 0 ? "52" : "27"));
// 2.max()：直接返回大的那个数，类型为BigInteger
// 原理：return (compareTo(val) > 0 ? this : val);
BigInteger compareMax = bigNum1.max(bigNum2); // 52
System.out.println("较大的值：" + compareMax);
// 3.min()：直接返回小的那个数，类型为BigInteger
// 原理：return (compareTo(val) < 0 ? this : val);
BigInteger compareMin = bigNum1.min(bigNum2); // 27
System.out.println("较小的值" + compareMin);
```
转换为其他类型
```java
BigInteger bigNum = new BigInteger("52");
int radix = 2;
// 1.转换为bigNum的二进制补码形式
byte[] num1 = bigNum.toByteArray();
// 2.转换为bigNum的十进制字符串形式
String num2 = bigNum.toString(); // 52
// 3.转换为bigNum的radix进制字符串形式
String num3 = bigNum.toString(radix); // 110100
// 4.将bigNum转换为int
int num4 = bigNum.intValue();
// 5.将bigNum转换为long
long num5 = bigNum.longValue();
// 6.将bigNum转换为float
float num6 = bigNum.floatValue();
// 7.将bigNum转换为double
double num7 = bigNum.doubleValue();
```
