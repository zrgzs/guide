---
title: JDK 的动态代理之源码解析
date: 2023-09-07 17:59:14
categories:
- java基础
- SE
author: lx0815
comment: false
---

废话不多说，上案例代码：
```java
public class Main {

    public static void main(String[] args) {
        // 先不用管，后面会提到
        System.setProperty("sun.misc.ProxyGenerator.saveGeneratedFiles", "true");
        // 创建一个代理类，该代理类由 Main.class.getClassLoader() 获取到的类加载器加载
        // 并且实现 F 接口
        // 该代理类的方法调用都将被转发到 匿名内部类，然后打印方法名称
        F f = (F) Proxy.newProxyInstance(
                Main.class.getClassLoader(),
                new Class[]{F.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println(method.getName());
                        return null;
                    }
                }
        );
        f.m();
    }

}
interface F {
    void m();
}
```
首先通过第9行进入 `java.lang.reflect.Proxy#newProxyInstance`
```java
/**
 * 返回指定接口的代理类实例，该代理类将方法调用调度到指定的调用处理程序。
 * Proxy.newProxyInstanceIllegalArgumentException投掷的原因与投掷的原因Proxy.getProxyClass相同。
 * 参数：loader – 用于定义代理类的类加载器 
 *       interfaces – 要实现的代理类的接口列表 
 *       h – 用于将方法调用调度到
 * 返回：一个代理实例，具有由指定的类装入器定义并实现指定接口的代理类的指定调用处理程序
 * 抛出：IllegalArgumentException – 如果违反了对可能传递到 getProxyClass 的参数的任何限制
 *       SecurityException – 如果安全经理 S 在场并且满足以下任何条件：
 *          · 给定 loader 的 is null 和调用方的类加载器不是 null ，并且调用 with s.checkPermission RuntimePermission("getClassLoader") permission 拒绝访问;
 *          · 对于每个代理接口，调用方的类装入器与 的intf类装入器的祖先不同，intf并且调用 拒绝s.checkPackageAccess()访问 intf;
 *          · 任何给定的代理接口都是非公共的，调用方类与非公共接口不在同一 运行时包 中，并且调用 with s.checkPermission ReflectPermission("newProxyInPackage.{package name}") permission 会拒绝访问。
 *       NullPointerException– 如果数组参数或其任何元素是 ，或者如果interfaces调用处理程序h是 ，是nullnull
 */
@CallerSensitive
    public static Object newProxyInstance(ClassLoader loader,
                                          Class<?>[] interfaces,
                                          InvocationHandler h)
        throws IllegalArgumentException
    {
        // ...
    
        /*
         * 查找或生成指定的代理类。说人话：生成代理类，如果代理类存在，那就不生成了
         */
        Class<?> cl = getProxyClass0(loader, intfs);

        /*
         * 使用指定的调用处理程序调用其构造函数。说人话：通过 Class 对象调用构造方法构造代理类对象
         */
        try {
        	// ...
            final Constructor<?> cons = cl.getConstructor(constructorParams);
        	// ...
            return cons.newInstance(new Object[]{h});
        } catch (IllegalAccessException|InstantiationException e) {
            // ...
        } catch (InvocationTargetException e) {
            // ...
        } catch (NoSuchMethodException e) {
            // ...
        }
    }
```
```java
/**
 * 生成代理类。在调用此函数之前，必须调用 checkProxyAccess 方法以执行权限检查。
 */
private static Class<?> getProxyClass0(ClassLoader loader,
                                           Class<?>... interfaces) {
    	// ...

        // 如果由给定加载器定义的代理类实现给定的接口存在，这将只返回缓存的副本;否则，它将通过 ProxyClassFactory 创建代理类.
        // 说人话：这里可以看出，一个代理类是由 类加载器 和 代理类需要实现的接口 共同决定的。
    	// 所以这里的意思就是判断这个类加载器和接口的组合，有没有创建过代理类，如果创建过，那么就存在缓存，那就直接从缓存取。
        return proxyClassCache.get(loader, interfaces);
    }
```
通过查看 `proxyClassCache` 这个属性如下：
```java
private static final WeakCache<ClassLoader, Class<?>[], Class<?>>
        proxyClassCache = new WeakCache<>(new KeyFactory(), new ProxyClassFactory());
```
很容易能够看出，如果代理类不存在，那么会调用 `ProxyClassFactory`工厂来生成代理类。通过该类的文档也能说明这一点。查看该类源码发现，该类实现了 `BiFunction` ，也就是说我们的目标更明确了，那就是：生成代理类的实现就在 ：`java.lang.reflect.Proxy.ProxyClassFactory#apply`
```java
@Override
public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {
    // ...

    /*
     * 生成指定的代理类。
     * 到了这里，终于到了最关键的地方。因为这个方法的返回值，就是代理类的 class 对象的字节数组了。
     */
    byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
        proxyName, interfaces, accessFlags);
    try {
        return defineClass0(loader, proxyName,
                            proxyClassFile, 0, proxyClassFile.length);
    } catch (ClassFormatError e) {
        // ...
    }
}
```
```java
public static byte[] generateProxyClass(final String var0, Class<?>[] var1, int var2) {
        ProxyGenerator var3 = new ProxyGenerator(var0, var1, var2);
        // 生成类文件，这里面就不再追了，这里面就是手写代理类的字节码到字节数组缓冲区中，然后将其返回了。好奇的可以自行了解。
        final byte[] var4 = var3.generateClassFile();
        // 如果需要保存文件，那么就将文件进行存储。默认为 false。
        // 可以通过最开始那个 main 方法的 line 5 开启。
        if (saveGeneratedFiles) {
            AccessController.doPrivileged(new PrivilegedAction<Void>() {
                public Void run() {
                    try {
                        int var1 = var0.lastIndexOf(46);
                        Path var2;
                        if (var1 > 0) {
                            Path var3 = Paths.get(var0.substring(0, var1).replace('.', File.separatorChar));
                            Files.createDirectories(var3);
                            var2 = var3.resolve(var0.substring(var1 + 1, var0.length()) + ".class");
                        } else {
                            var2 = Paths.get(var0 + ".class");
                        }

                        Files.write(var2, var4, new OpenOption[0]);
                        return null;
                    } catch (IOException var4x) {
                        throw new InternalError("I/O exception saving generated file: " + var4x);
                    }
                }
            });
        }

        return var4;
    }
```
最后来看看生成的 class 文件吧。

