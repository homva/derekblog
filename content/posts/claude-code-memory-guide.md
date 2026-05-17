---
title: "Claude Code Memory 完全指南：让 AI 助手记住你的项目"
date: 2026-04-27T19:10:00+08:00
draft: false
tags: ["Claude Code", "AI", "研发效率", "最佳实践"]
categories: ["技术"]
description: "深入解读 Claude Code 的 Memory 机制，帮助研发团队构建持久化的 AI 助手记忆体系"
---

## 背景：为什么 AI 助手需要"记忆"

如果你用过 Claude Code 或类似的 AI 编程助手，可能遇到过这样的场景：

- 每次新会话都要重新告诉 AI 你的项目架构
- AI 总是忘记你的代码规范（"用 2 空格缩进！"你说了第 N 遍）
- 上次会话中发现的调试技巧，下次全忘了

这就像你有个很聪明的同事，但每次对话都要从零开始介绍项目背景——效率极低。

Claude Code 的 **Memory 机制** 就是为了解决这个问题。它让 AI 助手能够：

1. **记住你的指令**：通过 `CLAUDE.md` 文件持久化项目规范
2. **自动学习**：通过 Auto Memory 自动积累经验和偏好

---

## 两大记忆系统概览

Claude Code 有两个互补的记忆系统：

| 特性 | CLAUDE.md | Auto Memory |
|------|-----------|-------------|
| **谁来写** | 你（开发者） | Claude 自动生成 |
| **内容类型** | 指令、规则、规范 | 学习笔记、调试经验、偏好 |
| **作用范围** | 项目级、用户级或组织级 | 每个工作目录独立 |
| **加载时机** | 每次会话启动时 | 每次会话启动时（前 200 行） |
| **适用场景** | 编码规范、工作流、架构说明 | 构建命令、调试技巧、自动发现的最佳实践 |

简单说：**CLAUDE.md 是你告诉 AI 的规则，Auto Memory 是 AI 自己记的笔记。**

---

## CLAUDE.md 文件详解

### 什么时候需要写 CLAUDE.md？

当你发现以下情况时，就该写下来了：

- AI 犯了同样的错误两次
- Code Review 指出了 AI 应该知道的问题
- 你在新会话中输入了和上次相同的纠正
- 新同事也需要同样的上下文才能高效工作

**核心原则**：把"需要反复说明的事情"变成"写在文件里的规则"。

### CLAUDE.md 放在哪里？

不同位置有不同的作用范围，**更具体的位置优先级更高**：

| 范围 | 位置 | 用途 | 共享给 |
|------|------|------|--------|
| **项目级** | `./CLAUDE.md` 或 `./.claude/CLAUDE.md` | 团队共享的项目规范 | 通过版本控制共享 |
| **用户级** | `~/.claude/CLAUDE.md` | 个人偏好（所有项目通用） | 仅你自己 |
| **本地级** | `./CLAUDE.local.md` | 项目特定个人偏好（加入 `.gitignore`） | 仅你自己 |

### 写出有效的 CLAUDE.md

#### 控制文件大小

目标：**每个文件控制在 200 行以内**。

原因：
- 文件越长，消耗的上下文越多
- 指令过长会降低 AI 的遵循度
- 项目规则可以用 `.claude/rules/` 目录按路径分片加载

#### 结构清晰

用 Markdown 标题和列表组织内容：

```markdown
# 项目架构

- 后端: Spring Boot 3.x
- 前端: React 18 + TypeScript
- 数据库: PostgreSQL 15

## 编码规范

### 后端
- 使用 4 空格缩进
- 所有 public 方法必须有 Javadoc
- Controller 返回统一 Response<T> 包装

### 前端
- 使用 2 空格缩进
- 组件命名: PascalCase
- 文件命名: kebab-case

## 常用命令

- 启动开发环境: `make dev`
- 运行测试: `npm test`
- 构建生产版本: `make build`
```

#### 指令具体可验证

❌ **模糊的指令**：
```markdown
格式化代码要规范
测试要做好
```

✅ **具体的指令**：
```markdown
- 使用 2 空格缩进，不用 tab
- 提交前运行 `npm test`，确保全部通过
- API handlers 放在 `src/api/handlers/` 目录
```

### 导入其他文件

CLAUDE.md 支持 `@path/to/import` 语法导入其他文件：

