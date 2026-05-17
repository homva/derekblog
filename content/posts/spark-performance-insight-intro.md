---
title: "Spark Performance Insight：重新定义 Spark 性能分析体验"
date: 2026-03-04T11:00:00+08:00
draft: false
tags: ["spark", "性能", "大数据","skill"]
categories: ["技术"]
description: "Spark Performance Insight：重新定义 Spark 性能分析体验"
---

> 一款由 DuckDB 驱动的新一代 Spark 性能分析工具，让性能问题无处遁形

## 背景痛点

虽然 Spark 原生 Web UI 提供了基础的监控能力，但在深度性能分析时，用户经常面临以下困境：

### 📊 指标迷宫
Spark UI 展示了大量原始指标和复杂的图表，初学者难以找到关键信息，专家也花费大量时间在各个页面间切换关联指标。

### 🔍 隐藏的洞察
GC 压力、数据倾斜等关键瓶颈往往隐藏在层层子菜单之下，很难快速获得应用的"健康检查"结果。

### 📉 无法量化的偏差
当某个 Job 运行变慢时，没有内置的方式进行两个运行的对比分析，无法精确定位是哪个 Stage 或 Task 发生了变化。

### ⏱️ 事件回放开销
对于大型作业，重放原始 JSON EventLog 会导致极高的 CPU/内存开销，漫长等待令人沮丧。

### 💥 可扩展性限制
没有结构化存储，Spark History Server（SHS）在处理包含数百万 Task 的作业时经常崩溃（OOM）。

---

## 核心特性

### 🏆 智能诊断引擎

**双重诊断模式，让性能问题无所遁形：**

#### 1️⃣ 规则引擎诊断（确定性分析）
- 基于统计阈值的确定性分析，告别 LLM 的概率性
- 多年 Spark 性能调优经验固化为自动化规则
- 精准检测：**数据倾斜、GC 压力、磁盘溢出、本地化问题**

#### 2️⃣ LLM 深度分析（智能洞察）
- 集成 Zhipu AI (GLM-4) 和 OpenAI
- 深度分析复杂性能问题（如 Shuffle IO、GC 压力）
- 生成专家级 Markdown 优化报告，提供可执行的调优建议

> 规则引擎提供即时、可量化的证据，是生产环境故障排查的"金标准"

### 🔄 应用对比分析

**跨应用横向对比，快速定位回归问题：**

- **应用对比**：并排对比不同应用实例，识别配置或资源导致的性能回归
- **Stage 深度对比**：深入对比两个 Stage，统计分布（P95、中位数）和 Task 执行追踪

### ⚡ 毫秒级查询体验

**借助 DuckDB 的强大分析能力：**

- TB 级日志高速流式摄入（Jackson）
- 服务端分页，支持百万级 Task 瞬间加载
- 预计算聚合表，实现即时 UI 响应
- 原生支持 ZSTD 压缩和 Spark V2 日志格式

### 🤖 AI 时代：MCP 集成

**让 AI Agent 直接"读懂"你的 Spark 日志：**

- 将 Spark Performance Insight 暴露为 MCP Server
- AI Agent（Claude、Gemini）可直接读取和分析本地 Spark 日志
- 自然语言调优："分析 `/tmp/spark-logs/app-1` 的日志" → AI 自动触发解析并给出优化建议

---

## 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (Vue 3)                      │
│  Vue 3 + Vite + ECharts + Material Design               │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Backend (Java 21)                      │
│  Spring Boot 3.x + Virtual Threads                       │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                OLAP Engine (DuckDB)                      │
│  嵌入式分析数据库，高性能查询                             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              Medallion Architecture (三层架构)            │
│                                                         │
│   🥉 Bronze (原始摄入): Jackson 流式处理，TB 级轻松处理   │
│   🥈 Silver (转换): 恢复逻辑关系，识别长尾任务            │
│   🥇 Gold (聚合): 预计算分析表，即时响应 UI               │
└─────────────────────────────────────────────────────────┘
```

### 核心技术栈

| 层级 | 技术选型 |
|------|----------|
| 前端 | Vue 3 + Vite + ECharts + Material Design |
| 后端 | Java 21 (Virtual Threads) + Spring Boot 3.x |
| OLAP | DuckDB (嵌入式分析数据库) |
| ORM | MyBatis Plus (XML 优化 SQL) |
| 压缩 | ZSTD 支持 |
| 日志 | Spark V2 EventLog |

---

## 快速开始

### 方式一：本地运行

```bash
# 构建并启动前后端
mvn clean install -Pbuild-frontend
mvn spring-boot:run

# 访问 UI
# http://localhost:18081
```

### 方式二：一键启动对比环境

```bash
# 同时启动 Spark Performance Insight 和原生 History Server
mvn clean install -Pbuild-frontend -Prun
```

访问：
- **Spark Performance Insight UI**: http://localhost:18081
- **原生 Spark History Server**: http://localhost:18080（对比参考）

### 方式三：Docker 部署

```bash
docker compose up -d
```

---

## 界面预览

### 应用列表
![Application List](https://github.com/petrel2015/Spark-Performance-Insight/raw/main/docs/img/ui_app_list.png)

### Job 列表
![Job List](https://github.com/petrel2015/Spark-Performance-Insight/raw/main/docs/img/ui_job_list.png)

### Stage 对比
![Stage Compare](https://github.com/petrel2015/Spark-Performance-Insight/raw/main/docs/img/stage_compare.png)

### SQL 详情
![SQL Detail](https://github.com/petrel2015/Spark-Performance-Insight/raw/main/docs/img/ui_sql_detail.png)

---

## 为什么选择 Spark Performance Insight？

| 维度 | 原生 Spark UI | Spark Performance Insight |
|------|---------------|---------------------------|
| 查询速度 | 分钟级回放 | **毫秒级查询** |
| 对比分析 | ❌ 不支持 | ✅ 完整支持 |
| 智能诊断 | ❌ 手动排查 | ✅ AI + 规则双引擎 |
| 大规模支持 | OOM 风险 | ✅ DuckDB 强力支撑 |
| AI 集成 | ❌ 无 | ✅ MCP 协议支持 |

---

## 未来规划

- [ ] Executor 性能诊断：深度分析吞吐量和延迟，定位资源利用瓶颈
- [ ] DAG 可视化：Job/Stage 关系图
- [ ] 高级基准测试：跨集群性能对比

---

## 总结

**Spark Performance Insight** 的核心理念是：**将 EventLog 转化为可操作的情报，而非原始数据**。

它不仅仅是一个监控工具，更是一个智能的性能分析平台，通过 Medallion Architecture、Smart Diagnosis 和 Multi-dimensional Benchmarking 三大支柱，彻底解决了原生 Spark Web UI 的痛点，让性能分析从"苦力活"变成"洞察力"。

---

**项目地址**: https://github.com/petrel2015/Spark-Performance-Insight  
**在线 Demo**: http://demo.fluffyeti.com:18081/

---

*本文基于项目 README 和官方文档整理，完整技术细节请参考 [项目文档](https://github.com/petrel2015/Spark-Performance-Insight/tree/main/docs/en)。*