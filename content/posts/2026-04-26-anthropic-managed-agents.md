---
title: "Anthropic Managed Agents 架构深度调研：大脑与双手的解耦革命"
date: 2026-04-26T09:45:00+08:00
draft: false
tags: ["Anthropic", "Claude", "AI Agent", "MCP", "架构设计", "Managed Agents"]
categories: ["AI技术", "架构设计"]
description: "Anthropic 发布 Managed Agents 架构，核心思想是将 Agent 的「大脑」（Orchestration/决策层）与「双手」（Execution/执行层）解耦。Token 节省 98.7%，成为 AI Agent 架构的重大演进。"
---

## 📖 概述

### 发布背景

**发布时间**: 2025年  
**发布机构**: Anthropic  
**核心文章**: 《Scaling Managed Agents: Decoupling the brain from the hands》  
**配套论文**: 《Dive into Claude Code: The Design Space of Today's and Future AI Agent Systems》 (arXiv:2604.14228)

### 核心问题

Anthropic 在大规模部署 AI Agent 时发现传统架构的问题：

| 问题 | 描述 |
|------|------|
| ❌ Tool definitions overload | 工具定义过载上下文窗口 |
| ❌ Intermediate tool results | 中间工具结果消耗大量 tokens |
| ❌ Direct tool-calling | 直接工具调用效率低下 |
| ❌ Context management | 上下文管理复杂，容易出错 |

### 解决方案

```
Managed Agents 核心思想：
✅ Brain (大脑) = Orchestration Layer → 决策层：负责规划、编排、决策
✅ Hands (双手) = Execution Layer → 执行层：负责代码执行、工具调用
✅ Decoupling (解耦) = Separation of Concerns → 分离关注点
```

---

## 🧠 核心架构理念

### "大脑"与"双手"的定义

#### 大脑 (Brain / Orchestration Layer)

**职责**：
- 任务理解和分解
- 工具选择和编排
- 决策和规划
- 监控和调整
- 错误处理策略

**特点**：
- 基于 LLM 的智能决策
- 不直接执行工具调用
- 通过编写代码来指挥执行层
- 保持"纯净"，不处理具体数据

#### 双手 (Hands / Execution Layer)

**职责**：
- 代码执行
- 工具调用（通过 MCP）
- 数据处理和转换
- 结果返回
- 状态持久化

**特点**：
- 基于 Code Execution Environment
- 处理大量数据但不消耗 context
- 独立运行，可并行执行
- 提供安全沙箱环境

### 传统架构 vs Managed Agents

#### 传统架构（耦合）

```
┌─────────────────────────────────────────────┐
│  Agent (LLM)                                 │
│                                              │
│  ┌───────────┐    ┌───────────┐             │
│  │ Brain     │───▶│ Direct    │             │
│  │ (决策)    │    │ Tool Call │             │
│  └───────────┘    └───────────┘             │
│         │              │                    │
│         │              ▼                    │
│         │        ┌───────────┐              │
│         │        │ MCP Tool  │              │
│         │        │ Results   │──┐           │
│         │        └───────────┘  │           │
│         │                       │           │
│         └──────────Back to──────┘           │
│              Context Window                 │
└─────────────────────────────────────────────┘

问题：
- Tool definitions → Context (过载)
- Tool results → Context (膨胀)
- 每次调用都要经过 LLM
- Context window 容易耗尽
```

#### Managed Agents 架构（解耦）