```markdown
# 项目概述

参见 @README 了解项目整体情况。
参见 @package.json 了解可用 npm 命令。

# Git 工作流

详细说明见 @docs/git-workflow.md
```

这样可以：
- 引用已有的文档，避免重复维护
- 把大文件拆分成模块，方便管理

### 与 AGENTS.md 兼容

如果项目已经有 `AGENTS.md`（给其他 AI 工具用的），可以这样兼容：

```markdown
@AGENTS.md

## Claude Code 专属规则

`src/billing/` 目录下的修改需使用 plan mode。
```

---

## 用 `.claude/rules/` 组织规则

大型项目指令太多怎么办？用规则目录拆分：

### 基本结构

```
your-project/
├── .claude/
│   ├── CLAUDE.md           # 主项目指令
│   └── rules/
│       ├── code-style.md   # 代码风格
│       ├── testing.md      # 测试规范
│       ├── security.md     # 安全要求
│       └── frontend/       # 子目录也支持
│           └── react.md
```

### 路径限定规则

规则可以限定只对特定文件生效，使用 YAML frontmatter：

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---

# API 开发规则

- 所有 API 端点必须包含输入验证
- 使用统一的错误响应格式
- 包含 OpenAPI 文档注释
```

**路径模式语法**：

| 模式 | 匹配 |
|------|------|
| `**/*.ts` | 所有 `.ts` 文件 |
| `src/**/*` | `src/` 下所有文件 |
| `*.md` | 根目录的 Markdown 文件 |
| `src/components/*.tsx` | 特定目录的 React 组件 |

**好处**：规则只在 AI 操作相关文件时才加载，节省上下文空间。

### 跨项目共享规则

用符号链接共享规则：

```bash
# 共享整个目录
ln -s ~/shared-claude-rules .claude/rules/shared

# 共享单个文件
ln -s ~/company-standards/security.md .claude/rules/security.md
```

---

## Auto Memory：AI 自学笔记

### 什么时候生效？

Auto Memory 在以下情况自动记录：

- 你纠正了 AI 的错误
- AI 发现了有效的调试方法
- 项目特有的构建/运行命令
- 你重复表达了某个偏好

**AI 自己判断什么值得记**，不需要你手动操作。

### 存储位置

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 索引文件，每次会话加载
├── debugging.md       # 调试相关笔记
├── api-conventions.md # API 设计决策
└── ...                # 其他主题文件
```

### 特点

- **每个项目独立**：基于 git 仓库路径区分
- **前 200 行加载**：`MEMORY.md` 前 200 行或 25KB 每次会话自动加载
- **可手动编辑**：就是普通的 Markdown 文件
- **主题文件按需加载**：详细内容存在主题文件里，AI 需要时才读取

### 启用/禁用

默认开启。可以通过设置关闭：

```json
{
  "autoMemoryEnabled": false
}
```

或环境变量：

```bash
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
```

### 查看/编辑 Auto Memory

会话中运行 `/memory` 命令可以：

- 查看所有加载的 CLAUDE.md 和规则文件
- 切换 Auto Memory 开关
- 打开 Auto Memory 目录

---

## 研发团队最佳实践

### 新项目初始化

1. **运行 `/init` 命令**：让 AI 分析代码库，自动生成初始 CLAUDE.md
2. **补充团队规范**：添加 AI 无法自动发现的规则
3. **提交到版本控制**：让团队共享这些指令

### CLAUDE.md 模板（后端项目）

```markdown
# 项目概述

一个基于 Spring Boot 的订单管理系统，处理电商订单全生命周期。

## 技术栈

- Java 21 + Spring Boot 3.2
- PostgreSQL 15 + Redis 7
- Gradle 8.x

## 架构要点

- 领域驱动设计（DDD）
- CQRS 模式处理读写分离
- 事件溯源用于审计

## 编码规范

### 必须
- 所有 public 方法必须有 Javadoc
- Controller 返回 `Response<T>` 统一包装
- 异常使用 `GlobalExceptionHandler` 统一处理
- 使用 4 空格缩进

### 禁止
- 禁止在 Controller 中写业务逻辑
- 禁止直接返回数据库实体（使用 DTO）
- 禁止使用 `System.out.println`

## 常用命令

```bash
# 启动开发环境
./gradlew bootRun

# 运行测试
./gradlew test

# 代码格式化
./gradlew spotlessApply

# 本地构建
./gradlew build -x test
```

## 测试规范

- 单元测试覆盖率 > 80%
- 集成测试放在 `src/testIntegration/`
- Mock 使用 Mockito
- 测试方法命名：`should_xxx_when_xxx`

## 提交规范

遵循 Conventional Commits：
- `feat:` 新功能
- `fix:` Bug 修复
- `refactor:` 重构
- `docs:` 文档
- `test:` 测试
```

### CLAUDE.md 模板（前端项目）

```markdown
# 项目概述

React 18 + TypeScript 企业级管理后台。

## 技术栈

- React 18 + TypeScript 5
- Vite 构建
- Tailwind CSS
- TanStack Query 数据请求

## 目录结构

```
src/
├── components/     # 通用组件
├── pages/          # 页面组件
├── hooks/          # 自定义 Hooks
├── services/       # API 调用层
├── stores/         # Zustand 状态管理
└── utils/          # 工具函数
```

## 编码规范

### 命名
- 组件文件：PascalCase（如 `UserProfile.tsx`）
- 工具函数：camelCase（如 `formatDate.ts`）
- CSS 类：使用 Tailwind，自定义类用 kebab-case

### 格式化
- 2 空格缩进
- 组件使用 arrow function
- Props 必须定义 TypeScript 类型

### React 规范
- 优先使用函数组件
- 状态提升到最小必要层级
- 副作用放在 `useEffect` 或 event handler

## 常用命令

```bash
# 开发
npm run dev

# 构建
npm run build

# 类型检查
npm run type-check

# 代码检查
npm run lint

# 修复 lint 问题
npm run lint:fix
```

## 组件开发流程

1. 先写 TypeScript 接口定义
2. 实现组件逻辑
3. 添加 Storybook story
4. 编写单元测试
```

### 组织级部署

对于需要统一规范的团队：

1. **创建组织级 CLAUDE.md**：
```markdown
# 公司研发规范

## 代码安全
- 不在代码中硬编码密钥
- 敏感配置使用环境变量
- 所有外部输入必须验证

## 代码审查
- PR 必须至少 1 人 approve
- 使用统一的 PR 模板

## 文档要求
- 新 API 必须有文档
- 架构变更需要 ADR（Architecture Decision Record）
```

2. **通过 MDM/Ansible 部署** 到所有开发机器

3. **设置无法排除**：组织级文件不受 `claudeMdExcludes` 影响

---

## 常见问题排查

### Q: AI 不遵循我的 CLAUDE.md？

排查步骤：

1. 运行 `/memory` 确认文件被加载
2. 检查文件位置是否正确
3. 让指令更具体（"用 2 空格" vs "格式化好一点"）
4. 检查是否有冲突的指令

### Q: Auto Memory 存了什么？

运行 `/memory` 查看自动记忆文件夹，都是普通 Markdown，可以阅读、编辑、删除。

### Q: CLAUDE.md 太长怎么办？

- 控制在 200 行以内
- 使用 `.claude/rules/` 按路径拆分
- 删掉不必要的内容

### Q: `/compact` 后指令丢失？

项目根目录的 CLAUDE.md 会重新加载，子目录的不会。把重要指令移到根目录。

---

## 快速开始

```bash
# 1. 在项目根目录创建 CLAUDE.md
touch CLAUDE.md

# 2. 或者让 AI 帮你生成
# 在 Claude Code 会话中运行：
/init

# 3. 查看当前加载的指令
/memory

# 4. 让 AI 记住你的偏好
"记住这个项目用 pnpm，不用 npm"
# AI 会自动写入 Auto Memory
```

---

## 总结

Claude Code 的 Memory 机制让 AI 助手从"每次对话从零开始"变成"有记忆的团队成员"：

| 场景 | 用什么 |
|------|--------|
| 想让 AI 遵循规则 | CLAUDE.md |
| 想让 AI 记住经验 | Auto Memory（自动） |
| 项目大、规则多 | `.claude/rules/` 目录 |
| 团队统一规范 | 组织级 CLAUDE.md |

**核心建议**：把重复的指令写进 CLAUDE.md，让 Auto Memory 自动积累经验，你的 AI 助手会越来越懂你的项目。

---

## 参考资料

- [Claude Code Memory 官方文档](https://code.claude.com/docs/en/memory)
- [Claude Code Skills 文档](https://code.claude.com/docs/en/skills)
- [Claude Code Settings 文档](https://code.claude.com/docs/en/settings)