---
title: "cc-haha 教程：基于泄露 Claude Code 源码的本地可运行版本"
date: 2026-04-19T22:43:00+08:00
draft: false
tags: ["cc-haha", "Claude Code", "AI", "编程助手", "教程", "开源项目"]
categories: ["技术"]
description: "cc-haha 项目完整教程：安装配置、功能使用、多 Agent 系统、记忆系统、Channel 远程驱动等"
---

# cc-haha 教程：基于泄露 Claude Code 源码的本地可运行版本

## 项目简介

**cc-haha**（Claude Code Haha）是一个基于 2026-03-31 从 Anthropic npm registry 泄露的 Claude Code 源码修复后发布的本地可运行版本。它解决了原始泄露代码中的关键问题，使 Claude Code 能够脱离 Anthropic 内部基础设施，在本地环境中完整运行。

| 维度 | 内容 |
|------|------|
| GitHub | https://github.com/NanmiCoder/cc-haha |
| 作者 | NanmiCoder（杨） |
| 运行时 | Bun |
| 语言 | TypeScript |
| 终端 UI | React + Ink |
| 桌面端 | Tauri 2 + React |
| 协议 | MCP, LSP |

> ⚠️ **声明**：本项目基于泄露的源码，所有原始代码版权归 Anthropic 所有，仅限学习和研究用途。

---

## 一、环境准备

### 1.1 安装 Bun（必须）

**macOS / Linux：**

```bash
curl -fsSL https://bun.sh/install | bash
```

**macOS（Homebrew）：**

```bash
brew install bun
```

**Windows（PowerShell）：**

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

**精简版 Linux** 如果提示 `unzip is required`，先运行：

```bash
apt update && apt install -y unzip
```

### 1.2 克隆项目

```bash
git clone https://github.com/NanmiCoder/cc-haha.git
cd cc-haha
```

### 1.3 安装依赖

```bash
bun install
```

---

## 二、配置与启动

### 2.1 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件，填写你的 API Key：

```bash
# 必填：Anthropic API Key 或 Auth Token
ANTHROPIC_API_KEY=your-api-key-here

# 可选：自定义 API 端点（接入 OpenRouter、MiniMax、Ollama 等）
ANTHROPIC_BASE_URL=https://api.example.com/v1

# 可选：指定模型
ANTHROPIC_MODEL=claude-sonnet-4-20250514

# 可选：关闭遥测和非必要网络请求
DISABLE_TELEMETRY=1
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

### 2.2 启动方式

#### 方式一：交互 TUI 模式

```bash
./bin/claude-haha
```

获得与官方 Claude Code 一致的终端交互界面。

#### 方式二：无头模式（Headless）

```bash
./bin/claude-haha -p "your prompt here"
```

适用于脚本调用和 CI/CD 场景。

#### 方式三：查看帮助

```bash
./bin/claude-haha --help
```

#### 方式四：降级 Recovery CLI 模式

当 TUI 出现问题时，使用简化 CLI 模式：

```bash
CLAUDE_CODE_FORCE_RECOVERY_CLI=1 ./bin/claude-haha
```

### 2.3 Windows 运行

Windows 需要 Git for Windows 环境：

```powershell
# PowerShell / cmd
bun --env-file=.env ./src/entrypoints/cli.tsx

# Git Bash
./bin/claude-haha
```

> ⚠️ 注意：语音输入、Computer Use 和 Sandbox 隔离功能在 Windows 上不可用。

### 2.4 全局使用

将 `bin/` 目录加入 PATH，即可在任意目录启动：

```bash
export PATH="$HOME/path/to/cc-haha/bin:$PATH"

# 之后任意目录直接运行
claude-haha
```

详见项目内的 [全局使用指南](docs/guide/global-usage.md)。

---

## 三、核心功能详解

### 3.1 多 Agent 系统

cc-haha 内置了多代理编排能力，支持并行任务执行和 Teams 协作。

**使用指南：** 参考 `docs/agent/01-usage-guide.md`

**实现原理：** 参考 `docs/agent/02-implementation.md`

核心能力：
- 多代理并行执行任务
- 代理间的协调与通信
- 任务分发和结果聚合
- Teams 协作模式

### 3.2 记忆系统

支持跨会话持久化记忆，让 Agent 能够记住上下文和历史对话。

**使用指南：** 参考 `docs/memory/01-usage-guide.md`

核心能力：
- 会话间记忆持久化
- 跨项目上下文记忆
- 自动记忆检索和应用

### 3.3 Skills 系统

可扩展的能力插件系统，支持自定义工作流和条件激活。

**使用指南：** 参考 `docs/skills/01-usage-guide.md`

**实现原理：** 参考 `docs/skills/02-implementation.md`

核心能力：
- 插件化扩展能力
- 自定义工作流定义
- 条件触发激活
- 与 OpenClaw 的 Skills 体系设计思路相似

### 3.4 Channel 系统

通过 IM 平台远程控制 Agent 的核心特色功能。

**架构解析：** 参考 `docs/channel/01-channel-system.md`

支持的通道：
- **Telegram** — 通过 Telegram Bot 远程控制
- **飞书** — 通过飞书 Bot 远程控制
- **Discord** — 通过 Discord Bot 远程控制

这个设计与 OpenClaw 的 Channel 体系非常相似，实现了：
- 在任意地点通过手机/电脑 IM 发送指令
- Agent 接收指令后执行编码任务
- 实时返回执行结果和进度

### 3.5 Computer Use 桌面控制

让 Agent 直接操控你的桌面——截屏、移动鼠标、点击、键盘输入。

**功能指南：** 参考 `docs/features/computer-use.md`

**架构解析：** 参考 `docs/features/computer-use-architecture.md`

核心能力：
- 屏幕截图获取
- 鼠标移动与点击
- 键盘输入模拟
- 跨平台支持（macOS / Windows）

> ⚠️ Windows 上部分功能不可用。

### 3.6 桌面端客户端

基于 Tauri 2 + React 构建的图形化客户端，支持多标签多会话。

**文档入口：** 参考 `docs/desktop/`

- [快速上手](docs/desktop/01-quick-start.md)
- [架构设计](docs/desktop/02-architecture.md)
- [安装指南](docs/desktop/04-installation.md)

#### 桌面端开发模式

```bash
# 先启动 API 服务端
cd /path/to/cc-haha
SERVER_PORT=3456 bun run src/server/index.ts

