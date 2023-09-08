---
title: Redis取数据报错：org.springframework.data.redis.RedisSystemException_ Error in execution; nested exception is io.lettuce.core.RedisCom
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---


## 1、问题描述
我的代码是这样的：
```java
 /**
     * 缓存穿透，存储Hash
     *
     * @param keyPrefix  前缀
     * @param id         唯一ID
     * @param classType  存储类型
     * @param dbFallback 回调函数，查询数据库
     * @param cacheTtl   过期时间
     * @param unit       过期时间单位
     * @param <R>        返回值值类型
     * @param <K>        ID类型
     * @return R
     */
    public  <R, K> R queryWithPassThroughForHash(String keyPrefix, K id, Class<R> classType, Function<K, R> dbFallback, Long cacheTtl, TimeUnit unit) {
        String key = keyPrefix + id;
        // 1、从redis缓存中获取商铺信息
        Map<Object, Object> objectMap = stringRedisTemplate.opsForHash().entries(key);
        // 2、判断缓存是否命中 ,解决缓存穿透的问题上，shopMap可能为空的Map，或者是空的HashMap
        if (!objectMap.isEmpty()) {
            // 2.1 命中转化为shop对象 直接返回商铺信息
            R r = null;
            try {
                r = BeanUtil.fillBeanWithMap(objectMap, classType.newInstance(), false);
            } catch (InstantiationException | IllegalAccessException e) {
                throw new RuntimeException(e);
            }
            // 2.1.1 如果shop中的所有属性均为null，那么代表没有这个店铺信息
            return r;
            // 2.1.2 否则返回转化后的商铺信息
        }
        // 2.2 未命中从数据库中查询商铺信息
        R r = dbFallback.apply(id);
        // 2.2.1 判断数据库中是否有当前商铺的信息
        if (ObjectUtil.isEmpty(r)) {
            // 2.2.1.2 数据库中无当前商铺信息，缓存空值到redis中
            stringRedisTemplate.opsForHash().put(key, "", "");
            stringRedisTemplate.expire(key, CACHE_NULL_TTL, TimeUnit.MINUTES);
            return null;
        }
        // 2.2.1.1 数据库中存在当前商铺信息，缓存至redis,后返回
        Map<String, Object> sqlObjectMap = BeanUtil.beanToMap(r, new HashMap<>(),
                CopyOptions.create()
                        .setIgnoreNullValue(true)
                        .setFieldValueEditor((filedName, filedValue) ->
                                filedValue == null ? "" : filedValue.toString()
                        ));
        stringRedisTemplate.opsForHash().putAll(key, sqlObjectMap);
        stringRedisTemplate.expire(key, cacheTtl, unit);
        return r;
    }
```
但是在取数据的时候就报错:![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220358.jpg)

## 2、问题原因
原来是redis中在已经存储过String类型的了![image.png](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220401.jpg)在取数据转换成Map就会报错了呗。

## 3、解决方式：
①删除redis中已经存在的类型不一致的KEY,②转换成类型一致的呗
