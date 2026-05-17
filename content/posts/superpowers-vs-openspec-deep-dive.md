---
title: "Superpowers vs OpenSpec 全景深度解析：从入门到高阶，AI 编程 Agent 的两种哲学"
date: 2026-04-20T01:30:00+08:00
draft: false
tags: ["AI编程", "Superpowers", "OpenSpec", "Agent开发", "SDD"]
categories: ["技术"]
description: "全面对比 Superpowers 与 OpenSpec 两大 AI 编程框架，涵盖入门教程、高阶技巧、11维差异分析，以及为什么它们可以互补而非互斥"
---

## 引言：AI 编程 Agent 的"三堵墙"

如果你认真用过 Claude Code、Cursor 或 GitHub Copilot，一定遇到过这三堵墙：

- **第一堵墙：需求理解偏差。** 你说"加个用户登录"，AI 选了 Session 方案，你想要的是 JWT。等你 review 代码才发现不对——Token 和时间都白烧了。
- **第二堵墙：工程纪律缺失。** AI 默认行为是"收到需求 → 直接写代码"。不建 Git 分支、不写测试、不做 Code Review。跑得快，但一出问题回滚就痛。
- **第三堵墙：设计决策流失。** 为什么选 bcrypt 不选 argon2？为什么 API 前缀用 `/api` 而不是 `/v1`？Chat 一关，这些决策全忘了。迭代三次后，没人能还原最早的 trade-off。

这三个问题无法靠"更好的 Prompt"解决——它们需要不同层面的工具。

2025 年底到 2026 年初，两个解决这些问题的开源框架迅速走红：

| 项目 | 作者 | GitHub Stars | 定位 |
|------|------|-------------|------|
| **Superpowers** | Jesse Vincent (Prime Radiant) | 140,000+ | Agentic Skills 框架 + 软件研发方法论 |
| **OpenSpec** | Fission AI | 110,000+ | Spec-Driven Development (SDD) 规范驱动框架 |

它们解决的是不同的问题。理解它们的差异、互补关系、以及各自能做到对方做不到的事，是这篇文章的目标。

---

## Part 1：Superpowers 深度解读

### 1.1 什么是 Superpowers？

Superpowers 是一个**完整的软件研发生命周期工作流**，由 14 个可组合的"Skill"组成，安装到 Claude Code、Cursor、Codex、Gemini CLI 等 AI 编程 Agent 中，**强制**它们遵循最佳工程实践。

用作者 Jesse Vincent 的话说：

> "它从你启动编程 Agent 的那一刻开始生效。当你说要构建某个功能时，它不会直接跳到写代码——而是先退一步，问你真正想做什么。"

### 1.2 四大核心哲学原则

| 原则 | 含义 |
|------|------|
| **测试驱动开发** | 永远先写测试，后写实现 |
| **系统性优于随机性** | 用系统化流程替代"凭感觉改代码" |
| **复杂度削减** | 简单性是首要目标（YAGNI 原则） |
| **证据优于断言** | 验证优先，没跑过测试就不算完成 |

### 1.3 14 个核心 Skill 一览

**测试类**
- `test-driven-development`：RED-GREEN-REFACTOR 循环，强制先写测试

**调试类**
- `systematic-debugging`：四阶段根因分析流程
- `verification-before-completion`：确保真的修好了，验证优先

**协作类**
- `brainstorming`：苏格拉底式需求澄清，通过问答精炼设计
- `writing-plans`：详细实现计划，每个任务 2-5 分钟粒度
- `executing-plans`：批量执行计划，人工检查点
- `dispatching-parallel-agents`：并行子 Agent 工作流
- `requesting-code-review`：预审查清单
- `receiving-code-review`：如何响应代码审查反馈
- `using-git-worktrees`：使用 Git Worktree 创建隔离开发环境
- `finishing-a-development-branch`：分支完成工作流（合并/PR/保留/放弃）
- `subagent-driven-development`：快速迭代 + 两阶段审查（规范合规性 + 代码质量）

