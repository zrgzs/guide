---
title: Hutool的BeanUtil.copyProperties的ignoreNullValue不生效
date: 2023-09-07 17:59:14
categories:
- 报错信息
author: wspstart
comment: false
---


## 1、问题描述
在学习redis做黑马点评项目的时候，有个是根据ID获取商铺信息的，我使用的是hash结构，需要将实体类转化为map结构，我使用的是hutool工具类提供的BeanUtil，以下是我的代码：
```java
    @Override
    public Result queryById(Long id) {
        String shopKey = CACHE_SHOP_KEY + id;
        // 1、从redis缓存中获取商铺信息
        Map<Object, Object> shopMap = stringRedisTemplate.opsForHash().entries(shopKey);
        // 2、判断缓存是否命中
        if (!shopMap.isEmpty()) {
            // 2.1命中直接返回商铺信息
            Shop shop = BeanUtil.fillBeanWithMap(shopMap, new Shop(), false);
            return Result.ok(shop);
        }
        // 2.2 未命中从数据库中查询商铺信息
        Shop shop = this.getById(id);
        // 2.2.1 判断数据库中是否有当前商铺的信息
        if (!ObjectUtil.isEmpty(shop)) {
            // 2.2.1.1 数据库中存在当前商铺信息，缓存至redis,后返回
            Map<String, Object> sqlShopMap = BeanUtil.beanToMap(shop, new HashMap<>(),
                    CopyOptions.create()
                            .setIgnoreNullValue(true)
                            .setFieldValueEditor((filedName, filedValue) -> filedValue.toString()));
            stringRedisTemplate.opsForHash().putAll(shopKey, sqlShopMap);
            stringRedisTemplate.expire(shopKey, CACHE_SHOP_TTL, TimeUnit.MINUTES);

        } else {
            // 2.2.1.2 数据库中无当前商铺信息，缓存空值到redis中
            stringRedisTemplate.opsForHash().putAll(shopKey, new HashMap<>());
        }
        return Result.ok(shop);
    }
```
可以看到明明是setIgnoreNullValue(true)设置了忽略Null值，但是还是会报空指针异常：
```latex
	java.lang.NullPointerException: null
	at com.hmdp.service.impl.ShopServiceImpl.lambda$queryById$0(ShopServiceImpl.java:61) ~[classes/:na]
	at cn.hutool.core.bean.copier.CopyOptions.editFieldValue(CopyOptions.java:258) ~[hutool-all-5.7.17.jar:na]
	at cn.hutool.core.bean.copier.BeanCopier.lambda$beanToMap$1(BeanCopier.java:233) ~[hutool-all-5.7.17.jar:na]
	at java.util.LinkedHashMap$LinkedValues.forEach(LinkedHashMap.java:608) ~[na:1.8.0_371]
	at cn.hutool.core.bean.BeanUtil.descForEach(BeanUtil.java:182) ~[hutool-all-5.7.17.jar:na]
	at cn.hutool.core.bean.copier.BeanCopier.beanToMap(BeanCopier.java:195) ~[hutool-all-5.7.17.jar:na]
	at cn.hutool.core.bean.copier.BeanCopier.copy(BeanCopier.java:106) ~[hutool-all-5.7.17.jar:na]
	at cn.hutool.core.bean.BeanUtil.beanToMap(BeanUtil.java:690) ~[hutool-all-5.7.17.jar:na]
	at com.hmdp.service.impl.ShopServiceImpl.queryById(ShopServiceImpl.java:58) ~[classes/:na]
```

## 2、出错原因
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220344.jpg)1、这是由于setFieldValueEditor优先级要高于ignoreNullValue导致前者首先被触发，因此出现空指针问题。需要在setFieldValueEditor中也需要判空。2、这么设计的原因主要是，如果原值确实是null，但是你想给一个默认值，在此前过滤掉就不合理了，而你的值编辑后转换为null，后置的判断就会过滤掉。

## 3、如何解决？
 简单来说就是在setFieldValueEditor方法的时候,也进行判断一下空值![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220350.jpg)这样判空一下就可以了。
