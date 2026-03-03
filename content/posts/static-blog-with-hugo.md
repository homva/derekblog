---
title: "从零搭建静态博客：Hugo + GitHub Pages 完整指南"
date: 2026-03-03
tags: ["Hugo", "静态博客", "GitHub Pages", "CI/CD"]
categories: ["技术实践"]
description: "手把手带你用 Hugo 搭建一个高性能静态博客，并通过 GitHub Actions 自动化部署到 GitHub Pages"
draft: false
---

静态博客在近几年经历了复兴。相比动态博客系统（WordPress、Ghost 等），静态站点生成器在性能、安全性和维护成本上都有显著优势。本文记录我们团队从选型到上线的完整过程。

## 为什么选择静态博客

在动手之前，先回答一个根本问题：**为什么不用现成的博客平台？**

| 方案 | 优点 | 缺点 |
|------|------|------|
| Medium / 掘金 | 零维护，有现成读者 | 内容不归自己，定制能力弱 |
| WordPress | 功能完整，插件丰富 | 需要服务器，维护成本高，安全隐患多 |
| 静态博客（Hugo/Hexo） | 极速、安全、版本控制友好 | 需要一定技术门槛 |

对于工程师团队来说，静态博客是最自然的选择：内容用 Markdown 写，用 Git 管理，CI/CD 自动部署——整个流程和日常开发工作无缝衔接。

## 选型：Hugo vs Hexo vs Jekyll

我们调研了主流的三个方案：

**Jekyll** 是 GitHub 官方支持的方案，但基于 Ruby，构建速度在文章较多时会明显变慢。

**Hexo** 基于 Node.js，生态成熟，中文社区活跃，但同样存在大站构建慢的问题。

**Hugo** 用 Go 编写，构建速度极快（千篇文章秒级完成），二进制安装无依赖，主题生态也相当丰富。最终我们选择了 Hugo。

## 环境准备

```bash
# macOS
brew install hugo

# 验证安装
hugo version
# hugo v0.124.0+extended darwin/arm64
```

## 创建项目

```bash
hugo new site my-blog
cd my-blog

# 初始化 Git
git init

# 添加主题（以 PaperMod 为例）
git submodule add https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
```

在 `hugo.yaml` 中配置主题：

```yaml
baseURL: https://your-username.github.io/
languageCode: zh-cn
title: 我的技术博客
theme: PaperMod

params:
  homeInfoParams:
    Title: 欢迎
    Content: 记录技术探索与工程实践
```

## 写第一篇文章

```bash
hugo new posts/hello-world.md
```

Hugo 会基于 archetype 模板生成文件，编辑内容后：

```bash
# 本地预览（支持热重载）
hugo server -D
```

打开 `http://localhost:1313` 即可看到效果。

## GitHub Actions 自动部署

这是整个方案中最关键的一环。在 `.github/workflows/deploy.yml` 创建以下配置：

```yaml
name: Deploy Hugo Site

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: 'latest'
          extended: true

      - name: Build
        run: hugo --minify

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

推送到 `main` 分支后，Actions 会自动构建并将生成的静态文件推送到 `gh-pages` 分支，GitHub Pages 从该分支提供服务。

## 性能优化要点

部署上线只是开始，以下几点可以进一步提升体验：

1. **启用 `--minify`**：Hugo 内置 HTML/CSS/JS 压缩，构建时直接加上
2. **图片懒加载**：在 `layouts` 中为 `img` 标签添加 `loading="lazy"`
3. **配置 CDN**：GitHub Pages 本身在国内访问较慢，可以通过 Cloudflare 加速
4. **RSS Feed**：Hugo 默认生成 RSS，记得在 `<head>` 中添加 `link` 标签让订阅者发现

## 总结

整个搭建过程从选型到上线大约花了半天时间。Hugo 的上手体验比预期顺畅，文档质量也很高。对于习惯 Git 工作流的工程师团队来说，这套方案几乎没有额外的心智负担——写文章和提交代码是同一件事。

如果你也在考虑搭建团队博客，不妨从 Hugo 开始。