**元技能**
- `writing-skills`：创建新 Skill 的最佳实践指南
- `using-superpowers`：Skill 系统入口

### 1.4 Skill 触发机制：不是"建议"，是"强制规则"

这是 Superpowers 最独特的设计：

> **强制调用规则**：哪怕只有 1% 的可能性某个 Skill 适用，AI Agent 也必须调用它。这不是可选项，不可协商，不可"合理化"跳过。

Skill 触发优先级：
1. 流程类 Skill 优先（如 brainstorming、debugging）——确定如何处理任务
2. 实现类 Skill 其次（如 frontend-design）——指导具体执行

### 1.5 完整开发工作流

当你对装了 Superpowers 的 Agent 说"来做个新功能"时：

```
用户请求
  ↓
brainstorming（苏格拉底式问答澄清需求）
  ↓
using-git-worktrees（创建隔离分支环境）
  ↓
writing-plans（拆解为 2-5 分钟粒度的任务）
  ↓
subagent-driven-development（子 Agent 驱动开发）
  ├─ Controller Agent：读计划、协调实施
  ├─ Implementer Agent：写代码和测试
  └─ Reviewer Agent：客观第三方代码审查
  ↓
test-driven-development（RED → GREEN → REFACTOR）
  ↓
requesting-code-review（任务间自动审查）
  ↓
finishing-a-development-branch（合并/PR/保留/放弃）
```

**每一步都是自动触发的，不需要手动干预。**

### 1.6 安装指南

**Claude Code（官方插件市场）：**
```bash
/plugin install superpowers@claude-plugins-official
```

**Claude Code（第三方市场）：**
```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**Cursor Agent：**
```bash
/add-plugin superpowers
```

**Codex：** 在侧边栏 Plugins 中找到 Superpowers，点击 + 安装。

**Gemini CLI：**
```bash
gemini extensions install https://github.com/obra/superpowers
# 更新：
gemini extensions update superpowers
```

**OpenCode：** 获取并执行安装指令：
```
https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

安装后，下次启动 Agent 时会看到 "You have Superpowers" 确认信息。

---

## Part 2：Superpowers 从入门到高阶

### 2.1 入门：5 分钟体验

安装后，直接对 Agent 说：

> "我想做一个用户认证 API，用 Express + MongoDB + JWT"

Superpowers 会自动触发 `brainstorming`，问一系列问题：
- 需要哪些认证方式？（用户名+密码？OAuth？短信验证码？）
- JWT 的过期时间是多少？
- 密码加密选什么算法？
- 现有的用户体系怎么兼容？

回答完问题后，它会自动创建 Git Worktree、生成详细实现计划，然后等你确认后开始执行。

### 2.2 进阶：TDD 的强制力量

Superpowers 的 TDD 不只是"建议先写测试"——它**强制**执行 RED-GREEN-REFACTOR 循环：

1. **RED**：写一个失败的测试（此时实现代码还不存在）
2. **GREEN**：写刚好能让测试通过的最少代码
3. **REFACTOR**：重构代码，保持测试绿色
4. **Code Review**：自我审计

如果你先写了实现代码再补测试，Superpowers 会**删除你写的实现代码**，让你从头来。这不是商量，是规则。

### 2.3 高阶：Subagent-Driven Development

Superpowers 最强大的能力之一是子 Agent 驱动开发：

```
┌─────────────┐
│ Controller  │ 读取计划、协调任务
└──────┬──────┘
       ▼
┌─────────────┐
│ Implementer │ 编写代码和测试（隔离环境）
└──────┬──────┘
       ▼
┌─────────────┐
│ Reviewer    │ 客观的第三方代码审查
└─────────────┘
```

这种架构允许 AI **自主工作数小时而不偏离计划**。每个任务完成后自动进行两阶段审查：
1. **规范合规性审查**：代码是否符合计划中的设计？
2. **代码质量审查**：代码质量是否达标？

