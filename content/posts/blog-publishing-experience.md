---
title: "博客发布经验总结：从零到发布完整工作流"
date: 2026-04-19T22:46:00+08:00
draft: false
tags: ["博客", "Hugo", "WSL", "经验分享", "工作流"]
categories: ["技术"]
description: "总结从文章撰写到博客发布的完整经验、踩坑记录和最佳实践"
---

# 博客发布经验总结：从零到发布完整工作流

## 背景

今天经历了从「写文章 → 配置 Hugo front matter → 构建博客 → 踩坑 → 解决问题 → 最终发布」的完整流程。这篇文章记录了整个过程的每个步骤、遇到的问题和对应的解决方案。

**环境：**

| 项目 | 值 |
|------|------|
| WSL 版本 | Ubuntu 24.04 ARM64 |
| Hugo 版本 | v0.147.4（从源码编译） |
| 博客框架 | Hugo + PaperMod 主题 |
| 博客路径 | `~/Desktop/openclaw_share_repo/tech-blog` |
| 构建输出 | `~/Desktop/openclaw_share_repo/tech-blog/public` |

---

## 一、完整工作流

### Step 1: 撰写文章

先在 workspace 中撰写纯 Markdown 文章（不含 front matter），完成内容编写：

```bash
# 文章初稿放在 workspace
/home/derek/.openclaw/workspace/tech-blog/文章名.md
```

### Step 2: 添加 Hugo Front Matter

文章放入博客 `content/posts/` 目录时，必须添加 Hugo 的 YAML front matter：

```yaml
---
title: "文章标题"
date: 2026-04-19T22:46:00+08:00
draft: false
tags: ["标签1", "标签2", "标签3"]
categories: ["技术"]
description: "文章简短描述，用于列表页展示"
---
```

> ⚠️ **注意**：如果没有 front matter，Hugo 无法识别文章元数据，会导致标题显示异常或文章不出现在列表中。

### Step 3: 放入博客内容目录

```bash
cp 文章.md ~/Desktop/openclaw_share_repo/tech-blog/content/posts/
```

### Step 4: 构建博客

```bash
cd ~/Desktop/openclaw_share_repo/tech-blog
make build
```

**如果构建成功**，会看到类似输出：

```
                   | EN   
-------------------+------
  Pages            | 107  
  Paginator pages  |   0  
  ...
Total in 368 ms
```

### Step 5: 确认输出

```bash
# 确认新文章已生成
ls public/posts/ | grep 文章名
wc -c public/posts/文章目录/index.html
```

---

## 二、踩坑记录与解决方案

### 坑 1：WSL ARM 无法运行 Hugo 预编译二进制

**现象：**

```
SIGILL: illegal instruction
github.com/tetratelabs/wazero/internal/platform.getisar0()
```

**根因：** Hugo v0.122+ 依赖 wazero 库，wazero 在 ARM Linux 上用 `MRS` 指令读取 CPU 寄存器。但 WSL2 ARM 的 Windows 内核模拟层不支持这条指令，直接触发 SIGILL 崩溃。

**解决：** 从 Go 源码编译 Hugo，并 patch wazero 的 CPU 寄存器读取逻辑：

```bash
# 1. 安装 Go
curl -fsSL "https://go.dev/dl/go1.24.4.linux-arm64.tar.gz" -o /tmp/go.tar.gz
mkdir -p ~/go_root && tar -xzf /tmp/go.tar.gz -C ~/go_root/
export PATH="$HOME/go_root/go/bin:$PATH"

# 2. 克隆 Hugo 源码
git clone --depth 1 --branch v0.147.4 https://github.com/gohugoio/hugo.git /tmp/hugo-src-new

# 3. Patch wazero（详见 Hugo WSL ARM 安装踩坑记文章）

# 4. 编译
cd /tmp/hugo-src-new
go build -o ~/.local/bin/hugo .
~/.local/bin/hugo version
```

**详细教程：** 参考本站的 [Hugo 在 WSL ARM 上安装踩坑记](/posts/hugo-wsl-arm-install/) 文章。

### 坑 2：旧版 Hugo 不兼容 PaperMod 主题

**现象：**

```
ERROR => hugo v0.146.0 or greater is required for hugo-PaperMod to build
```

**根因：** PaperMod 主题需要 Hugo ≥ 0.146.0，但 Hugo v0.121.2 是最后一个不含 wazero 的版本（在 WSL ARM 上不会崩溃）。

**解决：** 必须从源码编译新版 Hugo（见坑 1 的方案）。

### 坑 3：Hugo 配置 deprecation 导致构建失败

**现象：**

```
ERROR deprecated: site config key paginate was deprecated in Hugo v0.128.0
```

**根因：** `paginate` 配置项在 Hugo v0.128.0 中被废弃，PaperMod 新版本将其视为错误。

**解决：** 修改 `hugo.yaml`：

```yaml
# 修改前
paginate: 10

# 修改后
pagination:
  pagerSize: 10
```

### 坑 4：WSL 写 Windows 共享目录的 chtimes 权限问题

