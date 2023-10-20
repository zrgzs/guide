---
title: 使用Hash结构缓存对象，如何解决缓存穿透问题？
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---


## 1、问题描述
了解了缓存穿透问题后，我就想着使用hash结构存储对象。如果用户请求的ID不存在的时候，需要在redis缓存中缓存NULL值，这样显然是不可行的，因为使用通过entities返回的类型任然是Map类型，不是null。

![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220406.jpg)

StringRedisTemplate会创建一个空Map，使用无法通过类似string结构的 ！= null 来判断数据是否在缓存中。

### 2、解决方案
我们可以在根据ID获取到的实体信息时不使用putAll()方法，我们直接使用put（key,hashKey,value）方法，我们缓存的hashKey和value信息为空字符串，这样我们在请求打到缓存上的时候虽然map不是为空，但是我们结合hutool工具包来转换后的实体信息中的所有属性均为NULL，这样我们就可以返回给前端实体不存在，转化后的实体属性如果不为NULL，则说明实体信息是存在的。例如：
```java
 @Override
    public Result queryById(Long id) {
        String shopKey = CACHE_SHOP_KEY + id;
        // 1、从redis缓存中获取商铺信息
        Map<Object, Object> shopMap = stringRedisTemplate.opsForHash().entries(shopKey);
        // 2、判断缓存是否命中 ,解决缓存穿透的问题上，shopMap可能为空的Map，或者是空的HashMap
        if (!shopMap.isEmpty()) {
            // 2.1 命中转化为shop对象 直接返回商铺信息
            Shop shop = BeanUtil.fillBeanWithMap(shopMap, new Shop(), false);
            // 2.1.1 如果shop中的所有属性均为null，那么代表没有这个店铺信息
            if (BeanUtil.isEmpty(shop)) {
                return Result.fail("店铺不存在");
            }
            // 2.1.2 否则返回转化后的商铺信息
            return Result.ok(shop);
        }
        // 2.2 未命中从数据库中查询商铺信息
        Shop shop = this.getById(id);
        // 2.2.1 判断数据库中是否有当前商铺的信息
        if (ObjectUtil.isEmpty(shop)) {
            // 2.2.1.2 数据库中无当前商铺信息，缓存空值到redis中
            stringRedisTemplate.opsForHash().put(shopKey, "", "");
            stringRedisTemplate.expire(shopKey, CACHE_NULL_TTL, TimeUnit.MINUTES);
            return Result.fail("店铺不存在");
        }
        // 2.2.1.1 数据库中存在当前商铺信息，缓存至redis,后返回
        Map<String, Object> sqlShopMap = BeanUtil.beanToMap(shop, new HashMap<>(),
                CopyOptions.create()
                        .setIgnoreNullValue(true)
                        .setFieldValueEditor((filedName, filedValue) ->
                                filedValue == null ? "" : filedValue.toString()
                        ));
        stringRedisTemplate.opsForHash().putAll(shopKey, sqlShopMap);
        stringRedisTemplate.expire(shopKey, CACHE_SHOP_TTL, TimeUnit.MINUTES);
        return Result.ok(shop);
    }
```
通过hutool的BeanUtil.isEmpty(Object obj)来判断实体的属性是否全部为空。![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220411.jpg)
