---
title: SpringBoot 整合 腾讯云 API
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---


# SpringBoot 整合 腾讯云 API

此处假设腾讯云方面的配置大家都配置完毕了，下面直接开始与代码相关的。


## 0. 腾讯云 SDK 文档

[Java-SDK 中心-腾讯云 (tencent.com)](https://cloud.tencent.com/document/sdk/Java)


## 1. 引入依赖

```xml
<dependency>
     <groupId>com.tencentcloudapi</groupId>
     <artifactId>tencentcloud-sdk-java</artifactId>
     <!-- go to https://search.maven.org/search?q=tencentcloud-sdk-java and get the latest version. -->
     <!-- 请到https://search.maven.org/search?q=tencentcloud-sdk-java查询所有版本，最新版本如下 -->
     <version>3.1.322</version>
</dependency>
```


## 2. 在环境变量中配置 secretId 和 secretKey

不知道如何配置的参见 [SpringBoot 环境变量管理](http://awind.space/archives/1671462101135)


## 3. 根据调用文档中的参数，创建 TencentApiPublicProperties 类

```java
package com.xiaozhao.xiaozhaoserver.service.configProp;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * @description: 腾讯云接口的公共请求参数
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-12-08 9:42:33
 * @modify:
 */

@Data
@Component
public class TencentApiPublicProperties {

    @Value("${tencent.domainName}")
    private String domainName;

    @Value("${tencent.region}")
    private String region;

    @Value("${XIAO_ZHAO_DEFAULT_TENCENT_SECRET_ID}")
    private String secretId;

    @Value("${XIAO_ZHAO_DEFAULT_TENCENT_SECRET_KEY}")
    private String secretKey;

}
```


## 新建一个工具类用于请求 API

为什么不像配置七牛云的时候一样创建一个 `Service` ？腾讯云接口太多了，每个接口都来一个 `Service` 的话太多类了。但是感觉实际中的话，还是需要创建一个`Service` 的吧，调接口的时候

```java
package com.xiaozhao.xiaozhaoserver.service.utils;

import com.tencentcloudapi.common.AbstractModel;
import com.tencentcloudapi.common.Credential;
import com.tencentcloudapi.common.exception.TencentCloudSDKException;
import com.tencentcloudapi.common.profile.ClientProfile;
import com.tencentcloudapi.iai.v20200303.IaiClient;
import com.xiaozhao.xiaozhaoserver.service.configProp.TencentApiPublicProperties;
import com.xiaozhao.xiaozhaoserver.service.exception.BadParameterException;
import lombok.extern.slf4j.Slf4j;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * @description:
 * @author: Ding
 * @version: 1.0
 * @createTime: 2022-12-08 8:59:48
 * @modify:
 */

@Slf4j
public class TencentApiUtils {

    private TencentApiUtils() {}

    private static List<Method> iaiClientMethodList;

    /*
      加载该类的所有请求方法
     */
    static {
        log.info("开始添加 iaiClient method");
        iaiClientMethodList = new LinkedList<>();
        Method[] methods = IaiClient.class.getMethods();
        iaiClientMethodList = Arrays.asList(methods);
        log.info("添加了 " + methods.length + " 个 iaiClient method");
    }

    /**
     * 向腾讯云接口提交请求
     * @param abstractModel 请求模型
     * @param responseClass 响应类的类对象
     * @param tencentApiPublicProperties 腾讯云接口的相关请求参数
     * @return 返回请求得到的响应对象
     * @param <T> 响应对象
     * @throws TencentCloudSDKException 调用腾讯云接口时抛出异常
     */
    @SuppressWarnings("unchecked")
    public static <T> T executeIciClientRequest(AbstractModel abstractModel, Class<T> responseClass,
                                                   TencentApiPublicProperties tencentApiPublicProperties) throws TencentCloudSDKException {

        try {
            // 实例化一个认证对象，入参需要传入腾讯云账户secretId，secretKey,此处还需注意密钥对的保密
            // 密钥可前往https://console.cloud.tencent.com/cam/capi网站进行获取
            Credential cred = new Credential(tencentApiPublicProperties.getSecretId(),
                    tencentApiPublicProperties.getSecretKey());
            // 实例化一个client选项，可选的，没有特殊需求可以跳过
            ClientProfile clientProfile = new ClientProfile();
            clientProfile.setDebug(true);
            // 实例化要请求产品的client对象,clientProfile是可选的
            IaiClient client = new IaiClient(cred, tencentApiPublicProperties.getRegion(), clientProfile);

            // 返回的resp是一个CreatePersonResponse的实例，与请求对象对应
            for (Method method : iaiClientMethodList) {
                if (method.getParameters()[0].getType() == abstractModel.getClass()) {
                    Object responseObj = method.invoke(client, abstractModel);
                    if (responseObj.getClass() == responseClass) {
                        return (T) responseObj;
                    } else {
                        // 删除刚刚创建的东西
                        // 此处就不做实现了，主要是不会
                        throw new BadParameterException(String.format("方法 %s 的返回值为 %s ，而收到的类型为 %s",
                                method.getName(), method.getReturnType(), responseClass));
                    }
                }
            }
        } catch (InvocationTargetException e) {
            throw (TencentCloudSDKException) e.getTargetException();
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
        throw new RuntimeException("IaiClient 中没用可用的方法以发送 " + abstractModel);
    }
}
```


## 优化：

- 
可以改成一个服务类，更符合其身份。

- 
可以在这里面统一的打印日志信息，处理异常