```
┌─────────────────────────────────────────────┐
│  Brain Layer (LLM)                          │
│                                              │
│  ┌───────────────────────────────────┐      │
│  │ 1. Understand task                 │      │
│  │ 2. Plan execution                  │      │
│  │ 3. Write code                      │      │
│  │ 4. Send to Hands                   │      │
│  └───────────────────────────────────┘      │
│                    │                         │
│                    ▼                         │
│            ┌──────────────┐                  │
│            │ Code Output  │                  │
│            │ (Minimal)    │                  │
│            └──────────────┘                  │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  Hands Layer (Code Execution Environment)  │
│                                              │
│  ┌───────────────────────────────────┐      │
│  │ Execute code                       │      │
│  │ │                                  │      │
│  │ ├─▶ Load tools on-demand           │      │
│  │ ├─▶ Call MCP servers               │      │
│  │ ├─▶ Process data (in environment)  │      │
│  │ ├─▶ Filter/transform results       │      │
│  │ └─▶ Return minimal output          │      │
│  └───────────────────────────────────┘      │
│                    │                         │
│                    ▼                         │
│            ┌──────────────┐                  │
│            │ Minimal      │                  │
│            │ Result       │──┐               │
│            └──────────────┘  │               │
└─────────────────────────────┼───────────────┘
                              │
                              ▼
                      Back to Brain
                      (Only final result)

优势：
- Brain 只写代码，不处理数据
- Hands 执行代码，处理大量数据
- Context window 节省 98.7%
- Brain 保持"纯净"状态
```

---

## 🔧 技术实现详解

### 1. Model Context Protocol (MCP)

MCP 是 Anthropic 发布的开放协议，用于连接 AI Agent 到外部系统。

```
MCP 核心概念：

┌─────────────────────────────────────────────┐
│  MCP Architecture                           │
│                                              │
│  ┌───────────────┐    ┌───────────────┐     │
│  │ MCP Client    │───▶│ MCP Server    │     │
│  │ (Agent)       │    │ (Tool Provider)│     │
│  └───────────────┘    └───────────────┘     │
│         │                    │              │
│         │                    ▼              │
│         │             ┌───────────┐         │
│         │             │ Tools     │         │
│         │             │ Resources │         │
│         │             │ Prompts   │         │
│         │             └───────────┘         │
│         │                    │              │
│         └────────────────────┘              │
│                                              │
│  Universal Protocol:                        │
│  - Implement once                           │
│  - Unlock entire ecosystem                  │
│  - Standardized interface                   │
└─────────────────────────────────────────────┘

MCP Server 提供：
- Tools (工具调用)
- Resources (数据访问)
- Prompts (预定义模板)

社区已构建：
- 数千个 MCP servers
- 所有主流语言 SDK
- 成为行业标准
```

### 2. Code Execution with MCP

这是 Managed Agents 的核心技术实现。

#### 传统方式：直接工具调用

```python
# Brain 直接调用工具（传统方式）
# 问题：所有中间结果都要经过 context

TOOL CALL: gdrive.getDocument(documentId: "abc123")
 → returns "Discussed Q4 goals...\n[full transcript text]"
 → 50,000 tokens loaded into context

TOOL CALL: salesforce.updateRecord(
    objectType: "SalesMeeting",
    recordId: "00Q5f000001abcXYZ",
    data: { "Notes": "Discussed Q4 goals...\n[full transcript text]" }
)
 → Another 50,000 tokens through context

Total: 100,000+ tokens consumed
```

#### Managed Agents 方式：代码执行

```typescript
// Brain 编写代码，Hands 执行（Managed Agents）
// 优势：中间数据不经过 context

import * as gdrive from './servers/google-drive';
import * as salesforce from './servers/salesforce';

const transcript = (await gdrive.getDocument({ documentId: 'abc123' })).content;
await salesforce.updateRecord({
    objectType: 'SalesMeeting',
    recordId: '00Q5f000001abcXYZ',
    data: { Notes: transcript }
});

// Brain only sees:
// - Tool discovery: ~500 tokens
// - Code structure: ~1,000 tokens
// Total: ~1,500 tokens (节省 98.7%)
```

### 3. Progressive Disclosure（渐进式披露）

