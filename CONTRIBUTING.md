# 贡献指南

## 内容规范

### 文章命名

- 文件名使用小写字母和连字符：`my-article-title.md`
- 避免使用中文文件名（可能导致编码问题）

### Front Matter 必填项

```yaml
---
title: "文章标题"
date: 2026-03-03
draft: false
tags: ["标签1", "标签2"]
categories: ["分类"]
description: "简介，不超过 160 字符"
---
```

### 文章结构建议

1. **开头** - 背景/问题引入
2. **正文** - 分节讲解，使用 `##` 和 `###`
3. **代码块** - 指定语言，如 ```python
4. **结尾** - 总结或扩展阅读

## Git 提交规范

使用 Conventional Commits：

- `feat:` 新功能
- `fix:` 修复
- `content:` 内容更新
- `docs:` 文档更新
- `style:` 样式调整
- `chore:` 构建/工具

示例：
```
content: 添加高并发系统设计文章
feat: 添加暗色模式切换
docs: 更新部署文档
```

## 开发流程

1. 创建新分支
2. 编写/修改内容
3. 本地预览验证
4. 提交 PR

```bash
# 创建文章
hugo new posts/my-article.md

# 本地预览
make dev

# 构建
make build
```
