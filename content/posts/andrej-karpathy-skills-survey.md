---
title: "Andrej Karpathy Skills 调研报告"
date: 2026-04-21T00:20:00+08:00
draft: false
tags: ["AI编程", "Claude", "Karpathy", "编码规范", "CLAUDE.md"]
categories: ["技术"]
description: "基于 Karpathy AI 编程踩坑经验整理的四大原则及团队落地方案——Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven。"
---

### 📌 项目概况

- **仓库**: `forrestchang/andrej-karpathy-skills`（已迁移到 `multica-ai/andrej-karpathy-skills`）
- **来源**: 基于 Karpathy 在 X 上分享的 AI 编程助手踩坑经验，由社区整理为可落地的配置文件
- **热度**: GitHub Trending #1，一天内 9000+ stars
- **定位**: 一个 CLAUDE.md / .mdc 文件，约束 AI 编码助手的行为，减少常见错误

---

### 🔴 Karpathy 指出的三大核心问题

| 问题         | 原话                                                         | 后果                   |
| ------------ | ------------------------------------------------------------ | ---------------------- |
| **擅自假设** | "make wrong assumptions on your behalf and just run along with them" | 方向跑偏，返工         |
| **过度设计** | "overcomplicate code and APIs, bloat abstractions... 1000 lines when 100 would do" | 代码臃肿，维护成本高   |
| **越界修改** | "change/remove comments and code they don't sufficiently understand as side effects" | 破坏无关功能，引入回归 |

---

### ✅ 四大原则（可直接落地为团队规范）

#### 原则一：Think Before Coding（先想后写）

- **明确要求时再动手**——不确定就提问，不猜
- **多义场景列出多种理解**——不要默默选一种就干
- **敢于建议更简单的方案**——AI 应该 push back，不是盲从
- **遇到困惑停下来**——说清哪里不清楚，请求澄清

> **落地动作**：在 AI 编码助手的 system prompt / CLAUDE.md 中强制加入 "遇到歧义先提问" 的规则

#### 原则二：Simplicity First（极简优先）

- **不超出需求范围加功能**
- **单一用途代码不加抽象层**
- **不加未请求的"灵活性/可配置性"**
- **不为不可能发生的场景做错误处理**
- **能 50 行写完的不写 200 行**
- **检验标准**：资深工程师看了会不会说"太复杂了"？如果是，简化

> **落地动作**：Code Review  checklist 中增加"是否过度设计"检查项

#### 原则三：Surgical Changes（精准修改）

- **不"顺手改进"相邻代码、注释、格式**
- **不重构没坏的东西**
- **匹配现有代码风格**，即使你个人偏好不同
- **发现无关的死代码 → 提出来，别直接删**
- **自己的改动造成的孤儿代码（未使用的 import/变量/函数）→ 清理掉**
- **不主动清理别人留下的死代码**（除非被要求）
- **检验标准**：每一行改动都能追溯到用户的原始需求

> **落地动作**：PR diff 审查时，检查是否存在"越界修改"

#### 原则四：Goal-Driven Execution（目标驱动）

- **把命令式指令转为可验证的目标**

| 模糊指令 | 目标驱动写法                           |
| -------- | -------------------------------------- |
| "加校验" | "先写非法输入的测试用例，再让它们通过" |
| "修 bug" | "先写复现测试，再修到测试通过"         |
| "重构 X" | "重构前后确保测试全部通过"             |

- **多步骤任务写简短计划**：`[步骤] → 验证: [检查方式]`

> **落地动作**：所有 AI 辅助开发任务，用 TDD 方式描述需求，给出明确的 success criteria

---

### 🛠 具体实施方案

#### 方案 1：项目级规则文件（推荐起步）

在每个项目根目录放一个 `CLAUDE.md`（Claude Code）或 `.cursor/rules/karpathy-guidelines.mdc`（Cursor），内容包含四大原则。

**获取方式**：
```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

#### 方案 2：全局插件安装（Claude Code 用户）

```
/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills
```

安装后所有项目自动生效。

#### 方案 3：集成到 OpenClaw（我们的场景）

将四大原则写入 OpenClaw workspace 的 `AGENTS.md` 或子 agent 的 SKILL.md，让 tm-backend / tm-frontend 等子 agent 编码时自动遵循。

#### 方案 4：纳入 Code Review 流程

把四个原则提炼为 PR 模板中的检查项：
- [ ] 是否有未确认的假设？
- [ ] 是否存在过度设计/不必要的抽象？
- [ ] diff 是否只包含需求相关的改动？
- [ ] 是否有可验证的 success criteria？

---

### 📊 效果指标

按 repo 的说法，规范生效后会看到：
- Diff 中不必要的改动减少
- 因过度设计导致的重写减少
- 澄清性问题出现在编码之前，而非出错之后
- PR 更干净，没有"顺手重构"

---

### 💡 我的建议

1. **先把原则写进 OpenClaw 的全局指令**（AGENTS.md 或单独一份 `.claw.md`），让所有子 agent 编码时自动遵循
2. **SCRM/CMS/BI 等项目的 CLAUDE.md 中追加这些规则**，团队用 Cursor/Claude Code 的同事也能受益
3. **PR 模板加上四项检查**，人工 review 时也能对齐标准