严重问题会**阻塞进度**，不允许继续。

### 2.4 专家级：Skill 自定义与组合

Superpowers 提供了 `writing-skills` 元技能，教你如何创建自定义 Skill。每个 Skill 是一个 Markdown 文件，包含：
- 触发条件（什么时候使用这个 Skill）
- 工作流图（逐步如何执行）
- 快速参考表（要点）
- 常见错误警告（Red Flags）

这意味着你可以为团队定制专属的工作流约束。

---

## Part 3：OpenSpec 概述

### 3.1 什么是 OpenSpec？

OpenSpec 是由 Fission AI 开发的**轻量级规范驱动开发（SDD）框架**。核心理念是：

> 在 AI 写代码之前，先就"要构建什么"达成一致。

它将一句话需求转化为四个结构化文档：

| 文档 | 内容 |
|------|------|
| `proposal.md` | 为什么做、做什么、**不做什么**（防止 AI 擅自加功能） |
| `specs/` | 行为规格说明，使用 GIVEN/WHEN/THEN 场景描述 |
| `design.md` | 技术决策及其理由 |
| `tasks.md` | 实现清单，每个任务 2-5 分钟可完成 |

### 3.2 工作流

```
/opsx:new add-dark-mode        ← 创建变更
  ↓
/opsx:ff                        ← "fast-forward"，自动生成全部规划文档
  ↓
/opsx:apply                     ← AI 按 spec 实施
  ↓
/opsx:archive                   ← 归档变更，更新主 spec
```

### 3.3 核心创新：Delta Spec 系统

这是 OpenSpec 最独特的设计：

- 每次变更只记录**增量**（delta spec），描述什么变了
- 变更批准后，delta 会同步回主 spec
- 归档后，完整的历史可追溯

```
# 主 spec 示例
## Requirement: Session expiration
- The system SHALL expire sessions after 24 hours.

# Delta spec（变更）
## Requirement: Session expiration
- The system SHALL expire sessions after a configured duration.
+ The system SHALL support configurable session expiration periods.
```