```
工具发现机制：

1. Brain 列出 ./servers/ 目录 → 发现可用 MCP servers
2. Brain 读取特定工具文件 → getDocument.ts, updateRecord.ts
3. Brain 理解接口定义 → 只加载需要的工具
4. Brain 编写代码 → Hands 执行

File Structure:
servers/
├── google-drive/
│   ├── getDocument.ts
│   ├── listFiles.ts
│   └── uploadFile.ts
│   └── index.ts
├── salesforce/
│   ├── updateRecord.ts
│   ├── query.ts
│   ├── createLead.ts
│   └── index.ts
└── ... (other servers)

Token Usage Comparison:
- Load all tools upfront: 150,000 tokens
- Load on-demand:         2,000 tokens
- Savings:                98.7%
```

### 4. Privacy-Preserving Operations

```
隐私保护机制：

┌─────────────────────────────────────────────┐
│  Data Flow                                  │
│                                              │
│  Google Sheets ──▶ MCP Client               │
│                     │                        │
│                     ├─▶ Tokenize PII        │
│                     │   [EMAIL_1]           │
│                     │   [PHONE_1]           │
│                     │                        │
│                     ▼                        │
│                 Code Execution               │
│                 (Hands Layer)                │
│                     │                        │
│                     ├─▶ Untokenize          │
│                     │   Real data           │
│                     │                        │
│                     ▼                        │
│                 Salesforce                   │
│                                              │
│  Brain (LLM) never sees real PII            │
│  Data flows directly, not through context   │
└─────────────────────────────────────────────┘

// Real data never enters model context
```

---

## 🔄 核心价值对比

### 传统架构 vs Managed Agents

| 特性 | 传统架构 | Managed Agents | 优势 |
|------|---------|----------------|------|
| **工具加载** | 全量 upfront | 按需 on-demand | Token 节省 98.7% |
| **执行方式** | 直接 tool call | Code execution | 更高效 |
| **数据处理** | 经过 context | 在 execution env | 隐私保护 |
| **中间结果** | 大量 tokens | 最小化输出 | 成本降低 |
| **并行执行** | 困难 | 容易 | 性能提升 |
| **状态持久化** | 无 | 内置 | 可恢复 |
| **可扩展性** | 受 context 限制 | 高度可扩展 | 更灵活 |
| **隐私保护** | 数据暴露 | Tokenization | 更安全 |
| **可复用性** | 无 | Skills 系统 | 持续进化 |

### 实测数据对比

| 场景 | 传统方式 | Managed Agents | 节省 |
|------|---------|----------------|------|
| Tool definitions | 150,000 tokens | 500 tokens | 99.7% |
| Intermediate results | 50,000 tokens | 处理在执行环境 | 100% |
| Total context usage | 200,000 tokens | 2,500 tokens | **98.7%** |
| 工具数量扩展 | 受限于 context | 无限扩展 | ∞ |

---

## ⚖️ 优势与挑战

### 优势

#### 1. Token 效率（节省 98.7%）

实测数据表明，Managed Agents 在处理大规模工作流时，Token 消耗从 200,000 降低到 2,500，节省 98.7%。

#### 2. 延迟降低

传统方式每次 tool call 都要经过 LLM，Managed Agents 的代码直接执行，只有最终结果返回给 Brain，大幅降低延迟。

#### 3. 无限可扩展

传统架构受限于 context window，Managed Agents 通过按需加载工具定义，支持无限扩展。

#### 4. 状态持久化

Skills 系统允许 Agent 持续进化，可以恢复中断的工作，积累能力。

#### 5. 隐私保护

自动 tokenization 确保 PII 数据不进入模型 context，数据在执行环境中直接流转。

### 挑战

#### 1. 基础设施复杂度

需要构建 secure execution environment、sandbox、监控系统等基础设施。

#### 2. 安全考量

Agent 生成的代码需要在沙箱中执行，需要 resource limits、filesystem/network access control。

#### 3. 代码生成质量

依赖 LLM 生成正确的可执行代码，需要完善的错误处理机制。