- class 文件会生成在和项目根目录同级的com包下，需要自行反编译。
```java
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.d.jdbc01;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.lang.reflect.UndeclaredThrowableException;

final class $Proxy0 extends Proxy implements F {
    private static Method m1;
    private static Method m2;
    private static Method m0;
    private static Method m3;

    public $Proxy0(InvocationHandler var1) throws  {
        super(var1);
    }

    public final boolean equals(Object var1) throws  {
        try {
            return (Boolean)super.h.invoke(this, m1, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }

    public final String toString() throws  {
        try {
            return (String)super.h.invoke(this, m2, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final int hashCode() throws  {
        try {
            return (Integer)super.h.invoke(this, m0, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final void m() throws  {
        try {
            super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", Class.forName("java.lang.Object"));
            m2 = Class.forName("java.lang.Object").getMethod("toString");
            m0 = Class.forName("java.lang.Object").getMethod("hashCode");
            m3 = Class.forName("com.d.jdbc01.F").getMethod("m");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
}

```
现在就能理解，为什么调用接口的方法之后，会被转发到我们实现了 `InvocationHandler` 接口的对象中了，因为代理类的每一个方法都在 `h.invoke(..)` ，而 h 来自于 `Proxy` 父类，也就是我们传入的 `InvocationHandler` 接口的实现类。
