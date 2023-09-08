---
title: 使用StringRedisTemplate报错：java.lang.ClassCastException_ java.lang.Long cannot be cast to java.lang.String
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---


## 1、问题描述
我在使用StringRedisTemplate来存储对象信息的时候，我使用的是hash结构，在运行的同时报错：
```
java.lang.ClassCastException: java.lang.Long cannot be cast to java.lang.String
at org.springframework.data.redis.serializer.StringRedisSerializer.serialize(StringRedisSerializer.java:36) ~[spring-data-redis-2.7.12.jar:2.7.12]
at org.springframework.data.redis.core.AbstractOperations.rawHashValue(AbstractOperations.java:186) ~[spring-data-redis-2.7.12.jar:2.7.12]
at org.springframework.data.redis.core.DefaultHashOperations.putAll(DefaultHashOperations.java:209) ~[spring-data-redis-2.7.12.jar:2.7.12]
at com.hmdp.service.impl.UserServiceImpl.login(UserServiceImpl.java:97) ~[classes/:na]
at com.hmdp.service.impl.UserServiceImpl$$FastClassBySpringCGLIB$$9cac0aa5.invoke(<generated>) ~[classes/:na]
at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218) ~[spring-core-5.3.27.jar:5.3.27]
at org.springframework.aop.framework.CglibAopProxy.invokeMethod(CglibAopProxy.java:386) ~[spring-aop-5.3.27.jar:5.3.27]
at org.springframework.aop.framework.CglibAopProxy.access$000(CglibAopProxy.java:85) ~[spring-aop-5.3.27.jar:5.3.27]
at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:704) ~[spring-aop-5.3.27.jar:5.3.27]
at com.hmdp.service.impl.UserServiceImpl$$EnhancerBySpringCGLIB$$c7a7fed4.login(<generated>) ~[classes/:na]
```
意思是无法将Long类型转换为String类型，这是为什么呢？

## 2、出错原因：
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220415.jpg)

## 3、如何解决？

### 方案一：可以不使用StringRedisTemplate。使用RedisTemplate<key,value>。

### 方案二：不使用hutool工具包，自己创建新的Map，类型都是String类型。

### 方案三：继续使用hutool工具包，并转换一下类型。
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220420.jpg)在CopyOptions中有个方法用于转换类型的:

![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220424.jpg)

修改后的代码：

```java
@Override
    public Result login(LoginFormDTO loginForm, HttpSession session) {
        // 1、校验手机号、验证码
        if (!isPhoneInvalid(loginForm.getPhone())) {
            return Result.fail("手机号格式不正确");
        }
        String code = stringRedisTemplate.opsForValue().get(LOGIN_CODE_KEY + loginForm.getPhone());
        if (code == null || !code.equals(loginForm.getCode())) {
            return Result.fail("验证码不正确");
        }
        // 2、 根据手机号查询用户
        User user = getOne(new LambdaQueryWrapper<User>().eq(User::getPhone, loginForm.getPhone()));
        // 2.1 用户是否存在，不存在则创建新用户
        if (user == null) {
            user = createUserWithPhone(loginForm.getPhone());
        }
        // 3. 生成token
        String token = UUID.randomUUID().toString(true);
        //4. 保存用户信息到redis
        //4.1 将用户转为hash格式
        UserDTO userDTO = BeanUtil.copyProperties(user, UserDTO.class);
        //4.2存储 ，转换为map的时候stringRedisTemplate要求必须全部都是String类型的
        Map<String, Object> userMap = BeanUtil.beanToMap(userDTO, new HashMap<>(),
                CopyOptions.create()
                        .setIgnoreNullValue(true)
                        .setFieldValueEditor((filedName, filedValue) -> filedValue.toString()));
        String tokenKey = LOGIN_USER_KEY + token;
        stringRedisTemplate.opsForHash().putAll(tokenKey, userMap); // 存map是不允许存有效期的，我需要先存后设置有效期 StringRedisTemplate 要求存储的值必须都是String类型的
        // 设置有效期
        stringRedisTemplate.expire(tokenKey, LOGIN_USER_TTL, TimeUnit.MINUTES);
        //5、返回token
        return Result.ok(token);
    }
```
