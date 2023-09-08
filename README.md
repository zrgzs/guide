# guide
 博客

## 主题链接

https://shoka.lostyu.me/computer-science/note/theme-shoka-doc/

## 加入方式

1. 克隆 `main` 分支
2. 在对应的目录下新建文章
3. 添加文章信息头
   ```text
    ---
    title: xxx
    date: 2023-09-07 17:59:14
    categories:
    - java基础
    - other
    author: xxx
    comment: false
    ---
    ```
   其中，`comment: false` 是必须的。`title` 和 `date` 也是必填的。`categories` 是分类目录，第一个是一级目录，以此类推。
   `categories` 的层次结构需要与其相对于 `_post` 文件夹的路径一致。
4. 将已经写好的 md 格式的文档复制到 `guide-source/source/_posts`
5. 运行 `hexo clean ;hexo g ;hexo d`，如果是 linux 平台，则需要使用 `hexo clean && hexo g && hexo d`
