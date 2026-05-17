---
title: "Printing Press CLI 最佳实践：6 个 Agent 原生工具的实战指南"
date: 2026-05-09T02:08:00+08:00
draft: false
tags: ["CLI", "AI Agent", "Printing Press", "开发工具", "最佳实践"]
categories: ["技术"]
description: "一站式安装 6 个 Printing Press CLI，从配置到实战场景，涵盖公司信息调研、技术社区检索、航班查询、项目管理和网页抓取。"
---

## 前言

[Printing Press](https://printingpress.dev/) 是一个面向 AI Agent 的 CLI 工厂——它能把任意 API 封装成 **token-efficient 的命令行工具**，同时支持 Go CLI、Claude Code Skill、OpenClaw Skill 和 MCP Server 四种输出格式。

它的核心设计理念源于 Peter Steinberger 的 discrawl 和 gogcli 项目：

- **本地 SQLite 镜像** > 远程 API 调用（降低延迟、节省 token）
- **复合命令** > 十次来回请求（一次调用完成多步操作）
- **Agent-native 输出** > 裸 HTTP 响应（结构化、无颜色、零交互）

本文基于我实际安装的 6 个 CLI——**company-goat、hackernews、wikipedia、flight-goat、linear、firecrawl**——从安装、配置到实战场景，写一份完整的使用指南。

---

## 一键安装所有 CLI

Printing Press 的安装器基于 `npx`，一条命令同时安装 CLI 二进制 + Agent Skill：

```bash
# 确保 $HOME/go/bin 在 PATH 中
export PATH="$PATH:$HOME/go/bin"

# 逐个安装（CLI + Skill 一步到位）
npx -y @mvanhorn/printing-press install firecrawl
npx -y @mvanhorn/printing-press install company-goat
npx -y @mvanhorn/printing-press install hackernews
npx -y @mvanhorn/printing-press install wikipedia
npx -y @mvanhorn/printing-press install flight-goat
npx -y @mvanhorn/printing-press install linear
```

如果只需要 CLI 不需要 Skill：

```bash
npx -y @mvanhorn/printing-press install <name> --cli-only
```

或者直接用 Go 安装（无需 Node.js）：

```bash
go install github.com/mvanhorn/printing-press-library/library/developer-tools/firecrawl/cmd/firecrawl-pp-cli@latest
```

安装完成后，每个 CLI 都会出现在 `~/go/bin/` 下，对应的 Skill 链接到 `~/.openclaw/skills/`。

---

## 通用使用习惯

### 1. 每次使用前先跑 `doctor`

```bash
<cli-name>-pp-cli doctor
```

这条命令检查配置、认证和 API 连通性。养成习惯，能省去大量排查时间。

### 2. 永远带上 `--agent` 标志

```bash
hackernews-pp-cli search "LLM" --agent
```

`--agent` 等价于同时开启 `--json --compact --no-input --no-color --yes`，输出干净的结构化 JSON，适合脚本和 Agent 消费。

### 3. 善用 `--dry-run` 预览

所有写操作都支持 `--dry-run`，显示实际要发送的请求而不真正执行：

```bash
firecrawl-pp-cli scrape and-extract-from-url https://example.com --dry-run
```

### 4. 用 `--select` 只拿需要的字段

减少 token 消耗的核心技巧——只返回你关心的列：

```bash
linear-pp-cli issues --agent --select identifier,title,status,assignee
```

### 5. 本地 SQLite 缓存

大多数 CLI 支持 `sync` 命令将数据拉到本地 SQLite，后续查询走本地 FTS5 全文检索：

```bash
hackernews-pp-cli sync        # 拉取 HN 数据到本地
hackernews-pp-cli search local "Rust"  # 本地全文检索，零延迟
```

---

## 1. company-goat：一站式公司调研

**定位**：用一条命令跨 7 个数据源（SEC Form D、GitHub、Hacker News、Companies House、YC 等）调研一家公司。

### 核心用法

```bash
# 一键快照——所有数据源并行查询
company-goat-pp-cli snapshot "OpenAI"

# 只看融资信息（SEC Form D）
company-goat-pp-cli funding "Stripe"

# 融资趋势——历年 Form D 提交时间线
company-goat-pp-cli funding-trend "Anthropic"

# 两家对比——列对列对齐
company-goat-pp-cli compare "OpenAI" "Anthropic"

# 异常信号检测——发现数据源间不一致
company-goat-pp-cli signal "Scale AI"
# → 可能提示："Form D says raised $5M in 2024 but no GitHub commits since 2022"

# GitHub 工程活力
company-goat-pp-cli engineering "vercel"

# HN 提及时间线
company-goat-pp-cli mentions "Linear"
```

### 最佳实践

- **投研场景**：先用 `snapshot` 拿全貌，再用 `signal` 检查红旗
- **竞品分析**：`compare` 直接对齐两家公司的融资、工程、域名年龄
- **免 Crunchbase 付费**：Form D 数据在 Crunchbase 是付费墙后的，这里免费拿到

---

## 2. hackernews：HN 全量搜索与分析

**定位**：本地 SQLite + Algolia 双引擎，支持离线全文检索和实时搜索。

### 核心用法

```bash
# 实时搜索（Algolia 全量索引，覆盖 2006 年至今）
hackernews-pp-cli search "AI agents" --tag story --min-points 100

# 按时间排序，只看最近 7 天
hackernews-pp-cli search openai --tag story --since 7d --by-date

# 查看单条详情
hackernews-pp-cli items 46990729

# 本地全文检索（需先 sync）
hackernews-pp-cli search local "Rust async runtime"

# 争议话题——评论/点赞比最高的故事
hackernews-pp-cli controversial

# 某个话题本周热度
hackernews-pp-cli pulse "LLM"

# Who-is-Hiring 线程分析
hackernews-pp-cli hiring stats
hackernews-pp-cli hiring companies

# 链接是否曾被提交过
hackernews-pp-cli repost https://github.com/example/repo
```

### 最佳实践

- **日常浏览**：`sync` 定时同步，然后 `search local` 零延迟检索
- **追踪话题**：`pulse` 看话题热度的日粒度趋势
- **求职分析**：`hiring stats` 一键分析最新的 Hiring 线程

---

## 3. wikipedia：百科知识快速查询

**定位**：Wikipedia REST API 的结构化封装，无需认证。

### 核心用法

```bash
# 随机文章
wikipedia-pp-cli page get-random --agent

# 指定文章摘要
wikipedia-pp-cli page get-summary --title "Python_(programming_language)"

# 获取完整 HTML
wikipedia-pp-cli page get-html --title "Machine_learning"

# 获取文章配图
wikipedia-pp-cli page get-media --title "Mars"

# 历史上的今天
wikipedia-pp-cli feed --type events --month 5 --day 9

# 同步到本地 SQLite（支持离线搜索）
wikipedia-pp-cli sync
```

### 最佳实践

- **Agent 知识库**：`get-summary` 快速拿摘要，比网页抓取高效得多
- **离线场景**：`sync` 之后全走本地，断网可用
- **多语言**：通过修改 config 中的 `base_url` 可以切换到其他语言版本

---

## 4. flight-goat：航班查询与旅行规划

**定位**：Google Flights + Kayak + FlightAware AeroAPI 三合一，免费搜索 + 付费增强。

### 核心用法

```bash
# 搜索指定日期的航班（免费）
flight-goat-pp-cli flights SEA LAX --date 2026-06-15

# 找最便宜的日期（免费）
flight-goat-pp-cli dates SEA LAX

# 长途直飞目的地（免费，基于 Kayak）
flight-goat-pp-cli longhaul SEA --min-hours 8

# 最便宜的长途直飞日期
flight-goat-pp-cli cheapest-longhaul SEA

# 探索所有直飞目的地（免费）
flight-goat-pp-cli explore SEA

# Google Flights 搜索（价格 + 航司 + 时长）
flight-goat-pp-cli gf-search SEA LAX --date 2026-07-01

# 航线准点率历史统计
flight-goat-pp-cli reliability UA SEA-SFO

# 航班实时追踪
flight-goat-pp-cli monitor --flight UA123

# 机场今日准点概览
flight-goat-pp-cli ontime-now SEA
```

### 最佳实践

- **旅行规划**：先 `explore` 看能飞哪，再 `dates` 比价
- **长途出行**：`cheapest-longhaul` 帮你找到性价比最高的直飞日期
- **出差监控**：`monitor` + `alerts` 实时关注航班动态

---

## 5. linear：项目管理终端操作

**定位**：Linear API 的全功能 CLI + 本地 SQLite 分析引擎。

### 核心用法

```bash
# 查询 Issue 列表
linear-pp-cli issues --agent --select identifier,title,status,assignee

# 自然语言 SQL 查询（杀手级功能）
linear-pp-cli sql 'blocked issues whose blocker has not moved in 7 days'

# 查看你正在阻塞别人的 issue
linear-pp-cli blocking

# 找出瓶颈——谁被阻塞最多
linear-pp-cli bottleneck

# 团队工作负载分布
linear-pp-cli load

# 无主 issue（缺少 assignee 或 project）
linear-pp-cli orphans

# 查看当前认证用户
linear-pp-cli me

# 同步到本地 SQLite
linear-pp-cli sync
```

### 最佳实践

- **每日站会**：`blocking` + `bottleneck` 快速了解团队阻塞情况
- **Sprint 回顾**：`analytics` 跑周期数据
- **复杂查询**：`sql` 命令支持自然语言转 SQL，能做 API 本身不支持的复合查询
- **本地优先**：`sync` 之后所有分析跑本地 SQLite，50ms 响应

---

## 6. firecrawl：网页抓取与数据提取

**定位**：Firecrawl API 的结构化封装，支持爬取、抓取、深度研究和 LLM 提取。

### 配置认证

```bash
# 设置 API Token
firecrawl-pp-cli auth set-token YOUR_FIRECRAWL_TOKEN

# 或环境变量
export FIRECRAWL_BEARER_AUTH="your-token-here"
```

### 核心用法

```bash
# 抓取单个网页
firecrawl-pp-cli scrape and-extract-from-url https://example.com

# 批量抓取
firecrawl-pp-cli batch scrape-and-extract-from-urls \
  --urls "https://a.com,https://b.com"

# 深度研究
firecrawl-pp-cli deep-research start --query "AI agent frameworks 2026"
firecrawl-pp-cli deep-research get-status --id <job-id>

# 搜索 + 抓取
firecrawl-pp-cli firecrawl-search search-and-scrape --query "LLM benchmarks"

# 生成 LLMs.txt
firecrawl-pp-cli llmstxt generate-llms-txt --url https://example.com

# 网站地图
firecrawl-pp-cli map urls --url https://example.com

# 团队额度查询
firecrawl-pp-cli team get-credit-usage
```

### 最佳实践

- **数据管道**：`map` 先拿站点结构 → `batch` 批量抓取 → `extract` 结构化提取
- **竞品监控**：定时 `scrape` 竞品页面，配合本地 SQLite 做变更检测
- **研究加速**：`deep-research` 用 LLM 自动研究一个话题，省去手动搜索

---

## 总结：我的日常工作流

```
早上：
  company-goat-pp-cli snapshot "竞品公司"    # 快速扫一眼竞品动态
  hackernews-pp-cli pulse "LLM"              # 看看 HN 上在聊什么

工作中：
  linear-pp-cli blocking                     # 站会前检查阻塞情况
  linear-pp-cli sql "..."                    # 复杂查询写进报告
  firecrawl-pp-cli scrape ...                # 抓需要的网页数据

出差规划：
  flight-goat-pp-cli explore SEA             # 看看能飞哪
  flight-goat-pp-cli dates SEA LAX           # 比价

闲时：
  wikipedia-pp-cli page get-random           # 随机读一条百科
  hackernews-pp-cli controversial            # 看 HN 上在吵什么
```

---

## 参考链接

- [Printing Press 官网](https://printingpress.dev/)
- [Printing Press Library GitHub](https://github.com/mvanhorn/printing-press-library)
- 当前 Library 共 **49+ 个 CLI**，覆盖电商、开发工具、营销、旅行、生产力等多个领域

---

*📝 本文所有命令均在 WSL (Ubuntu) + Go 1.22 环境下实测通过。*
