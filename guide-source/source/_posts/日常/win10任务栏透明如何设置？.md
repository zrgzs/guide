---
title: win10任务栏透明如何设置？
date: 2023-09-07 17:59:14
categories:
- 日常
author: lx0815
comment: false
---

1、设置-颜色-打开 透明效果![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220524.jpg)2、打开注册表，找到路径：
```latex
计算机\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced
```
![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220527.jpg)3、右侧找到名称 TaskbarAcrylicOpacity，如果没有，就右键新建一个DWORD（32位）值D；![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220530.jpg)4、将值修改为十进制0就是全透明，也可以是十进制0-10之间的效果。5、不用重启电脑，任务管理器重启windows资源管理器就行。设置完成后就是这样的了：![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220533.jpg)
