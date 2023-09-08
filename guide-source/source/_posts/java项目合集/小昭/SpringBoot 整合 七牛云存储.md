---
title: SpringBoot 整合 七牛云存储
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---


# SpringBoot 整合 七牛云存储

七牛云的注册及配置这里就不赘述了。


## 0. 七牛云存储 JavaSDK 官方文档

[Java SDK_SDK 下载_对象存储 - 七牛开发者中心 (qiniu.com)](https://developer.qiniu.com/kodo/1239/java)


## 1. 引入依赖

```xml
<dependency>
  <groupId>com.qiniu</groupId>
  <artifactId>qiniu-java-sdk</artifactId>
  <version>[7.7.0, 7.10.99]</version>
</dependency>
```

> 这里的`version`指定了一个版本范围，每次更新`pom.xml`的时候会尝试去下载`7.7.x`版本中的最新版本，你可以手动指定一个固定的版本。



## 2. 在环境变量中配置 AccessKey 和 SecretKey

不知道如何配置的参见[SpringBoot 环境变量管理](http://awind.space/archives/1671462101135)


## 3. 根据文档中需要填写的配置为模板创建 QiNiuProperties 类

```java
package com.xiaozhao.xiaozhaoserver.service.configProp;

import lombok.Data;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * @description: 域名相关：<a href="https://developer.qiniu.com/kodo/1671/region-endpoint-fq">域名</a>
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-11-17 6:15:13
 * @modify:
 */

@Data
@Component
public class QiNiuProperties {

    /**
     * 存储桶名称
     */
    @Value("${qiniu.bucket}")
    private String bucket;

    /**
     * 地区描述，例如 huadongzhejiang2
     */
    @Value("${qiniu.region}")
    private String region;

    /**
     * 七牛云中配置的访问域名
     */
    @Value("${qiniu.domain}")
    private String domain;

    /**
     * 图片存储的根路径
     */
    @Value("${qiniu.rootDirectory:#{ 'xiaozhao/person-face/' }}")
    private String rootDirectory;

    /**
     * 最大重试次数
     */
    @Value("${qiniu.retryMaxCount:#{ 3 }}")
    private int retryMaxCount;

    /**
     * 加速域名（见官网，不知道有啥用）
     */
    @Value("${qiniu.accelerateUploadDomain}")
    private String accelerateUploadDomain;

    /**
     * 访问公钥，从环境变量获取
     */
    @Value("${XIAO_ZHAO_DEFAULT_QINIU_ACCESS_KEY}")
    private String accessKey;

    /**
     * 密钥，从环境变量获取
     */
    @Value("${XIAO_ZHAO_DEFAULT_QINIU_SECRET_KEY}")
    private String secretKey;


    /**
     * 手动复写该方法是为了确保不出现两个连续的斜杠
     */
    public String getDomain() {
        if (! StringUtils.isBlank(domain) && !domain.endsWith("/")) {
            domain += '/';
        }
        return domain;
    }

    /**
     * 手动复写该方法是为了确保不出现两个连续的斜杠
     */
    public String getRootDirectory() {
        if (! StringUtils.isBlank(rootDirectory) && rootDirectory.startsWith("/")) {
            rootDirectory = rootDirectory.substring(1);
        }
        if (! StringUtils.isBlank(rootDirectory) && !rootDirectory.endsWith("/")) {
            rootDirectory += '/';
        }
        return rootDirectory;
    }
}
```


## 4. 新建 QiNiuConfig 配置类

```java
package com.xiaozhao.xiaozhaoserver.service.config.qiniu;

import com.qiniu.storage.UploadManager;
import com.qiniu.util.Auth;
import com.xiaozhao.xiaozhaoserver.service.configProp.QiNiuProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.security.NoSuchProviderException;

/**
 * @description:
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-11-16 23:25:31
 * @modify:
 */

@Slf4j
@Configuration
public class QiNiuConfig {

    private QiNiuProperties qiNiuProperties;
    @Autowired
    public void setQiNiuProperties(QiNiuProperties qiNiuProperties) {
        this.qiNiuProperties = qiNiuProperties;
    }

    /**
     * 配置空间的存储区域
     */
    @Bean
    public com.qiniu.storage.Configuration qiNiuConfiguration() {
        try {
            log.info("准备开始读取 QiNiuProperties: ");
            com.qiniu.storage.Configuration configuration = new com.qiniu.storage.Configuration(RegionFactoryBuilder
                    .builder(qiNiuProperties.getRegion())
                    .createRegion());

            configuration.retryMax = qiNiuProperties.getRetryMaxCount();
            return configuration;
        } catch (NoSuchProviderException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 构建一个七牛上传工具实例
     */
    @Bean
    public UploadManager uploadManager(com.qiniu.storage.Configuration configuration) {
        return new UploadManager(configuration);
    }

    /**
     * 认证信息实例
     */
    @Bean
    public Auth auth() {
        return Auth.create(qiNiuProperties.getAccessKey(), qiNiuProperties.getSecretKey());
    }
}
```


### region 的处理

region 在配置文件中写的是 字符串，而要根据配置文件中的字符串找到相应的方法，肯定不能用大量的 `if... else if... else` 。所以这里使用工厂模式，具体哪一种我也不造。

首先看一下类图

![](https://raw.githubusercontent.com/zrgzs/images/main/images/20230907220304.jpg)

`RegionFactory` 中又两个抽象方法：

- `boolean support(String region);` 
   - 判断该工厂是否支持创建描述为 `region` 的 `Region` 对象
- `Region createRegion();` 
   - 创建 `Region` 对象

其七个子类工厂均实现其方法，示例如下：

```java
package com.xiaozhao.xiaozhaoserver.service.config.qiniu.impl;

import com.qiniu.storage.Region;
import com.xiaozhao.xiaozhaoserver.service.config.qiniu.RegionFactory;

/**
 * @description:
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-11-17 9:36:33
 * @modify:
 */

public class HuabeiRegionFactory implements RegionFactory {

    private static final String SUPPORT_REGION = "huabei";

    @Override
    public boolean support(String region) {
        return SUPPORT_REGION.equalsIgnoreCase(region);
    }

    @Override
    public Region createRegion() {
        return Region.huabei();
    }
}
```

在 `RegionFactoryBuilder` 中，通过 `ServiceLoader` 类加载 `RegionFactory` 的实现类，作为服务提供者，然后遍历其所有被加载的实现类以找到支持该地区的一个 工厂，找不到将抛出异常。

```java
package com.xiaozhao.xiaozhaoserver.service.config.qiniu;

import java.security.NoSuchProviderException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.ServiceLoader;

/**
 * @description:
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-11-17 9:03:35
 * @modify:
 */

public class RegionFactoryBuilder {

    private static final ServiceLoader<RegionFactory> regionFactories = ServiceLoader.load(RegionFactory.class);

    private static final Map<String, RegionFactory> factoryMap = new HashMap<>();

    private RegionFactoryBuilder() {
    }

    public static RegionFactory builder(String region) throws NoSuchProviderException {
        RegionFactory f = factoryMap.get(region);
        if (Objects.nonNull(f)) return f;
        for (RegionFactory factory : regionFactories) {
            if (factory.support(region)) {
                factoryMap.put(region, factory);
                return factory;

            }
        }
        throw new NoSuchProviderException("Region 配置错误，没有程序能够支持 " + region);
    }
}
```


## . 新建 QiNiuService 接口，并创建其实现类

编写一个保存 `List<MultipartFile>` 的方法如下：

```java
@Override
    public List<String> saveMultipartFileList(List<MultipartFile> fileList, String directory) {
        // 防止 NPE
        directory = Objects.isNull(directory) ? "" : directory;
        // 图片保存路径
        StringBuilder path;
        // 响应对象
        com.qiniu.http.Response response;
        // 图片访问路径
        String accessPath = null;
        // 所有图片的访问路径
        List<String> accessPathList = new LinkedList<>();
        try {
            StringBuilder sb = new StringBuilder();
            for (MultipartFile multipartFile : fileList) {
                // 获取文件名，主要用于获取图片后缀
                String fileName = multipartFile.getOriginalFilename();
                // 使用 UUID 生成文件名，与目录拼接得到保存路径
                path = sb.append(directory).append(UUID.randomUUID()).append('.').append(StringUtils.substringAfterLast(fileName, "."));
                // 开始上传文件
                response = uploadManager.put(multipartFile.getBytes(), path.toString(), getUploadToken());

                if (!response.isOK()) {
                    log.error(String.format("本次上传信息：\n文件名：%s\n文件大小：%s\n文件保存路径：%s",
                            fileName, multipartFile.getSize(), path));
                    throw new RuntimeException("上传文件失败");
                }
                sb.delete(0, sb.length());
                // 得到访问路径
                accessPath = sb.append("http://").append(qiNiuProperties.getDomain()).append(path).toString();
                accessPathList.add(accessPath);
                sb.delete(0, sb.length());
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        log.debug("商品图片上传成功，访问路径为：" + accessPath);
        return accessPathList;
    }
```
