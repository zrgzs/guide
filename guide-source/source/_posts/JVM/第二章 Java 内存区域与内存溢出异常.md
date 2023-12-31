---
title: 第二章 Java 内存区域与内存溢出异常
date: 2023-09-07 17:59:14
categories:
- JVM
author: lx0815
comment: false
---


# 2.2 运行时数据区
![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220316.jpg)

# 2.2.1 程序计数器
> 是当前线程所执行的字节码的行号指示器，字节码解释器通过改变这个计数器的值来选取下一条需要执行的字节码指令，它是程序控制流的指示器，分支、循环、跳转、异常处理、线程恢复等基础功能都需要依赖这个计数器来完成。

- 记录当前代码跑到哪里了
> 此内存区域是唯一一个在《Java虚拟机规范》中没有规定任何`OutOfMemoryError`情况的区域。


# 2.2.2 虚拟机栈
> 生命周期与线程相同

- 启动一个新线程的时候会创建一个虚拟机栈，同时关闭一个线程也将销毁这个虚拟机栈
> 虚拟机栈描述的是Java方法执行的线程内存模型：每个方法被执行的时候，Java虚拟机都会同步创建一个栈帧（Stack Frame）用于存储局部变量表、操作数栈、动态连接、方法出口等信息。每一个方法被调用直至执行完毕的过程，就对应着一个栈帧在虚拟机栈中从入栈到出栈的过程。

- 每调用一个方法，虚拟机栈里就会新建一个栈帧来存储该方法的各项信息
> 经常有人把Java内存区域笼统地划分为堆内存（Heap）和栈内存（Stack），这种划分方式直接继承自传统的C、C++程序的内存布局结构，在Java语言里就显得有些粗糙了，实际的内存区域划分要比这更复杂。不过这种划分方式的流行也间接说明了程序员最关注的、与对象内存分配关系最密切的区域是“堆和“栈”两块。其中，“堆”在稍后笔者会专门讲述，而“栈”通常就是指这里讲的虚拟机栈，或者更多的情况下只是指虚拟机栈中局部变量表部分。

- 内存不止栈和堆

### 2.2.2.1 局部变量表
> 存放了编译期可知的各种Java虚拟机基本数据类型（`boolean`、`byte`、`char`、`short`、`int`、 `float`、`long`、`double`）、对象引用（reference类型，它并不等同于对象本身，可能是一个指向对象起始地址的引用指针，也可能是指向一个代表对象的句柄或者其他与此对象相关的位置）和returnAddress类型（指向了一条字节码指令的地址）。

- 基本类型
- 对象引用
- 返回地址
> 这些数据类型在局部变量表中的存储空间以局部变量槽（Slot）来表示，其中64位长度的`long`和`double`类型的数据会占用两个变量槽，其余的数据类型只占用一个。局部变量表所需的内存空间在编译期间完成分配，当进入一个方法时，这个方法需要在栈帧中分配多大的局部变量空间是完全确定的，在方法运行期间不会改变局部变量表的大小。

- long和double占用两个槽，其余一个槽。槽的大小由虚拟机决定
- 方法需要在栈帧中分配多大的局部变量空间是完全确定的
- 在方法运行期间不会改变局部变量表的大小


### 为什么栈帧大小可以完全确定？
因为Java中变量的类型分为基本类型和引用类型，而每一种类型所占用的槽的数量是确定的，所以在编译器即可确定一个方法中到底需要多少个槽。

> 如果线程请求的栈深度大于虚拟机所允许的深度，将抛出`StackOverflowError`异常；如果Java虚拟机栈容量可以动态扩展，当栈扩展时无法申请到足够的内存会抛出`OutOfMemoryError`异常。


> HotSpot虚拟机的栈容量是不可以动态扩展的，以前的Classic虚拟机倒是可以。所以在HotSpot虚拟机上是不会由于虚拟机栈无法扩展而导致`OutOfMemoryError`异常——只要线程申请栈空间成功了就不会有OOM，但是如果申请时就失败，仍然是会出现OOM异常的。