### 3.4 安装

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init    # 选择你的 AI 助手
```

### 3.5 支持的工具

OpenSpec 支持 **20+ AI 编程助手**：Claude Code、Cursor、GitHub Copilot、Windsurf、RooCode、Cline、Amazon Q、Codex 等。

---

## Part 4：Superpowers vs OpenSpec —— 11 维深度对比

经过对两个框架的实际研究和对比，以下是核心差异：

| 维度 | OpenSpec | Superpowers |
|------|----------|-------------|
| **核心定位** | 变更管理（Change Management） | 代码质量（Code Quality） |
| **解决的问题** | "我们为什么做这个变更？" | "这段代码是否正确？" |
| **TDD** | 可选（依赖开发者自律） | **强制**（RED-GREEN-REFACTOR） |
| **多 Agent** | 不支持（单 Agent） | 支持（3+ Agent 协作） |
| **Spec 存储** | 独立 `specs/` 目录，按能力组织 | 嵌入 `design.md`，保存在 `docs/superpowers/specs/` |
| **Git 集成** | 手动管理 | 自动 Git Worktree 隔离 |
| **代码审查** | 自查清单 | 子 Agent 客观审查 |
| **平台支持** | 任意 AI 助手（20+） | 仅支持子 Agent 能力的平台 |
| **Token 效率** | 高（单 Agent） | 较低（多 Agent 消耗大） |
| **变更审计链** | 完整（proposal → design → spec → archive） | 部分（plan → PR） |
| **上手时间** | 5 分钟 | 10-15 分钟 |

### 4.1 本质区别一句话

- **OpenSpec = 决策历史学家**：记录每一个"为什么"
- **Superpowers = 质量执法者**：确保每一个"怎么做"都正确

---

## Part 5：Superpowers 能做到而 OpenSpec 做不到的事

这是选型时最关键的部分。以下 6 项能力是 OpenSpec **天然不具备**的：

### 5.1 强制 TDD（RED-GREEN-REFACTOR）

OpenSpec 只说"去实现"，不约束你怎么写代码。你可以跳过测试直接写实现——框架不会阻拦。

Superpowers 的 TDD 是**强制性的**。如果你先写实现代码，它会删掉你的代码，让你先写测试。这种纪律性保证从第一天起就有 85-95% 的测试覆盖率。

### 5.2 多 Agent 并行开发

Superpowers 的 `dispatching-parallel-agents` 和 `subagent-driven-development` 允许同时派出多个子 Agent 并行工作。每个子 Agent 在隔离环境中独立完成任务，然后由 Controller 和 Reviewer 协调。

OpenSpec 是单 Agent 模型——一个 Agent 负责所有工作。

### 5.3 客观的第三方代码审查

Superpowers 的 Reviewer Agent 是**客观的、第三方的**代码审查者。它没有"这是我的代码"的心理包袱，能发现自审时忽略的问题。严重问题会**阻塞进度**。

OpenSpec 只有自查清单，依赖开发者的自律和人类的 Code Review。

### 5.4 自动 Git Worktree 隔离

每次变更都在独立的 Git Worktree 中进行。如果方向错了，直接丢弃 Worktree——主分支毫发无损。

OpenSpec 需要你手动管理 Git 分支纪律。

### 5.5 系统化调试

Superpowers 的 `systematic-debugging` 提供四阶段根因分析流程：
1. 确认症状
2. 缩小范围
3. 定位根因
4. 修复并验证

而不是"凭感觉改代码，改到能跑就行"。

OpenSpec 没有内置的调试方法论。

### 5.6 自我进化的 Skill 系统

Superpowers 提供了 `writing-skills` 元技能，允许你创建自定义 Skill 来定义团队的专属工作流。这意味着你可以持续扩展框架的能力边界。

OpenSpec 的工作流是固定的（proposal → design → spec → tasks → apply → archive）。

---

## Part 6：OpenSpec 能做到而 Superpowers 做不到的事

公平起见，反过来看：

### 6.1 完整的变更审计链

OpenSpec 的 `proposal → design → spec → archive` 链路，让每一次变更都有完整的历史记录。三个月后有人问"为什么这里选 bcrypt？"，你可以翻到 archived 的变更文档，看到当时的决策理由。

Superpowers 的 `design.md` 只保留最新的设计文档。多次迭代后，最早的 trade-off 决策就消失了。

### 6.2 Delta Spec 知识库

OpenSpec 的 spec 按**能力**组织，不是按**功能**。你可以查询"认证系统是怎么工作的"，主 spec 会给你一个完整答案。这对新成员 onboarding 和团队知识传承至关重要。

Superpowers 没有独立的可查询 spec 知识库。

### 6.3 平台无关性

OpenSpec 支持 20+ AI 编程助手——Claude Code、Cursor、GitHub Copilot、Windsurf、RooCode 等，**不限平台**。

Superpowers 仅支持具有子 Agent 能力的平台（Claude Code、Cursor、Codex、Gemini CLI）。如果你用的是 ChatGPT 或普通的 GitHub Copilot，无法使用。

### 6.4 Token 效率

OpenSpec 是单 Agent 工作流，Token 消耗少。Superpowers 的多 Agent 架构会让 Token 消耗增加 2-3 倍。

---

## Part 7：能不能一起用？—— 三重栈实践

**可以。** 事实上，很多人正在同时使用 Claude Code + OpenSpec + Superpowers：

```
Layer 1: OpenSpec        ← 需求层（WHAT & WHY）
         proposal.md / specs/ / design.md / tasks.md
           ↓
Layer 2: Superpowers     ← 纪律层（HOW）
         TDD / Code Review / Debugging / Worktree
           ↓
