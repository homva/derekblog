# Derek Blogs

基于 Hugo + PaperMod 的个人技术博客，风格简洁现代。

## 项目结构

```
tech-blog/
├── hugo.yaml          # 站点配置
├── Makefile           # 构建命令
├── wrangler.toml      # Cloudflare Pages 部署配置
├── themes/PaperMod/   # PaperMod 主题（git submodule）
├── layouts/           # 自定义模板
│   └── index.html     # 首页模板
├── content/           # 内容目录
│   ├── about.md       # 关于页面
│   ├── posts/         # 博客文章
│   ├── search.md      # 搜索页
│   └── archives.md    # 归档页
└── public/            # 构建产物
```

## 环境要求

- Hugo v0.157.0+ (extended 版本)
- Git
- Make (可选)

## 本地开发

### 安装 Hugo

macOS:
```bash
brew install hugo
```

Linux:
```bash
# Debian/Ubuntu
sudo apt install hugo

# Arch Linux
sudo pacman -S hugo
```

### 克隆项目

```bash
git clone --recurse-submodules <repo-url>
cd tech-blog
```

如果忘记 `--recurse-submodules`，可以手动初始化：
```bash
git submodule update --init --recursive
```

### 启动开发服务器

```bash
# 方式一：使用 Make
make dev

# 方式二：直接使用 Hugo
hugo server --buildDrafts --buildFuture --disableFastRender --port 1313
```

访问 http://localhost:1313 查看效果。

### 构建静态文件

```bash
# 方式一：使用 Make
make build

# 方式二：直接使用 Hugo
hugo --minify --cleanDestinationDir
```

构建产物输出到 `public/` 目录。

### 清理构建产物

```bash
make clean
```

## 内容管理

### 创建新文章

```bash
hugo new posts/my-new-post.md
```

### 文章 Front Matter 示例

```yaml
---
title: "文章标题"
date: 2026-03-03
draft: false
tags: ["技术", "编程"]
categories: ["后端开发"]
description: "文章简介，用于 SEO 和列表展示"
---
```

### 页面类型

- `content/posts/` - 博客文章
- `content/about.md` - 关于页面
- `content/search.md` - 搜索页面（Fuse.js 全文搜索）
- `content/archives.md` - 归档页面

## 部署

### Cloudflare Pages（推荐）

1. 将代码推送到 GitHub/GitLab
2. 登录 Cloudflare Dashboard → Pages → 创建项目
3. 连接 Git 仓库，配置构建设置：
   - **构建命令**: `hugo --minify`
   - **输出目录**: `public`
   - **环境变量**: `HUGO_VERSION=0.157.0`

或使用 wrangler CLI：
```bash
wrangler pages deploy public --project-name=tech-blog
```

### GitHub Pages

1. 修改 `hugo.yaml` 中的 `baseURL` 为实际域名
2. 构建静态文件：`make build`
3. 推送 `public/` 目录到 `gh-pages` 分支

### Vercel

1. 导入 Git 仓库
2. 框架选择 Hugo
3. 构建命令：`hugo --minify`
4. 输出目录：`public`

## 主题定制

本项目使用 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题。

### 主要配置（hugo.yaml）

```yaml
params:
  # 首页信息
  homeInfoParams:
    Title: "👋 Hi, Welcome"
    Content: 这里是 Derek Blogs —— 记录技术探索与工程实践。
  
  # 功能开关
  ShowReadingTime: true      # 阅读时间
  ShowBreadCrumbs: true      # 面包屑导航
  ShowCodeCopyButtons: true  # 代码复制按钮
  ShowWordCount: true        # 字数统计
  showtoc: true              # 文章目录

# 菜单
menu:
  main:
    - name: 🔍 搜索
      url: /search/
    - name: 📂 归档
      url: /archives/
    - name: 🏷 标签
      url: /tags/
```

### 自定义样式

编辑 `assets/css/extended/custom.css`：

```css
:root {
  --primary: #2563eb;
}

/* 自定义首页样式 */
.home-info {
  border-left: 4px solid var(--primary);
  padding-left: 1.5rem;
}
```

## Makefile 命令

| 命令 | 说明 |
|------|------|
| `make dev` | 启动开发服务器（带热重载） |
| `make build` | 构建生产版本（压缩） |
| `make clean` | 清理构建产物 |

## 常见问题

### 主题未加载

确保 git submodule 已初始化：
```bash
git submodule update --init --recursive
```

### Hugo 版本过低

PaperMod 需要 Hugo extended 版本，检查：
```bash
hugo version
# 应显示: hugo v0.xxx+extended
```

### Cloudflare Pages 构建失败

在 Cloudflare Dashboard 设置环境变量：
- `HUGO_VERSION`: `0.157.0`

## 技术栈

- [Hugo](https://gohugo.io/) - 静态站点生成器
- [PaperMod](https://github.com/adityatelange/hugo-PaperMod) - Hugo 主题
- [Cloudflare Pages](https://pages.cloudflare.com/) - 部署平台

## License

MIT