### 2.2.2.2 操作数栈
// TODO

### 2.2.2.3 动态连接
// TODO

### 2.2.2.4 方法出口
// TODO

## 2.2.3 本地方法栈

- 和虚拟机栈作用相似，不过本地方法栈是为本地方法服务，即被 native 修饰的方法

## 2.2.4 Java 堆
> 在虚拟机启动时创建。


> 逃逸分析技术的日渐强大，栈上分配、标量替换优化手段已经导致一些微妙的变化悄然发生，所以说Java对象实例都分配在堆上也渐渐变得不是那么绝对了。

- // TODO ？？？？
> Java堆既可以被实现成固定大小的，也可以是可扩展的，不过当前主流的Java虚拟机都是按照可扩展来实现的（通过参数`-Xmx`和`-Xms`设定）。


> 如果在Java堆中没有内存完成实例分配，并且堆也无法再扩展时，Java虚拟机将会抛出`OutOfMemoryError`异常。


## 2.2.5 方法区
> 用于存储已被虚拟机加载的类型信息、常量、静态变量、即时编译器编译后的代码缓存等数据。


### 为什么把方法区称为永久代？
> 因为仅仅是当时的HotSpot虚拟机设计团队选择把收集器的分代设计扩展至方法区，或者说使用永久代来实现方法区而已，这样使得HotSpot的垃圾收集器能够像管理Java堆一样管理这部分内存，省去专门为方法区编写内存管理代码的工作。


### 使用永久代来实现方法区的坏处
> 但现在回头来看，当年使用永久代来实现方法区的决定并不是一个好主意，这种设计导致了Java应用更容易遇到内存溢出的问题（永久代有`-XX：MaxPermSize`的上限，即使不设置也有默认大小，而J9和JRockit只要没有触碰到进程可用内存的上限，例如32位系统中的4GB限制，就不会出问题），而且有极少数方法（例如`String::intern()`）会因永久代的原因而导致不同虚拟机下有不同的表现。当Oracle收购BEA获得了JRockit的所有权后，准备把JRockit中的优秀功能，譬如Java Mission Control管理工具，移植到HotSpot虚拟机时，但因为两者对方法区实现的差异而面临诸多困难。


### HotSpot开发团队的挽救措施
> 考虑到HotSpot未来的发展，在JDK 6的时候HotSpot开发团队就有放弃永久代，逐步改为采用本地内存（Native Memory）来实现方法区的计划了，到了JDK 7的HotSpot，已经把原本放在永久代的字符串常量池、静态变量等移出，而到了JDK 8，终于完全废弃了永久代的概念，改用与JRockit、J9一样在本地内存中实现的元空间（Meta-space）来代替，把JDK 7中永久代还剩余的内容（主要是类型信息）全部移到元空间中。

- JDK 6 及以下：
   - 方法区的实现是永久代
- JDK 7：
   - 将原本放在永久代的 **字符串常量池、静态变量 **等移出
- JDK 8：
   - 完全废弃永久代，改用在本地内存中实现的元空间来代替

### 永久代是什么？
// TODO

### 元空间是什么？
// TODO

> 如果方法区无法满足新的内存分配需求时，将抛出`OutOfMemoryError`异常。



## 2.2.6 运行时常量池
> 是方法区的一部分。


> Class文件中除了有类的版本、字段、方法、接口等描述信息外，还有一项信息是常量池表（Constant Pool Table），用于存放编译期生成的各种字面量与符号引用，这部分内容将在类加载后存放到方法区的运行时常量池中。

- 存放：
   - 类的版本
   - 字段
   - 方法
   - 接口
   - 常量池表
      - 字面量
      - 符号引用
> 不过一般来说，除了保存Class文件中描述的符号引用外，还会把由符号引用翻译出来的直接引用也存储在运行时常量池中。


### 符号引用？？直接引用？？
// TODO

## 2.2.7 直接内存
> 直接内存（Direct Memory）并不是虚拟机运行时数据区的一部分，也不是《Java虚拟机规范》中定义的内存区域。但是这部分内存也被频繁地使用，而且也可能导致`OutOfMemoryError`异常出现，所以我们放到这里一起讲解。