Layer 3: Claude Code     ← 执行层
         写代码 / 跑测试 / 管 Git / 派子 Agent
```

**分工明确**：
- OpenSpec 负责**规划阶段**：想清楚 WHAT 和 WHY
- Superpowers 负责**编码阶段**：确保 HOW 做得好
- Claude Code 负责**执行**：动手干活

**关键配置**：它们不会自动协作。需要在 `CLAUDE.md` 中显式配置：

```
For any new feature, start with /opsx:propose; skip brainstorming/writing-plans.

When using /opsx:apply, always follow TDD:
write failing tests first, then implement code.
```

否则你会得到两份不同步的设计文档——OpenSpec 的 `proposal.md` 和 Superpowers 的 `design.md`——很快就会出现冲突。

---

## Part 8：选型决策树

```
开始
 │
 ├─ 你的平台支持子 Agent 调度吗？
 │  ├─ 否 → OpenSpec（唯一选择）
 │  └─ 是 → 继续
 │
 ├─ 是全新项目（greenfield）？
 │  ├─ 是 → Superpowers（天生适合新项目）
 │  └─ 否 → 继续
 │
 ├─ 需要严格的 TDD 强制？
 │  ├─ 是 → Superpowers
 │  └─ 否 → 继续
 │
 ├─ 需要长期的 spec 知识库？
 │  ├─ 是 → OpenSpec
 │  └─ 否 → 继续
 │
 ├─ 团队需要变更审计链？
 │  ├─ 是 → OpenSpec
 │  └─ 否 → Superpowers（更快迭代）
 │
 └─ Token 预算紧张？
    ├─ 是 → OpenSpec（单 Agent）
    └─ 否 → Superpowers（多 Agent 质量更高）
```

---

## Part 9：实际场景推荐

### 选 OpenSpec 的场景

- **金融/医疗/合规行业**：每次变更必须有审计痕迹
- **大型团队（10+ 人）**：需要 spec 知识库来对齐认知
- **存量项目（brownfield）**：增量引入 SDD，不需要重写
- **平台受限**：只用 GitHub Copilot 或 ChatGPT
- **Token 预算紧张**

### 选 Superpowers 的场景

- **全新项目（greenfield）**：从零开始，需要严格工程质量
- **有 TDD 要求的团队**：或者想要建立 TDD 文化
- **使用 Claude Code / Cursor**：具备子 Agent 能力
- **代码质量 > spec 文档**：更关注代码正确性

### 最佳实践：三者合一

- **复杂项目 + 高质量要求 + 有预算**：Claude Code + OpenSpec + Superpowers
- OpenSpec 管需求，Superpowers 管纪律，Claude Code 管执行
- 这是目前 AI 辅助开发的最强组合

---

## 总结

OpenSpec 和 Superpowers 不是竞争对手，而是**解决不同问题的互补工具**。

- 如果你的痛点是"AI 做出来的不是我想要的"——选 **OpenSpec**
- 如果你的痛点是"AI 写的代码质量不可控"——选 **Superpowers**
- 如果两个都是痛点——**两个都用**

2026 年的 AI 编程已经过了"写个 Prompt 就能交付"的 Vibe Coding 阶段。未来的工程实践，一定是有纪律、有规范、可追溯的。这两个框架，就是通往那个未来的两条路——或者说，一条路的两段。

---

## 参考资源

- [Superpowers GitHub](https://github.com/obra/superpowers)
- [Superpowers 官方文档](https://lzw.me/docs/opencodedocs/obra/superpowers/start/superpowers-intro/)
- [OpenSpec 官网](https://openspec.pro/)
- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [DeepWiki: Superpowers](https://deepwiki.com/obra/superpowers)
- [Claude Code + OpenSpec + Superpowers 三重栈实践](https://www.heyuan110.com/posts/ai/2026-04-09-claude-code-openspec-superpowers/)
