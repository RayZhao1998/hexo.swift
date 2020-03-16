# hexo.swift

## 来源

作为一个博客框架的折腾狂，从 jekyll 到 hexo 的静态博客框架方案，再到 wordpress 和 Ghost 这样的动态框架，都已经尝试过，并且沉迷于各种主题的使用。

后来，成为一个 Swift lover，我开始用 Vapor 构建自己的动态博客框架，用上软件工程课程和数据库课程中熟练掌握的 CRUD 构建了简单的动态博客框架，实现了文章的发布，查看功能，毕竟后端开发能力比较差，不太想折腾下去了。

看见 John Sundell 大佬开源了他的静态博客框架 Publish，于是打算自己做一个属于自己的 Only Swift 的静态博客框架，暂时取名为 hexo.swift，意味模仿 hexo 但又是 Only Swift 的。

## 简介

这是一个使用 Swift 编写的静态博客，当前的版本仅自用，仅供学习参考，不能用于生产。

## 使用

如果你使用 MacOS，可通过 hexo.swift 可执行文件进行以下操作

- new
  - new post <post name> 新建一篇文章
  - new page <page name> 新建一个页面
- build
  将 Posts 和 Pages 中所有 md 文件转换成 html 文件
- run
  将 Output 中生成好的 html 文件，通过 python http.server 构建网站

如果你使用 ubuntu，目前可执行文件尚不能在 ubuntu 上使用，若想在服务器构建网站，你需要在 Mac 本地 build，在服务器通过 `python3 -m http.server 8080` 来进行构建。