> 在JDK 1.4中新加入了NIO（New Input/Output）类，引入了一种基于通道（Channel）与缓冲区（Buffer）的I/O方式，它可以使用Native函数库直接分配堆外内存，然后通过一个存储在Java堆里面的`DirectByteBuffer`对象作为这块内存的引用进行操作。这样能在一些场景中显著提高性能，因为避免了在Java堆和Native堆中来回复制数据。
> 显然，本机直接内存的分配不会受到Java堆大小的限制，但是，既然是内存，则肯定还是会受到本机总内存（包括物理内存、SWAP分区或者分页文件）大小以及处理器寻址空间的限制，一般服务器管理员配置虚拟机参数时，会根据实际内存去设置-Xmx等参数信息，但经常忽略掉直接内存，使得各个内存区域总和大于物理内存限制（包括物理的和操作系统级的限制），从而导致动态扩展时出现`OutOfMemoryError`异常。


# 2.3 HotSpot虚拟机对象探秘

## 2.3.1 对象的创建
> （文中讨论的对象限于普通Java对象，不包括数组和Class对象等）

> 当Java虚拟机遇到一条字节码new指令时，首先将去检查这个指令的参数是否能在常量池中定位到一个类的符号引用，并且检查这个符号引用代表的类是否已被加载、解析和初始化过。如果没有，那必须先执行相应的类加载过程。

- 判断该类是否已经被加载，没有则加载
> 在类加载检查通过后，接下来虚拟机将为新生对象分配内存.

> 假设Java堆中内存是绝对规整的，所有被使用过的内存都被放在一边，空闲的内存被放在另一边，中间放着一个指针作为分界点的指示器，那所分配内存就仅仅是把那个指针向空闲空间方向挪动一段与对象大小相等的距离，这种分配方式称为“指针碰撞”（Bump ThePointer）。

> 但如果Java堆中的内存并不是规整的，已被使用的内存和空闲的内存相互交错在一起，那就没有办法简单地进行指针碰撞了，虚拟机就必须维护一个列表，记录上哪些内存块是可用的，在分配的时候从列表中找到一块足够大的空间划分给对象实例，并更新列表上的记录，这种分配方式称为“空闲列表”（Free List）。

> 选择哪种分配方式由Java堆是否规整决定，而Java堆是否规整又由所采用的垃圾收集器是否带有空间压缩整理（Compact）的能力决定。

> 因此，当使用Serial、ParNew等带压缩整理过程的收集器时，系统采用的分配算法是指针碰撞，既简单又高效；而当使用CMS这种基于清除（Sweep）算法的收集器时，理论上[1] 就只能采用较为复杂的空闲列表来分配内存。

> [1] 强调“理论上”是因为在CMS的实现里面，为了能在多数情况下分配得更快，设计了一个叫作Linear 
> Allocation Buffer的分配缓冲区，通过空闲列表拿到一大块分配缓冲区之后，在它里面仍然可以使用指 
> 针碰撞方式来分配。

- 内存分配方式
   - 指针碰撞
      - 堆内存规整时，直接从空余的内存和已使用内存的交界点开始分配内存。
   - 空闲列表
      - 堆内存不规整时，需要通过某种方式找到一个足够大的内存空间用来分配。
- 怎么选择分配方式？
   - 根据Java堆是否规整决定，而Java堆是否规整又由所采用的垃圾收集器是否带有空间压缩整理（Compact）的能力决定。