# 可选自检
curl http://127.0.0.1:3456/health

# 启动桌面前端
cd desktop
bun run dev --host 127.0.0.1 --port 2024

# 浏览器打开
# http://127.0.0.1:2024
```

**注意事项：**
- 如果 3456 端口被占用，先 `lsof -nP -iTCP:3456 -sTCP:LISTEN` 找到 PID 再 kill
- 测试聊天时建议新建 session 并选择真实存在的工作目录
- 旧 session 绑定的目录已被删除会返回 `Working directory does not exist`

---

## 四、接入第三方模型

cc-haha 不限于 Anthropic 模型，可以通过配置接入多种第三方模型。

**使用指南：** 参考 `docs/guide/third-party-models.md`

支持的模型提供商：
- OpenAI
- DeepSeek
- Ollama（本地模型）
- OpenRouter
- MiniMax
- 以及其他兼容 Anthropic API 格式的服务

配置示例：

```bash
ANTHROPIC_BASE_URL=https://openrouter.ai/api/v1
ANTHROPIC_MODEL=openai/gpt-4
ANTHROPIC_API_KEY=your-openrouter-key
```

---

## 五、MCP 服务器集成

支持 MCP（Model Context Protocol）服务器，可以接入外部工具和服务：

```bash
# 在配置中定义 MCP 服务器
# 详见项目文档中的 MCP 配置指南
```

---

## 六、常见问题排查

**参考文档：** `docs/guide/faq.md`

### TUI 启动失败
- 检查 Bun 版本是否满足要求
- 尝试 Recovery CLI 模式：`CLAUDE_CODE_FORCE_RECOVERY_CLI=1 ./bin/claude-haha`

### 输入无响应
- 确认终端支持交互式输入
- Windows 建议使用 Git Bash

### API 调用失败
- 检查 `.env` 中 API Key 是否正确
- 确认 `ANTHROPIC_BASE_URL` 格式正确
- 尝试 `DISABLE_TELEMETRY=1` 关闭非必要网络请求

### 端口冲突
```bash
# 查找占用端口的进程
lsof -nP -iTCP:3456 -sTCP:LISTEN
# 杀掉进程后重启
```

---

## 七、项目架构概览

### 技术栈

| 层级 | 技术 |
|------|------|
| 运行时 | Bun |
| 语言 | TypeScript |
| 终端 UI | React + Ink |
| CLI 解析 | Commander.js |
| API | Anthropic SDK |
| 协议 | MCP, LSP |
| 桌面端 | Tauri 2 + React |

### 目录结构

详见 `docs/reference/project-structure.md`。

### 修复记录

相对于原始泄露源码的修复内容，详见 `docs/reference/fixes.md`。

---

## 八、与 OpenClaw 的对比

| 维度 | cc-haha | OpenClaw |
|------|---------|----------|
| **定位** | AI 编码助手 | 通用个人助理 |
| **核心场景** | 代码编写、调试、重构 | 消息管理、设备控制、自动化 |
| **Channel 系统** | Telegram/飞书/Discord | Telegram/WhatsApp/Discord 等 |
| **桌面控制** | Computer Use（截屏+键鼠） | Node 设备控制 |
| **多 Agent** | 内置多 Agent 编排 | 支持子 Agent 和 ACP 运行时 |
| **扩展机制** | Skills + MCP | Skills + 插件 |
| **开源协议** | 基于泄露源码（学习用途） | 开源项目 |

两者在架构设计上有不少相似之处，特别是 Channel 远程驱动和 Skills 扩展体系。

---

## 九、总结

cc-haha 是目前社区中**最完整的 Claude Code 本地运行方案**，在原始泄露代码的基础上做了大量修复和增强工作：

1. **完整 TUI** — 与官方一致的交互体验
2. **多 Agent** — 并行任务编排和协作
3. **记忆系统** — 跨会话上下文保持
4. **Channel 远程** — 通过 IM 随时随地驱动编码
5. **Computer Use** — Agent 直接操控桌面
6. **桌面客户端** — Tauri 2 + React 图形化界面
7. **第三方模型** — 不绑定 Anthropic，灵活接入

对于想深入了解 Claude Code 架构实现的开发者来说，这个项目是最直观的学习材料。但需要注意法律风险，仅限学习研究，不建议商用。

---

**参考资料:**
- GitHub: https://github.com/NanmiCoder/cc-haha
- DeepWiki: https://deepwiki.com/NanmiCoder/cc-haha
- SourcePulse: https://www.sourcepulse.org/projects/27254191