#### 4. 学习曲线

开发者需要理解 MCP protocol、Brain/Hands separation、Skills system 等新概念。

---

## 🌍 行业影响

### 1. MCP 成为行业标准

```
MCP 生态：
- 数千个 MCP servers 已构建
- 所有主流语言 SDK
- 主要 AI 公司采用
- De-facto standard for agent-tool connection

社区：
- GitHub: modelcontextprotocol/servers
- Discord: MCP community
- 活跃的开发者生态
```

### 2. 推动 Agent 架构演进

```
影响方向：

1. 从"Tool Calling"到"Code Execution" → 更高效的数据处理
2. 从"单一 Agent"到"分层架构" → Brain + Hands separation
3. 从"无状态"到"有状态" → Skills accumulation
4. 从"耦合"到"解耦" → Scalability improvements
```

### 3. Cloudflare Code Mode

Cloudflare 也发布了类似发现（"Code Mode"），核心洞察一致：
- LLMs are adept at writing code
- Code execution is more efficient
- Developers should leverage this

### 4. 学术研究推动

arXiv 论文《Dive into Claude Code: The Design Space of Today's and Future AI Agent Systems》提供了学术理论基础。

---

## 📚 参考文献

### 官方文档

1. **Anthropic 官方博客** - "Scaling Managed Agents: Decoupling the brain from the hands" - https://www.anthropic.com/engineering/managed-agents
2. **Anthropic 官方博客** - "Code execution with MCP: Building more efficient agents" - https://www.anthropic.com/engineering/code-execution-with-mcp
3. **Anthropic 官方博客** - "Building agents that reach production systems with MCP" - https://claude.com/blog/building-agents-that-reach-production-systems-with-mcp

### 学术论文

4. **arXiv 论文** - "Dive into Claude Code: The Design Space of Today's and Future AI Agent Systems" (2604.14228) - https://arxiv.org/pdf/2604.14228

### MCP 协议

5. **MCP 官方文档** - https://modelcontextprotocol.io/
6. **MCP Servers 仓库** - https://github.com/modelcontextprotocol/servers
7. **MCP SDKs** - https://modelcontextprotocol.io/docs/sdk

### Skills 系统

8. **Skills 文档** - https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview

### 社区分析

9. **Claude Directory** - "Claude Managed Agents" - https://www.claudedirectory.org/blog/blog-claude-managed-agents
10. **Anthem Creation** - "Claude Managed Agents: Anthropic AI" - https://anthemcreation.com/en/artificial-intelligence/claude-managed-agents-anthropic-ai/

---

## 🎯 总结

### 核心创新

```
Managed Agents 的三大创新：

1️⃣ 架构解耦
   - Brain (Orchestration) 与 Hands (Execution) 分离
   - 大脑不处理数据，双手不决策
   
2️⃣ Token 效率
   - Code execution 替代 direct tool calling
   - Progressive disclosure 按需加载
   - Token savings: 98.7%
   
3️⃣ 状态持久
   - Skills 系统积累能力
   - Agent 持续进化
   - 可恢复工作流
```

### 适用场景

```
最适合：
✅ 大规模工具集成 (1000+ tools)
✅ 数据密集型工作流
✅ 隐私敏感操作
✅ 复杂多步骤流程
✅ 需要状态持久化
✅ 并行执行需求

不太适合：
❌ 简单单一工具调用
❌ 轻量级 agent
❌ 无执行环境基础设施
```

### 实施建议

```
1. 评估基础设施 → 是否有 code execution 环境、是否支持 sandboxing
2. 选择 MCP servers → 从官方 servers 开始，逐步扩展生态
3. 构建 Skills 库 → 积累常用代码模式，创建 SKILL.md 文档
4. 安全配置 → 设置资源限制、配置 tokenization、监控执行环境
```

---

这是 AI Agent 架构的重大演进，值得深入研究和实践落地。