> 除如何划分可用空间之外，还有另外一个需要考虑的问题：对象创建在虚拟机中是非常频繁的行为，即使仅仅修改一个指针所指向的位置，在并发情况下也并不是线程安全的，可能出现正在给对象A分配内存，指针还没来得及修改，对象B又同时使用了原来的指针来分配内存的情况。解决这个问题有两种可选方案：一种是对分配内存空间的动作进行同步处理——实际上虚拟机是采用CAS配上失败重试的方式保证更新操作的原子性；另外一种是把内存分配的动作按照线程划分在不同的空间之中进行，即每个线程在Java堆中预先分配一小块内存，称为本地线程分配缓冲（Thread Local AllocationBuffer，TLAB），哪个线程要分配内存，就在哪个线程的本地缓冲区中分配，只有本地缓冲区用完了，分配新的缓存区时才需要同步锁定。虚拟机是否使用TLAB，可以通过-XX：+/-UseTLAB参数来设定。

- 线程不安全？为什么？
   - 对象的内存分配过程中，主要是将对象的引用指向这个内存区域，然后进行初始化操作。而并发情况下，就有可能出现：
      - 线程 A 发现内存区域 C 可以分配给对象 B
      - 线程 D 抢到 CPU 时间片，线程 D 也发现了内存区域 C 可以分配给对象 E
      - 线程 A 抢到 CPU 时间片，将对象 B 的引用指向了内存区域 C 
      - 线程 D 抢到 CPU 时间片，将对象 E 的引用指向了内存区域 C
- 怎么解决？两种方式
   - `TLAB(Thread Local AllocationBuffer)`
   - CAS + 失败重试
- 虚拟机是否使用TLAB，可以通过-XX：+/-UseTLAB参数来设定。
> 内存分配完成之后，虚拟机必须将分配到的内存空间（但不包括对象头）都初始化为零值，如果使用了TLAB的话，这一项工作也可以提前至TLAB分配时顺便进行。这步操作保证了对象的实例字段在Java代码中可以不赋初始值就直接使用，使程序能访问到这些字段的数据类型所对应的零值。

