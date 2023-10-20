---
title: SSM+Shiro+Redis+ 纯注解环境搭建
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 分布式存储社团一体化平台
author: wspstart
comment: false
---

首先根据业务拆分成 `Permission` 和 `Club` 两个模块。然后在父工程中添加依赖：

## 1. SpringWeb开发

### 1.1 添加依赖
```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>5.2.22.RELEASE</version>
</dependency>
<dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>${spring.version}</version>
        </dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-jdbc</artifactId>
    <version>${spring.version}</version>
</dependency>
```

### 1.2 添加容器启动配置类
```java
public class PermissionWebInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class[]{SpringMvcConfig.class};
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class[]{};
    }

    @Override
    protected String[] getServletMappings() {
        return new String[]{"/"};
    }
}
```
> 《Spring实战》
> AbstractAnnotationConfigDispatcherServletInitializer剖析
> 如果你坚持要了解更多细节的话，那就看这里吧。在Servlet 3.0环境中，容器会在类路径中查找实
> 现javax.servlet.servletContainerInitializer接口的类，如果能发现的话，就会用它来配置Servet容器。
> 
> Spring提供了这个接口的实现，名为SpringServletContainerInitializer，这个类反过来又会查找实现webApplicationInitializer的类并将配置的任务交给它们来完成。Spring 3.2引入了一个便利的WiebApplicationInitializer基础实现，也就是AbstractAnnotationConfigDispatcherServletInitializer。因为我们的Spittr-WebAppInitializer扩展了AbstractAnnotationConfig DispatcherServlet-Initializer(同时也就实现了webApplicationInitializer)，因此当部署到Servlet 3.0容器中的时候，容器会自动发现它，并用它来配置Servlet上下文。
> 
> 尽管它的名字很长，但是AbstractAnnotationConfigDispatcherServlet-Initializer使用起来很简便。在程序清单5.1中，SpittrwebAppInitializer重写了三个方法。


## 2. Lombok
```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.24</version>
</dependency>
```

## 3. MyBatis

### 3.1 依赖导入
```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.11</version>
</dependency>
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis-spring</artifactId>
    <version>3.0.1</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.31</version>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.2.12</version>
</dependency>
```

### 3.2 新增 properties 配置文件
```xml
url=jdbc:mysql://localhost:3306/club_manager_server
driverClassName=com.mysql.cj.jdbc.Driver
username=
password=
```

### 3.3 配置 MyBatisConfig
```java
@Configuration
public class MybatisConfig {

    @Autowired
    private DataSourceProperties dataSourceProperties;

    /**
     * @return 配置并返回数据源
     */
    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setUrl(dataSourceProperties.getUrl());
        dataSource.setDriverClassName(dataSourceProperties.getDriverClassName());
        dataSource.setUsername(dataSourceProperties.getUsername());
        dataSource.setPassword(dataSourceProperties.getPassword());
        return dataSource;
    }

    /**
     *
     * @return 配置 SqlSessionFactory 对象
     * @throws Exception
     */
    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception  {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource());
        sessionFactory.setConfigLocation(new ClassPathResource("mybatis-config.xml"));
        return sessionFactory.getObject();
    }

    /**
     *
     * @param dataSource 数据源对象
     * @return 返回事务管理器
     */
    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);

    }

    @Bean
    public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }
}
```

## 4. Junit5

### 4.1 依赖导入
```xml
 <!-- Junit5 -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-api</artifactId>
    <version>${junit5.version}</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-engine</artifactId>
    <version>${junit5.version}</version>
    <scope>test</scope>
</dependency>
```

### 4.2 使用示例

报错，结束项目开发。

【参考文章】[实例演示如何以全注解的方式搭建SSM（Spring+SpringMVC+Mybatis）项目_將晨的博客-CSDN博客](https://blog.csdn.net/Follower_JC/article/details/107105691)[Spring中Resource（资源）的获取_詹姆斯哈登的博客-CSDN博客_spring 获取resource](https://blog.csdn.net/haydenyu/article/details/76427663)
