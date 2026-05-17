---
title: "OpenSpec 全面解读：让 AI 编码从聊天即文档到文档即契约"
date: 2026-04-20T01:15:00+08:00
draft: false
tags: ["AI编程", "OpenSpec", "Spec驱动开发", "软件工程", "开发方法论"]
categories: ["技术"]
description: "全面解读 Fission-AI/OpenSpec 框架，Spec 驱动开发 SDD 的核心理念、全部概念、完整工作流与实战指南"
---

## OpenSpec 全面解读：让 AI 编码从"聊天即文档"到"文档即契约"

> **项目地址：** <https://github.com/Fission-AI/OpenSpec>  
> **作者：** Fission AI 团队（[@0xTab](https://x.com/0xTab) 等）  
> **许可证：** MIT  
> **社区：** [Discord](https://discord.gg/YctCnvvshC) | [npm](https://www.npmjs.com/package/@fission-ai/openspec)

---

## 一、OpenSpec 是什么？

OpenSpec 是一个 **Spec 驱动开发（SDD）框架**，专为 AI 编码助手设计。它解决的核心问题是：

> **AI 编码助手很强大，但不可预测——需求只存在于聊天记录里，上下文一丢就忘。**

OpenSpec 的答案是：在写代码之前，**先写 Spec**。

它不是要求你写一份几百页的需求文档，而是引入一个**轻量级的规范层**，让人类和 AI 对"要做什么"达成一致，每个变更都有自己的文件夹，包含提案、规范、设计、任务清单。

### 核心哲学

```
fluid not rigid         — 不搞阶段锁，想改就改
iterative not waterfall — 边做边学，逐步完善
easy not complex        — 最小仪式，几秒上手
brownfield-first        — 优先面向已有代码库，不是只能从零开始
```

### 与同类工具的对比

| 工具 | 特点 | OpenSpec 的差异 |
|------|------|----------------|
| **GitHub Spec Kit** |  thorough 但重量级，阶段锁，Python 环境 | OpenSpec 更轻量，可随时迭代 |
| **AWS Kiro** | 强大但锁定 IDE 和 Claude 模型 | OpenSpec 兼容 20+ 工具，不绑平台 |
| **什么都不用** | 需求只存在于聊天中，丢失后无法回溯 | OpenSpec 提供可预测性，不增加仪式负担 |

---

## 二、核心概念全景

为了让你快速理解，我们用 **"盖房子"** 的比喻来贯穿所有概念。

### 2.1 Specs：系统的"行为地图"

**对应比喻：房子的现状蓝图**

`openspec/specs/` 存放的是**系统当前所有行为的事实记录**，按领域分文件夹：

```
openspec/specs/
├── auth/       ← 认证领域：怎么登录、怎么发 token
├── payments/   ← 支付领域：怎么扣款、怎么退款
└── ui/         ← 界面领域：怎么切换主题、怎么交互
```

Spec 格式使用 **RFC 2119 关键词**（SHALL/MUST/SHOULD/MAY）标注需求强度，每个需求配 **Given/When/Then 场景**：

```markdown
### Requirement: User Authentication
The system SHALL issue a JWT token upon successful login.

#### Scenario: Valid credentials
- GIVEN a user with valid credentials
- WHEN the user submits login form
- THEN a JWT token is returned
- AND the user is redirected to dashboard
```

**关键原则：**

- Spec 是**"行为契约"**，不是"实现指南"
- 记录**外部可见的行为**，不记录内部类名、函数名
- 不写库选择、框架选型、步骤 1-2-3
- 一个简单测试：**如果实现变了但外部行为没变，那它就不该出现在 Spec 里**

### 2.2 Changes：每次改动的"独立包裹"

**对应比喻：每次改建的"施工申请单"**

每个功能、每个 Bug 修复、每次重构，都在 `openspec/changes/` 下有一个独立文件夹：

```
openspec/changes/
├── add-dark-mode/       ← 加暗色模式的改动
├── fix-login-bug/       ← 修登录 Bug 的改动
└── refactor-api/        ← API 重构的改动
```

**好处：**

1. **所有内容在一处**——提案、设计、任务、规范，不用到处找
2. **并行工作**——多个变更同时存在不冲突
3. **干净的历史**——归档后保留完整上下文，以后能看懂"为什么这么改"
4. **适合审查**——打开文件夹，看提案、查设计、读规范，一目了然

### 2.3 Delta Specs：增删改的"红笔标注"

**这是 OpenSpec 最核心的设计。**

Specs 不是重写，而是用**增量方式**描述变化。每个变更文件夹里的 spec 用三个标记描述改动：

```markdown
# Delta for UI（UI 领域的改动）

## ADDED Requirements（新增）
### Requirement: Theme Selection
The system SHALL allow users to choose between light and dark themes.

## MODIFIED Requirements（修改）
### Requirement: Session Timeout
The system SHALL expire sessions after 30 minutes of inactivity.
(Previously: 60 minutes)

## REMOVED Requirements（删除）
### Requirement: Remember Me
(Deprecated in favor of persistent sessions)
```

**归档时自动合并：**

| Delta 标记 | 归档动作 |
|---|---|
| **ADDED** | 追加到主 specs |
| **MODIFIED** | 替换主 specs 中的对应版本 |
| **REMOVED** | 从主 specs 中删除 |

**对应比喻：** 就像老师在图纸上用红笔标注——"这里加一扇窗"、"把这面墙改大"、"把这个房间去掉"。工程验收后，红笔标注正式更新到主蓝图。

### 2.4 Artifacts：4 份"施工文件"

每个变更包含 4 个 artifact，按依赖顺序生成：

```
proposal ──► specs ──► design ──► tasks ──► implement
   为什么     改什么     怎么做     步骤清单   动手
```

| Artifact | 文件 | 回答的问题 | 比喻 |
|----------|------|-----------|------|
| **Proposal** | `proposal.md` | 为什么要做？范围是什么？ | 业主的改建申请书 |
| **Specs** | `specs/*/spec.md` | 行为上有什么变化？ | 改动后的蓝图标注 |
| **Design** | `design.md` | 技术上怎么做？ | 工程师的施工图纸 |
| **Tasks** | `tasks.md` | 具体分几步？ | 工人的施工清单 |

**关键点：**

- 每一步依赖上一步的输出（proposal 完了才能写 specs）
- 但可以**随时回头修改**前面的 artifact（边做边学）
- Proposal 和 Specs 是"人看的"，Design 和 Tasks 是"AI/工程师看的"

### 2.5 Archive：归档即合并

```
/opsx:archive add-dark-mode
```

归档时做三件事：

1. 把 Delta specs 合并回主 specs
2. 整个文件夹移到 `changes/archive/2025-01-24-add-dark-mode/`
3. 保留完整的历史记录

**对应比喻：** 工程验收合格，把红笔标注正式描到蓝图上，施工申请单装订存档。以后翻档案就知道"某年某月某日加了个阳台，当时为什么加、怎么加的"。

### 2.6 Schema：定义你的工作流

**对应比喻：公司的"施工流程规范"**

Schema 决定了"有哪些 artifact、它们的依赖关系是什么"：

```yaml
artifacts:
  - id: proposal
    requires: []

  - id: specs
    requires: [proposal]      ← specs 必须等 proposal

  - id: design
    requires: [proposal]

  - id: tasks
    requires: [specs, design] ← tasks 要等两者都完成

apply:
  requires: [tasks]
```

你可以：
- **Fork 内置 schema**：`openspec schema fork spec-driven my-workflow`
- **从零创建**：`openspec schema init research-first`
- **添加任意 artifact**：比如 `review.md`（审查清单）、`security.md`（安全评估）
- **自定义模板**：在 `templates/` 目录下放 Markdown 模板，引导 AI 生成符合团队风格的内容

### 2.7 Profile：精简版 vs 完整版

| | Core Profile（默认） | Expanded Workflow（扩展模式） |
|---|---|---|
| **命令数** | 4 个 | 11 个 |
| **风格** | 一步到位 | 逐步确认 |
| **适合** | 个人快速开发 | 团队协作、精细控制 |

**开启方式：**
```bash
openspec config profile    # 选择 workflows
openspec update            # 更新 AI 指令
```

### 2.8 Context Injection：给 AI 注入项目知识

在 `openspec/config.yaml` 中配置：

```yaml
context: |
  Tech stack: TypeScript, React, Node.js, PostgreSQL
  API style: RESTful, documented in docs/api.md
  Testing: Jest + React Testing Library
  We value backwards compatibility for all public APIs

rules:
  proposal:
    - Include rollback plan
    - Identify affected teams
  specs:
    - Use Given/When/Then format
```

**对应比喻：** 新员工入职时给他的"项目手册"——告诉他公司用什么技术、有什么规矩、要注意什么。

### 2.9 Verify：三维度质量检查

```
/opsx:verify add-auth
```

| 维度 | 检查什么 | 通俗理解 |
|------|---------|---------|
| **Completeness（完整性）** | 所有任务做了吗？所有需求实现了吗？场景覆盖了吗？ | "活儿干完了没？" |
| **Correctness（正确性）** | 实现符合 spec 意图吗？边界情况处理了吗？ | "活儿干对了吗？" |
| **Coherence（一致性）** | 设计决策体现在代码里了吗？命名规范一致吗？ | "活儿干得漂亮吗？" |

**不会阻止归档**，但会暴露潜在问题，按 CRITICAL / WARNING / SUGGESTION 分类报告。

### 2.10 Explore：先踩点再动工

```
/opsx:explore
```

**不创建任何 artifact**，只是让 AI 调研代码库、分析问题、对比方案。想清楚了再 `/opsx:propose` 或 `/opsx:new` 正式开始。

**对应比喻：** 动工前先"踩点"——看看地基、量量尺寸、查查管线，想清楚再写申请书。

---

## 三、架构全景图

```
                    ┌─────────────────────────────────┐
                    │        openspec/                │
                    │                                 │
 ┌──────────────────┤   ┌───────────┐   ┌───────────┐ │
 │                  │   │  specs/   │   │ changes/  │ │
 │  事实来源         │   │ 现状蓝图  │   │ 施工申请  │ │
 │  系统当前行为     │   │           │   │           │ │
 │                  │   │ auth/     │   │ add-dark  │ │
 │                  │   │ payments/ │   │ fix-bug   │ │
 │                  │   │ ui/       │   │ ...       │ │
 └──────◄───────────┤   └───────────┘   └─────┬─────┘ │
        归档合并     └─────────────────────────┼───────┘
                                              │
                   每个变更包含                 │
             ┌──────┴──────┐                  │
             │  4 Artifacts │                  │
             │ proposal     │                  │
             │ specs (Δ)    │                  │
             │ design       │                  │
             │ tasks        │                  │
             └──────────────┘                  │
                   │                           │
             /opsx:new/propose                 │
             /opsx:continue/ff                 │
             /opsx:apply                       │
             /opsx:verify ─────────────────────┘
             /opsx:archive ──► 移入 archive/
                               Δ specs 合并回主 specs
```

---

## 四、完整命令参考

### 核心 Profile（4 个命令）

| 命令 | 作用 | 产出 |
|------|------|------|
| `/opsx:propose [name]` | 一步创建变更 + 生成所有规划产物 | proposal + specs + design + tasks |
| `/opsx:explore [topic]` | 探索性调研（不创建变更） | 分析结果、方案对比 |
| `/opsx:apply [name]` | 按任务清单实现代码 | 代码 + 勾选 tasks.md |
| `/opsx:archive [name]` | 归档完成变更，合并 specs | 变更移入 archive/ |

### 扩展 Workflow（额外 7 个命令）

| 命令 | 作用 | 适用场景 |
|------|------|----------|
| `/opsx:new [name]` | 创建变更空架子（不含产物） | 想逐步控制 |
| `/opsx:continue [name]` | 按依赖链逐个生成下一个产物 | 想每步审查 |
| `/opsx:ff [name]` | 快进：一次性生成所有产物 | 需求明确时加速 |
| `/opsx:verify [name]` | 三维度验证实现是否匹配规范 | 归档前质检 |
| `/opsx:sync [name]` | 合并 delta specs 到主 specs | 长期变更提前合并 |
| `/opsx:bulk-archive` | 批量归档多个变更 | 一次收拢多个完成项 |
| `/opsx:onboard` | 引导式完整工作流教程 | 新人上手 |

### CLI 终端命令（人机共用）

| 命令 | 用途 |
|------|------|
| `openspec init` | 初始化项目（交互式） |
| `openspec update` | 更新 AI 工具配置 |
| `openspec list` | 浏览变更和 specs |
| `openspec view` | 交互式仪表盘 |
| `openspec show <item>` | 查看具体内容 |
| `openspec validate` | 检查规范格式问题 |
| `openspec status` | 查看 artifact 进度 |
| `openspec config` | 查看和修改配置 |
| `openspec schema fork` | Fork 内置 schema |
| `openspec schema init` | 从零创建 schema |
| `openspec schema validate` | 验证 schema 正确性 |

---

## 五、典型工作流模式

### 模式 1：快速功能（最常见）

适合需求明确、范围清晰的中小型功能。

```
你: /opsx:new add-dark-mode
AI: Created openspec/changes/add-dark-mode/
    Ready to create: proposal

你: /opsx:ff
AI: ✓ Creating proposal.md
    ✓ Creating specs/ui/spec.md
    ✓ Creating design.md
    ✓ Creating tasks.md
    All planning artifacts complete!

你: /opsx:apply
AI: Working through tasks...
    ✓ 1.1 Create ThemeContext
    ✓ 1.2 Add CSS custom properties
    ...
    All tasks complete!

你: /opsx:verify
AI: Verifying add-dark-mode...
    COMPLETENESS  ✓
    CORRECTNESS   ✓
    COHERENCE     ⚠ Design mentions CSS variables but uses Tailwind

你: /opsx:archive
AI: ✓ Specs merged
    ✓ Archived change
```

### 模式 2：探索性工作流

适合需求模糊、需要先调研的场景。

```
你: /opsx:explore
AI: What would you like to explore?

你: 我想提升页面加载性能，但不确定瓶颈在哪

AI: [分析 bundle 大小、慢查询、渲染模式]
    发现三个瓶颈:
    1. 未优化的大图片
    2. ProductList 同步数据请求
    3. Context 变更导致的重复渲染
    哪个想先解决？

你: 先解决数据请求问题

你: /opsx:new optimize-product-list-fetching
你: /opsx:continue     ← 逐步生成，每步审查
AI: ✓ Created proposal.md
    Now available: specs, design

你: /opsx:continue
AI: ✓ Created specs/

你: /opsx:continue
AI: ✓ Created design.md
    ✓ Created tasks.md

你: /opsx:apply → /opsx:verify → /opsx:archive
```

**`/opsx:ff` vs `/opsx:continue` 的选择原则：**

| 场景 | 选 |
|------|---|
| 能清晰描述完整范围 | `/opsx:ff` 一步到位 |
| 边做边想、需要控制 | `/opsx:continue` 逐步确认 |
| 时间紧迫 | `/opsx:ff` |
| 复杂变更、需要审查每一步 | `/opsx:continue` |

### 模式 3：并行变更 + 切换

```
# 在做 add-dark-mode，被紧急 bug 打断

/opsx:new fix-login-redirect
/opsx:ff
/opsx:apply           ← AI 自动在 fix-login-redirect 上下文工作
/opsx:archive          ← 归档 bug 修复

# 切回暗色模式
/opsx:apply add-dark-mode    ← 指定变更名，自动恢复上下文
    [从上次中断的任务 2.3 继续]
```

### 模式 4：批量归档

```
/opsx:bulk-archive
→ Found 3 completed changes:
    ✓ add-dark-mode
    ✓ fix-login-redirect
    ✓ update-footer

  Checking for spec conflicts...
  ⚠ add-dark-mode and update-footer both touch specs/ui/

  Inspecting codebase to resolve...
  Both changes are implemented. Will apply in chronological order.
```

---

## 六、支持的工具生态

OpenSpec 兼容 **20+ AI 编码工具**，`openspec init` 会自动配置对应工具的 Skills 和 Commands：

| 工具 | 技能路径 | 命令路径 |
|------|---------|---------|
| **Claude Code** | `.claude/skills/` | `.claude/commands/opsx/` |
| **Cursor** | `.cursor/skills/` | `.cursor/commands/` |
| **Codex** | `.codex/skills/` | `$CODEX_HOME/prompts/` |
| **GitHub Copilot** | `.github/skills/` | `.github/prompts/` |
| **Gemini CLI** | `.gemini/skills/` | `.gemini/commands/` |
| **Windsurf** | `.windsurf/skills/` | `.windsurf/workflows/` |
| **Kiro** | `.kiro/skills/` | `.kiro/prompts/` |
| **OpenCode** | `.opencode/skills/` | `.opencode/commands/` |

还兼容：Amazon Q Developer、Cline、CodeBuddy、Continue、Crush、Trae、RooCode、Kilo Code、Qoder、Qwen Code 等。

非交互式配置：

```bash
openspec init --tools claude,cursor        # 指定工具
openspec init --tools all                   # 全部配置
openspec init --profile core                # 指定 profile
```

---

## 七、安装与快速上手

### 安装

```bash
npm install -g @fission-ai/openspec@latest
```

要求 Node.js 20.19.0 或更高。

### 初始化项目

```bash
cd your-project
openspec init
```

交互式向导会帮你：
1. 创建 `openspec/` 目录结构
2. 配置 AI 工具集成（自动检测已安装的工具）
3. 生成 `config.yaml`

### 开始第一个变更

```
你: /opsx:propose add-dark-mode

AI: Created openspec/changes/add-dark-mode/
    ✓ proposal.md — 为什么做、改什么
    ✓ specs/       — 需求和场景
    ✓ design.md    — 技术方案
    ✓ tasks.md     — 实施清单
    Ready for implementation!

你: /opsx:apply
AI: Implementing tasks...
    ✓ 1.1 Add theme context provider
    ✓ 1.2 Create toggle component
    ✓ 2.1 Add CSS variables
    ✓ 2.2 Wire up localStorage
    All tasks complete!

你: /opsx:archive
AI: Archived to openspec/changes/archive/2025-01-23-add-dark-mode/
    Specs updated. Ready for the next feature.
```

---

## 八、轻量级渐进策略（Progressive Rigor）

OpenSpec 不搞官僚主义，按风险级别选择 spec 精细度：

| 级别 | 适用场景 | 内容 |
|------|---------|------|
| **Lite（默认）** | 大部分变更 | 简短行为描述 + 清晰范围 + 几个验收检查 |
| **Full** | 跨团队/API 变更/安全隐私/迁移 | 完整 RFC 2119 格式 + 全面场景覆盖 |

**大部分变更保持 Lite 模式就够了。**

---

## 九、自定义 Schema 实战

### Fork 内置 schema

```bash
openspec schema fork spec-driven my-workflow
```

得到：

```
openspec/schemas/my-workflow/
├── schema.yaml           # 工作流定义
└── templates/
    ├── proposal.md       # 模板可自由修改
    ├── spec.md
    ├── design.md
    └── tasks.md
```

### 示例：添加审查环节

```yaml
# 在 schema.yaml 中新增
  - id: review
    generates: review.md
    description: Pre-implementation review checklist
    template: review.md
    instruction: |
      Create a review checklist based on the design.
      Include security, performance, and testing considerations.
    requires:
      - design

  - id: tasks
    requires:
      - specs
      - design
      - review    ← tasks 现在依赖 review
```

### 示例：极速迭代工作流

```yaml
name: rapid
version: 1
description: Fast iteration with minimal overhead

artifacts:
  - id: proposal
    requires: []
  - id: tasks
    requires: [proposal]

apply:
  requires: [tasks]
  tracks: tasks.md
```

只有 proposal 和 tasks 两步，跳过详细 spec 和 design，适合快速小修小改。

---

## 十、与其他 AI 开发框架的关系

### OpenSpec vs Superpowers

这两个框架互补而非竞争：

| | Superpowers | OpenSpec |
|---|---|---|
| **核心** | Skill 驱动的编码方法论 | Spec 驱动的变更管理框架 |
| **侧重** | AI 的工作纪律（TDD、Code Review、子代理） | 人和 AI 的对齐机制（先对齐再做） |
| **产物** | 设计文档 + 任务计划 + 代码 | Proposal + Spec + Design + Tasks |
| **适合场景** | 功能开发全流程自动化 | 需求管理、变更追踪、团队协作 |

**最佳组合：** OpenSpec 管"做什么"，Superpowers 管"怎么做"。OpenSpec 的 spec 可以作为 Superpowers brainstorming 阶段的输入，Superpowers 的 TDD 和 Code Review 可以保障 OpenSpec apply 阶段的代码质量。

---

## 十一、最佳实践总结

### 什么时候用 OpenSpec

| 场景 | 推荐度 | 说明 |
|------|--------|------|
| 团队协作的 AI 编码 | ⭐⭐⭐⭐⭐ | 避免 prompt 丢失上下文 |
| 中大型功能开发 | ⭐⭐⭐⭐⭐ | 需求对齐 + 变更追踪 |
| 遗留系统渐进改造 | ⭐⭐⭐⭐⭐ | brownfield-first 设计 |
| 需要审计追踪的项目 | ⭐⭐⭐⭐⭐ | 归档即历史 |
| 简单 Bug 修复 | ⭐⭐⭐ | 可能偏重，但 lite 模式够用 |
| 单文件小脚本 | ⭐⭐ | 可能过度工程化 |

### Context 管理建议

- 开始实现前**清空上下文窗口**（`/clear`）
- 实现过程中保持良好的上下文卫生
- 推荐模型：**Opus 4.5** 和 **GPT 5.2**（高推理能力模型效果更好）
- 每次 `npm update` 后运行 `openspec update` 刷新 AI 指令

### 何时更新变更 vs 开新变更

**更新现有变更：**
- 同一个意图，只是细化执行
- 范围缩小（先做 MVP）
- 学习驱动的修正（代码库不如预期）

**开新变更：**
- 意图根本改变
- 范围爆炸到完全不同的工作
- 原变更可以独立标记为"完成"

---

## 十二、总结

OpenSpec 回答了一个关键问题：

> **我们如何让 AI 编码变得可预测、可追溯、可协作？**

答案是：**用 Spec 作为人与 AI 之间的契约。**

它不追求大而全的流程，而是用极简的设计——一个文件夹、四个文件、增量规范——就把"需求变代码"这个过程变得可控。

几个令人印象深刻的设计决策：

1. **Delta Specs**：不重写规范，只用增/改/删标注变化，归档自动合并——这比"每次重写整个 spec"优雅得多
2. **变更即文件夹**：每个变更是一个自包含的目录，天然支持并行、天然适合 Code Review
3. **Actions, not phases**：命令是"你能做的事"，不是"你被卡住的阶段"——可以随时回头修改任何 artifact
4. **20+ 工具兼容**：不绑定特定 IDE 或模型，你用什么工具就配什么工具

如果你正在用 AI 工具写代码，OpenSpec 值得花 10 分钟安装试试。它不会改变你能做什么，但会让你和 AI 的协作质量上一个台阶。

---

## 相关链接

- **GitHub 仓库：** <https://github.com/Fission-AI/OpenSpec>
- **Getting Started：** <https://github.com/Fission-AI/OpenSpec/blob/main/docs/getting-started.md>
- **Concepts：** <https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md>
- **Workflows：** <https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md>
- **Commands：** <https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md>
- **Customization：** <https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md>
- **Discord 社区：** <https://discord.gg/YctCnvvshC>
- **npm 包：** <https://www.npmjs.com/package/@fission-ai/openspec>
