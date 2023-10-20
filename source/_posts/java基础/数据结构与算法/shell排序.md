---
title: shell排序
date: 2023-09-07 17:59:14
categories:
- java基础
- 数据结构与算法
author: lx0815
comment: false
---


# 排序 - Shell排序(Shell Sort)

> 希尔排序(Shell Sort)是**插入排序**的一种，它是针对直接插入排序算法的改进。



## 希尔排序介绍

希尔排序实质上是一种分组插入方法。它的基本思想是: 对于n个待排序的数列，取一个小于n的整数gap(gap被称为步长)将待排序元素分成若干个组子序列，所有距离为gap的倍数的记录放在同一个组中；然后，对各组内的元素进行直接插入排序。 这一趟排序完成之后，每一个组的元素都是有序的。然后减小gap的值，并重复执行上述的分组和排序。重复这样的操作，当gap=1时，整个数列就是有序的。


## 希尔排序实现

下面以数列{80,30,60,40,20,10,50,70}为例，演示它的希尔排序过程。

第1趟: (gap=4)

![alg-sort-shell-1.jpg](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907215639.jpg)


当gap=4时,意味着将数列分为4个组: {80,20},{30,10},{60,50},{40,70}。 对应数列: {80,30,60,40,20,10,50,70} 对这4个组分别进行排序，排序结果: {20,80},{10,30},{50,60},{40,70}。 对应数列:

第2趟: (gap=2)

![alg-sort-shell-2.jpg](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907215641.jpg)


当gap=2时,意味着将数列分为2个组: {20,50,80,60}, {10,40,30,70}。 对应数列: {20,10,50,40,80,30,60,70} 注意: {20,50,80,60}实际上有两个有序的数列{20,80}和{50,60}组成。 {10,40,30,70}实际上有两个有序的数列{10,30}和{40,70}组成。 对这2个组分别进行排序，排序结果: {20,50,60,80}, {10,30,40,70}。 对应数列:

第3趟: (gap=1)

![alg-sort-shell-3.jpg](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/20230907215644.jpg)


当gap=1时,意味着将数列分为1个组: {20,10,50,30,60,40,80,70} 注意: {20,10,50,30,60,40,80,70}实际上有两个有序的数列{20,50,60,80}和{10,30,40,70}组成。 对这1个组分别进行排序，排序结果:


## 希尔排序的时间复杂度和稳定性


### 希尔排序时间复杂度

希尔排序的时间复杂度与增量(即，步长gap)的选取有关。例如，当增量为1时，希尔排序退化成了直接插入排序，此时的时间复杂度为O(N²)，而Hibbard增量的希尔排序的时间复杂度为O(N3/2)。


### 希尔排序稳定性

希尔排序是按照不同步长对元素进行插入排序，当刚开始元素很无序的时候，步长最大，所以插入排序的元素个数很少，速度很快；当元素基本有序了，步长很小， 插入排序对于有序的序列效率很高。所以，希尔排序的时间复杂度会比O(n^2)好一些。由于多次插入排序，我们知道一次插入排序是稳定的，不会改变相同元素的相对顺序，但**在不同的插入排序过程中，相同的元素可能在各自的插入排序中移动，最后其稳定性就会被打乱，所以shell排序是不稳定的**。

`算法稳定性` -- 假设在数列中存在a[i]=a[j]，若在排序之前，a[i]在a[j]前面；并且排序之后，a[i]仍然在a[j]前面。则这个排序算法是稳定的！


## 代码实现

```java
package com.w.winterVacation.sort;

import java.util.Arrays;

/**
 * shell排序
 * @author wspstart
 * @create 2023-01-25 17:23
 */
public class ShellSort {

    public static void sort(int[] arr){
        for (int gap = arr.length / 2; gap > 0 ; gap = gap / 2) {
            // 分组插入排序
            for (int i = gap; i < arr.length; i++) {
                // 记录当前正在插入的数据
                int temp = arr[i];
                int j;
                for ( j = i; j >=gap  && greater(arr[j - gap],temp); j= j-gap) {
                    arr[j] = arr[j-gap];
                }
                arr[j] = temp;
            }
            println(gap,arr);
        }
    }


    /**
     * 比较v元素是否大于w元素
     *
     * @param v
     * @param w
     * @return
     */
    private static boolean greater(int v, int w) {
        return v > w;
    }

    /**
     * 数组元素i和j交换
     *
     * @param a
     * @param i
     * @param j
     */
    private static void exch(int[] a, int i, int j) {
        int temp;
        temp = a[i];
        a[i] = a[j];
        a[j] = temp;
    }

    private static void println(int num, int[] a) {
        System.out.println("第" + num + "次循环" + Arrays.toString(a));
    }
}
```