**现象：**

```
Error: error copying static files: chtimes /home/derek/Desktop/.../public: operation not permitted
```

**根因：** WSL 访问 Windows 文件系统（`/mnt/c/` 或桌面共享路径）时，文件时间戳修改操作不被允许。

**解决：** 先在 WSL 原生目录构建，再复制回共享目录：

```bash
# 1. 复制到 WSL 原生目录
rm -rf /tmp/blog-build
mkdir -p /tmp/blog-build
cp -r ~/Desktop/openclaw_share_repo/tech-blog/* /tmp/blog-build/

# 2. 在 WSL 原生目录构建
cd /tmp/blog-build && make build

# 3. 同步回共享目录
cp -r /tmp/blog-build/public ~/Desktop/openclaw_share_repo/tech-blog/
```

---

## 三、一键发布脚本

为了提高效率，我把整个流程整理成一个可复用的脚本：

```bash
#!/bin/bash
# publish-blog.sh - 博客文章发布脚本
# 用法：./publish-blog.sh 文章名.md

set -e

BLOG_SRC="$1"
BLOG_DIR="/home/derek/Desktop/openclaw_share_repo/tech-blog"
BUILD_DIR="/tmp/blog-build"

if [ -z "$BLOG_SRC" ]; then
    echo "用法: $0 <文章路径>"
    exit 1
fi

if [ ! -f "$BLOG_SRC" ]; then
    echo "错误: 文件不存在: $BLOG_SRC"
    exit 1
fi

echo "📝 复制文章到博客目录..."
cp "$BLOG_SRC" "$BLOG_DIR/content/posts/"

echo "🔨 在 WSL 原生目录构建..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r "$BLOG_DIR"/* "$BUILD_DIR/"
cd "$BUILD_DIR" && make build

echo "📦 同步构建结果回共享目录..."
cp -r "$BUILD_DIR/public" "$BLOG_DIR/"

echo "✅ 发布完成！"
echo "输出: $BLOG_DIR/public/"
```

使用方式：

```bash
chmod +x publish-blog.sh
./publish-blog.sh ~/Desktop/openclaw_share_repo/tech-blog/content/posts/新文章.md
```

---

## 四、文章撰写规范

### 4.1 文件命名

- 使用小写英文 + 短横线：`yt-dlp-deep-dive.md`、`hugo-wsl-arm-install.md`
- 不要用中文文件名、空格或大写字母

### 4.2 Front Matter 必填项

```yaml
title: "文章标题（中文或英文均可）"
date: 2026-04-19T22:46:00+08:00    # 发布时间，注意时区 +08:00
draft: false                        # 是否为草稿（true = 仅开发模式可见）
tags: ["标签1", "标签2"]            # 标签列表
categories: ["技术"]                # 分类
description: "文章描述"             # 列表页展示摘要
```

### 4.3 内容格式

- 使用标准 Markdown 语法
- 代码块标注语言：\`\`\`python / \`\`\`bash / \`\`\`yaml
- 图片使用相对路径或外部 URL
- 标题层级从 `##` 开始（`#` 被 front matter 的 title 覆盖）

### 4.4 参考已有文章

现有文章列表：

| 文件名 | 类型 |
|--------|------|
| `chalk-project-intro.md` | 开源项目介绍 |
| `yt-dlp-deep-dive.md` | 项目深度解读 |
| `hugo-wsl-arm-install.md` | 踩坑教程 |
| `cc-haha-tutorial.md` | 使用教程 |
| `high-concurrency-design.md` | 技术设计 |
| `static-blog-with-hugo.md` | 搭建指南 |

---

## 五、Hugo 安装备忘

当前环境 Hugo 安装在 `~/.local/bin/hugo`，版本 v0.147.4，是从 Go 源码编译的 patched 版本。

```bash
# 验证
~/.local/bin/hugo version

# PATH 中添加
export PATH="$HOME/.local/bin:$PATH"
```

Go 安装在 `~/go_root/go/`：

```bash
export PATH="$HOME/go_root/go/bin:$PATH"
```

如果需要重装或升级 Hugo，参考踩坑教程文章。

---

## 六、总结

今天一共完成了 3 篇文章的发布：

1. **yt-dlp 深度解读** — 775 行，项目架构深度分析
2. **Hugo WSL ARM 安装踩坑** — 完整的问题诊断和解决方案
3. **cc-haha 教程** — 泄露 Claude Code 源码的完整使用指南

**核心经验：**

| 经验 | 要点 |
|------|------|
| 写文章 | 先写内容，后加 front matter |
| 放位置 | 必须放在 `content/posts/` 目录下 |
| 构建 | 用 `make build`，WSL 共享目录要先 cp 到 `/tmp/` |
| 同步 | 构建完成后 `cp -r public/` 回原路径 |
| Hugo | WSL ARM 上必须从源码编译 + patch wazero |
| 配置 | `paginate` 改为 `pagination.pagerSize` |

把这些流程固化下来，以后发文章就是一条命令的事。
