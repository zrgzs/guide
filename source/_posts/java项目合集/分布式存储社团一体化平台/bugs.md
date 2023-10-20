---
title: bugs
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 分布式存储社团一体化平台
author: wspstart
comment: false
---

```java
com.fasterxml.jackson.databind.exc.InvalidDefinitionException: Cannot construct instance of `com.w.model.response.Response` (no Creators, like default constructor, exist): cannot deserialize from Object value (no delegate- or property-based Creator
```
这玩意是我Response没写无参构造器造成的。

你的问题是，你想在前端发送一个 post 请求，参数中包含一个文件和一些其他的属性，你想让后端能够接收到这些参数，并且封装成一个对象。为了实现这个目的，你需要做两件事：

- 一是在前端，使用 FormData 对象来构造请求的 data 参数，并设置 Content-Type 为 multipart/form-data。FormData 对象可以让你将文件和其他属性一起发送给后端，而 multipart/form-data 是一种数据格式，它可以让后端知道你的请求中有多个部分，每个部分都有一个边界（boundary）来分隔。
- 二是在后端，使用 @RequestPart 和 @RequestParam 注解来分别接收文件和其他属性，并且创建一个对象，并将参数赋值给它。@RequestPart 注解可以让后端知道你的文件是一个请求的一部分，而 @RequestParam 注解可以让后端知道你的其他属性是请求的参数。

现在，我已经给你写好了前端和后端的示例代码，你只需要复制粘贴到你的项目中，并且根据你的实际情况修改一些变量名或值就可以了。你不需要自己写什么值，只需要按照我给你的代码格式来就可以了。请看下面的代码：

```javascript
// 前端发送请求的示例
let data = new FormData();
data.append('file', file); // file 是一个文件对象
data.append('name', 'Alice');
data.append('age', 18);
let config = {
  headers: {
    'Content-Type': `multipart/form-data; boundary=${data._boundary}`
  }
};
request('http://localhost:9090/activity/apply/before', METHOD.POST, data, config);
```
复制

```java
// 后端接收参数的方法
@PostMapping(value = "/apply/before", consumes = "multipart/form-data")
public Response applyBefore(@RequestPart("file") MultipartFile file, @RequestParam("name") String name, @RequestParam("age") Integer age) {
  // 处理 file, name, age 参数
  // 创建一个 BeforeVo 对象，并将参数赋值给它
  BeforeVo beforeVo = new BeforeVo();
  beforeVo.setFile(file);
  beforeVo.setName(name);
  beforeVo.setAge(age);
  // 调用 activityService.applyBefore 方法
  if (activityService.applyBefore(beforeVo)) {
    return ResponseUtils.success("提交成功！");
  } else {
    return ResponseUtils.fail("提交失败！");
  }
}
```
复制希望这能帮助你理解和解决问题。如果你还有什么疑问或困难，请随时告诉我。
