---
title: Win10任务栏美化
date: 2023-09-07 17:59:14
categories:
- 日常
author: lx0815
comment: false
---

- 需要的软件：TranslucentTB

懒人版：
```json
// See https://TranslucentTB.github.io/config for more information
{
  "$schema": "https://sylveon.dev/TranslucentTB/schema",
  "desktop_appearance": {
    "accent": "clear",
    "color": "#00000000",
    "show_peek": false,
    "show_line": false
  },
  "visible_window_appearance": {
    "enabled": true,
    "accent": "clear",
    "color": "#00000000",
    "show_peek": true,
    "show_line": false,
    "rules": {
      "window_class": {},
      "window_title": {},
      "process_name": {}
    }
  },
  "maximized_window_appearance": {
    "enabled": true,
    "accent": "acrylic",
    "color": "#00000000",
    "show_peek": true,
    "show_line": true,
    "rules": {
      "window_class": {},
      "window_title": {},
      "process_name": {}
    }
  },
  "start_opened_appearance": {
    "enabled": true,
    "accent": "clear",
    "color": "#F4F4F4C8",
    "show_peek": true,
    "show_line": true
  },
  "search_opened_appearance": {
    "enabled": true,
    "accent": "normal",
    "color": "#00000000",
    "show_peek": true,
    "show_line": true
  },
  "task_view_opened_appearance": {
    "enabled": true,
    "accent": "clear",
    "color": "#00000064",
    "show_peek": true,
    "show_line": true
  },
  "battery_saver_appearance": {
    "enabled": false,
    "accent": "opaque",
    "color": "#00000000",
    "show_peek": true,
    "show_line": false
  },
  "ignored_windows": {
    "window_class": [],
    "window_title": [],
    "process_name": []
  },
  "hide_tray": false,
  "disable_saving": false,
  "verbosity": "off"
}
```
详细设置如下：在桌面：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220505.jpg)打开任何窗口：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220507.jpg)窗口最大化：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220510.jpg)打开开始菜单：这里需要更改主题色：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220512.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220515.jpg)打开搜索菜单：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220517.jpg)打开任务视图：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220520.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220522.jpg)
