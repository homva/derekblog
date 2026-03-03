---
title: "Hugo 博客搭建完全指南"
date: 2026-03-03T10:00:00+08:00
draft: false
tags: ["Hugo", "博客", "建站"]
categories: ["技术"]
description: "从零开始搭建 Hugo 静态博客，配置主题、部署到 Cloudflare Pages。"
---

## 前言

Hugo 是目前最快的静态网站生成器之一，使用 Go 语言编写，构建速度极快。本文介绍如何从零开始搭建 Hugo 博客并部署到 Cloudflare Pages。

## 安装 Hugo

```bash
# macOS
brew install hugo

# 验证安装
hugo version
```

## 创建新站点

```bash
hugo new site my-blog
cd my-blog
git init
```

## 本地开发

使用 `make dev` 启动开发服务器：

```bash
make dev
# 访问 http://localhost:1313
```

## 构建部署

```bash
# 构建静态文件
make build

# 清理构建产物
make clean
```

## 部署到 Cloudflare Pages

1. 将代码推送到 GitHub
2. 在 Cloudflare Pages 中连接仓库
3. 构建命令设置为 `hugo --minify`
4. 输出目录设置为 `public`

## 总结

Hugo + Cloudflare Pages 是一套免费、快速、稳定的博客方案，非常适合技术博客使用。