- 初始化为 0 值是初始化对象所在的内存空间。
- 对象中的属性的内存空间是如何分配的？？？// TODO
   - 【猜想】初始化局部变量的时候会用到一种数据结构，叫“槽”。会不会内存也是按照某种“槽”进行分配大小，然后就可以根据其在对象中的偏移量来确定内存中的位置。
   - 【结论】[实例数据的分配规则](#IKYSo)（语雀客户端访问异常，浏览器可以访问）
> 接下来，Java虚拟机还要对对象进行必要的设置，例如这个对象是哪个类的实例、如何才能找到类的元数据信息、对象的哈希码（实际上对象的哈希码会延后到真正调用Object::hashCode()方法时才计算）、对象的GC分代年龄等信息。这些信息存放在对象的对象头（Object Header）之中。根据虚拟机当前运行状态的不同，如是否启用偏向锁等，对象头会有不同的设置方式。关于对象头的具体内容，稍后会详细介绍。

- 是个饼
> 在上面工作都完成之后，从虚拟机的视角来看，一个新的对象已经产生了。但是从Java程序的视角看来，对象创建才刚刚开始——构造函数，即Class文件中的<init>()方法还没有执行，所有的字段都为默认的零值，对象需要的其他资源和状态信息也还没有按照预定的意图构造好。一般来说（由字节码流中new指令后面是否跟随invokespecial指令所决定，Java编译器会在遇到new关键字的地方同时生成这两条字节码指令，但如果直接通过其他方式产生的则不一定如此），new指令之后会接着执行<init>()方法，按照程序员的意愿对对象进行初始化，这样一个真正可用的对象才算完全被构造出来。

- 实例属性的 初始值是在调用 构造方法 的时候赋值的。没有调用构造方法前都是 0。
- 类属性呢？
   - 这里只是谈了普通Java对象，没有提及数组、Class对象等的创建过程。又是一个坑。// TODO

## 2.3.2 对象的内存布局
> 在HotSpot虚拟机里，对象在堆内存中的存储布局可以划分为三个部分：对象头（Header）、实例数据（Instance Data）和对齐填充（Padding）。

- 对象的存储布局
   - 对象头
   - 实例数据
   - 对齐填充
> HotSpot虚拟机对象的对象头部分包括两类信息。第一类是用于存储对象自身的运行时数据，如哈希码（HashCode）、GC分代年龄、锁状态标志、线程持有的锁、偏向线程ID、偏向时间戳等，这部分数据的长度在32位和64位的虚拟机（未开启压缩指针）中分别为32个比特和64个比特，官方称它为“Mark Word”。

- 对象头存储对象自身的运行时数据，在64位的虚拟机上位64比特。
   - 哈希码
   - GC 分代年龄
   - 锁状态标志
   - 线程持有的锁
   - 偏向线程 ID
   - 偏向时间戳
   - 等
> 对象需要存储的运行时数据很多，其实已经超出了32、64位Bitmap结构所能记录的最大限度，但对象头里的信息是与对象自身定义的数据无关的额外存储成本，考虑到虚拟机的空间效率，Mark Word被设计成一个有着动态定义的数据结构，以便在极小的空间内存储尽量多的数据，根据对象的状态复用自己的存储空间。例如在32位的HotSpot虚拟机中，如对象未被同步锁锁定的状态下，Mark Word的32个比特存储空间中的25个比特用于存储对象哈希码，4个比特用于存储对象分代年龄，2个比特用于存储锁标志位，1个比特固定为0，在其他状态（轻量级锁定、重量级锁定、GC标记、可偏向）[1]下对象的存储内容如表2-1所示。

表2-1 HotSpot虚拟机对象头Mark Word

| **存储内容** | **标志位** | **状态** |
| --- | --- | --- |
| 对象哈希码、对象分代年龄 | 01 | 未锁定 |
| 指向锁记录的指针 | 00 | 轻量级锁定 |
| 指向重量级锁的指针 | 10 | 膨胀（重量级锁定） |
| 空，不需要记录信息 | 11 | GC 标记 |
| 偏向线程 ID、偏向时间戳、对象分代年龄 | 01 | 可偏向 |

- 上表不够明确，经过查阅资料找到一张更好的表格（已经向作者大大提交了issue了）
- ![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220319.jpg)
- 这里有个题外话，对运行时的对象头进行分析可以使用 `jol-core` 类库，具体使用方法自行搜索。
> 对象头的另外一部分是类型指针，即对象指向它的类型元数据的指针，Java虚拟机通过这个指针来确定该对象是哪个类的实例。并不是所有的虚拟机实现都必须在对象数据上保留类型指针，换句话说，查找对象的元数据信息并不一定要经过对象本身，这点我们会在下一节具体讨论。此外，如果对象是一个Java数组，那在对象头中还必须有一块用于记录数组长度的数据，因为虚拟机可以通过普通Java对象的元数据信息确定Java对象的大小，但是如果数组的长度是不确定的，将无法通过元数据中的信息推断出数组的大小。

- 类型指针大小与Mark Word大小一样
- 建议阅读：[面试被问：一个Java对象占多少内存？ - 腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1596672)

- 总结：32位虚拟机下对象头的内存布局（未开启指针压缩）
| Object Header（64bits） |  |  |  |  |  | State |
| --- | --- | --- | --- | --- | --- | --- |
| Mark Word（32bits） |  |  |  |  | Klass Word（32bits） |  |
| 对象的hashcode:25 |  | 对象分代年龄:4 | 偏向锁:1（0） | 锁标志位:2（01） | 指向元空间的类型指针 | 无锁 |
| 线程 ID:23 | Epoch:2 | 对象分代年龄:4 | 偏向锁:1（1） | 锁标志位:2（01） | 指向元空间的类型指针 | 可偏向 |
| 指向线程栈中锁记录的指针:32 |  |  |  | 锁标志位:2（00） | 指向元空间的类型指针 | 轻量级锁 |
| 指向重量级锁 Monitor 的指针:32 |  |  |  | 锁标志位:2（10） | 指向元空间的类型指针 | 重量级锁 |
| 空:32 |  |  |  | 锁标志位:2（11） | 指向元空间的类型指针 | GC 标记 |

> 接下来实例数据部分是对象真正存储的有效信息，即我们在程序代码里面所定义的各种类型的字段内容，无论是从父类继承下来的，还是在子类中定义的字段都必须记录起来。这部分的存储顺序会受到虚拟机分配策略参数（
> -XX：FieldsAllocationStyle参数）和字段在Java源码中定义顺序的影响。HotSpot虚拟机默认的分配顺序为longs/doubles、ints、shorts/chars、bytes/booleans、oops（OrdinaryObject Pointers，OOPs），从以上默认的分配策略中可以看到，相同宽度的字段总是被分配到一起存放，在满足这个前提条件的情况下，在父类中定义的变量会出现在子类之前。如果HotSpot虚拟机的+XX：CompactFields参数值为true（默认就为true），那子类之中较窄的变量也允许插入父类变量的空隙之中，以节省出一点点空间。


###### 实例数据的分配规则（锚点）

- 实例数据的分配顺序规则
   - 父类的变量在子类前
   - 类中变量按照：longs/doubles、ints、shorts/chars、bytes/booleans、oops（OrdinaryObject Pointers，OOPs）的顺序分配
- 为什么会有间隙？
   - 看下文：[JVM中的对象探秘（三）- 对象的实例数据与对齐填充_java 对齐填充_很酷的小陈同学的博客-CSDN博客](https://blog.csdn.net/q13145241q/article/details/108169128)

### 关于 +XX: CompactFields 参数 不生效 的一次测试
关于“如果HotSpot虚拟机的+XX：CompactFields参数值为true（默认就为true），那子类之中较窄的变量也允许插入父类变量的空隙之中，以节省出一点点空间。”这句话的测试如下。

#### 环境

##### Java 环境
java version "1.8.0_351"Java(TM) SE Runtime Environment (build 1.8.0_351-b10)Java HotSpot(TM) 64-Bit Server VM (build 25.351-b10, mixed mode)

##### JVM 参数默认值
通过命令 `java -XX:+PrintFlagsFinal`  查看参数的默认值可以发现 CompactFields 确实默认为 true，但是它似乎没有作用。![](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220323.jpg)

##### IDE 环境
IntelliJ IDEA 2023.1 (Ultimate Edition)Build #IU-231.8109.175, built on March 28, 2023For educational use only.Runtime version: 17.0.6+10-b829.5 amd64VM: OpenJDK 64-Bit Server VM by JetBrains s.r.o.Windows 10.0GC: G1 Young Generation, G1 Old GenerationMemory: 2016MCores: 12Registry:debugger.new.tool.window.layout=truedebugger.valueTooltipAutoShowOnSelection=trueide.experimental.ui=true

Non-Bundled Plugins:cn.com.pism.batslog (23.03.02.2009-RE)com.intellij.zh (231.250)leetcode-editor (8.7)com.intellij.ideolog (203.0.30.0)CMD Support (1.0.5)coderead.IdeaPlugins.maven (1.1)com.intellij.plugin.adernov.powershell (2.0.10)MavenRunHelper (4.23.222.2964.0)com.baomidou.plugin.idea.mybatisx (1.5.5)cn.yiiguxing.plugin.translate (3.4.2)

Kotlin: 231-1.8.20-IJ8109.175

##### Windows 环境
Win10 专业版 19045.2728

#### 测试代码
```java

class F2 {
    byte a1;
    boolean a2;
    char a3;
    short a4;
    int a5;
    float a6;
    long a7;
    double a8;

    S2 a9;
}

class S2 extends F2 {
    boolean b1;
}

public class T {

    public static void main(String[] args) {
        f2_s2();
    }

    private static void f2_s2() {
        System.out.println(ClassLayout.parseInstance(new S2()).toPrintable());
        /* 运行结果
        从运行结果来看并没有把小字段添加到间隙中去。这里的运行结果是没有开启指针压缩的情况下的，不过这应该不会对实验结果造成影响。

        _2._3._2_object_memory_layout.test1.S2 object internals:
        OFF  SZ                                     TYPE DESCRIPTION               VALUE
          0   8                                          (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
          8   8                                          (object header: class)    0x000002b97f14dcc0
         16   8                                     long F2.a7                     0
         24   8                                   double F2.a8                     0.0
         32   4                                      int F2.a5                     0
         36   4                                    float F2.a6                     0.0
         40   2                                     char F2.a3
         42   2                                    short F2.a4                     0
         44   1                                     byte F2.a1                     0
         45   1                                  boolean F2.a2                     false
         46   2                                          (alignment/padding gap)
         48   8   _2._3._2_object_memory_layout.test1.S2 F2.a9                     null
         56   1                                  boolean S2.b1                     false
         57   7                                          (object alignment gap)
        Instance size: 64 bytes
        Space losses: 2 bytes internal + 7 bytes external = 9 bytes total
         */
    }
}
```
从运行结果可以发现：父类变量在偏移量为 46 的位置出现了一个大小为 2 的间隙，但是 JVM 并没有将子类中大小为 1 的 boolean 变量插入到父类变量的间隙中。如果将子类的 boolean 变量插入到间隙中，这将使整个对象的大小缩减为 56 bytes，并且只浪费 1 bytes，而不是占用 64 bytes 浪费 9 bytes。这是为什么呢？我希望是我这对块知识的理解有误。

> 对象的第三部分是对齐填充，这并不是必然存在的，也没有特别的含义，它仅仅起着占位符的作用。由于HotSpot虚拟机的自动内存管理系统要求对象起始地址必须是8字节的整数倍，换句话说就是任何对象的大小都必须是8字节的整数倍。对象头部分已经被精心设计成正好是8字节的倍数（1倍或者2倍），因此，如果对象实例数据部分没有对齐的话，就需要通过对齐填充来补全。

- 也就是说一个对象的大小一定是 8 字节的整数倍。

## 2.3.3 对象的访问定位
> 创建对象自然是为了后续使用该对象，我们的Java程序会通过栈上的reference数据来操作堆上的具体对象。由于reference类型在《Java虚拟机规范》里面只规定了它是一个指向对象的引用，并没有定义这个引用应该通过什么方式去定位、访问到堆中对象的具体位置，所以对象访问方式也是由虚拟机实现而定的，

- Java程序通过 reference 数据（指向一个对象的引用）来操作堆中的对象。
- 具体怎么通过 reference 去定位到堆中对象的具体位置由虚拟机决定。
> 主流的访问方式主要有使用句柄和直接指针两种： 
> - 如果使用句柄访问的话，Java堆中将可能会划分出一块内存来作为句柄池，reference中存储的就是对象的句柄地址，而句柄中包含了对象实例数据与类型数据各自具体的地址信息，其结构如图2-2所示。 
> - 如果使用直接指针访问的话，Java堆中对象的内存布局就必须考虑如何放置访问类型数据的相关信息，reference中存储的直接就是对象地址，如果只是访问对象本身的话，就不需要多一次间接访问的开销，如图2-3所示。

详情见图：![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220325.jpg)![image.png](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907220328.jpg)
> 这两种对象访问方式各有优势，使用句柄来访问的最大好处就是reference中存储的是稳定句柄地址，在对象被移动（垃圾收集时移动对象是非常普遍的行为）时只会改变句柄中的实例数据指针，而reference本身不需要被修改。
> 使用直接指针来访问最大的好处就是速度更快，它节省了一次指针定位的时间开销，由于对象访问在Java中非常频繁，因此这类开销积少成多也是一项极为可观的执行成本，就本书讨论的主要虚拟机HotSpot而言，它主要使用第二种方式进行对象访问（有例外情况，如果使用了Shenandoah收集器的话也会有一次额外的转发，具体可参见第3章），但从整个软件开发的范围来看，在各种语言、框架中使用句柄来访问的情况也十分常见。

- 句柄访问
   - 优点：垃圾收集时，reference 中存储的句柄地址不会改变，只需要改变句柄池中的实例数据指针即可。
- 直接指针
   - 优点：速度更快，节省了一次指针定位的时间开销。
- HotSpot 使用直接指针进行访问。

# 2.4 实战：OutOfMemoryError异常
略。
