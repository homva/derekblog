---
title: "Karpathy 原文解读：「用 Claude 编码几周后的随机笔记」"
date: 2026-04-21T00:20:00+08:00
draft: false
tags: ["AI编程", "Claude", "Karpathy", "工作流"]
categories: ["技术"]
description: "解读 Karpathy 分享的 AI 编码工作流转变——从手写代码到声明式指令，以及 LLM 带来的能力边界扩展。"
---

发布时间：2026年1月26日，760万浏览。

---

### 1️⃣ 编码工作流的范式转移

> 从 11 月的「80% 手写 + 20% Agent」到 12 月的「80% Agent + 20% 审查修改」

Karpathy 说自己**现在主要在用英语编程**——用自然语言告诉 LLM 写什么代码。他承认这有点伤自尊，但用"代码级动作"操作软件的效率太高了。

**关键判断**：这是他 20 年编程生涯中最大的工作流变化，而且发生在**几周内**。他认为已有「百分之十几」的工程师经历了类似转变，但大众认知还停留在个位数百分比。

> 📌 **解读**：这不是一个渐进过程，而是一个**相变（phase shift）**——能力一旦跨过某个阈值，工作流会在极短时间内翻转。

---

### 2️⃣ IDE 还在，Agent 群还没到时候

Karpathy 对两个 hype 泼了冷水：

- ❌ "不再需要 IDE"——**太早了**
- ❌ "Agent Swarm（多 Agent 群）"——**也太早了**

**他现在的实际工作流**：左边开几个 Claude Code 终端窗口，右边开 IDE 盯着代码做人工审查。像盯鹰一样盯着 AI。

**错误类型变了**：不再是语法错误，而是**概念性错误**——像一个粗心急躁的初级程序员会犯的那种。

#### 🔴 他列出的具体缺陷（也是上一份调研中四大原则的来源）：

| 缺陷       | 原文                                                         |
| ---------- | ------------------------------------------------------------ |
| 擅自假设   | "make wrong assumptions on your behalf and just run along with them without checking" |
| 不管理困惑 | "don't manage their confusion, don't seek clarifications"    |
| 不暴露矛盾 | "don't surface inconsistencies"                              |
| 不展示权衡 | "don't present tradeoffs"                                    |
| 不会反驳   | "don't push back when they should"                           |
| 太迎合     | "still a little too sycophantic"                             |
| 过度设计   | "overcomplicate code and APIs, bloat abstractions, don't clean up dead code" |
| 千行变百行 | "implement a bloated construction over 1000 lines... you say 'couldn't you just do this instead?' → immediately cut it down to 100 lines" |
| 越界修改   | "change/remove comments and code they don't sufficiently understand as side effects, even if orthogonal to the task" |

**注意**：他说即使写了 CLAUDE.md 做约束，这些问题**仍然会发生**。

---

### 3️⃣ Tenacity（韧性）—— LLM 不会累

> "They never get tired, they never get demoralized, they just keep going."

看 Agent 死磕一个问题 30 分钟最后解决掉，他说这是 **"feel the AGI" moment**。人的核心瓶颈之一就是 stamina（耐力），LLM 把它大幅拉长了。

> 📌 **解读**：AI 不是比人聪明，是比人能熬。

---

### 4️⃣ Speedup ≠ 加速，而是**扩张**

Karpathy 提出了一个关键区分：

- **不是**"原来 3 天做完的事现在 1 天做完"
- **而是**"以前不值得做的现在做了" + "以前因为知识盲区不敢碰的现在敢碰了"

> 📌 **解读**：LLM 带来的不是效率提升，而是**能力边界的扩展**。

---

### 5️⃣ Leverage（杠杆力）——全文最有实操价值的一段

> "Don't tell it what to do, give it success criteria and watch it go."

Karpathy 给了一套**从命令式到声明式**的方法论：

| 方式     | 做法                             |
| -------- | -------------------------------- |
| ❌ 命令式 | 一步步告诉 AI 怎么写代码         |
| ✅ 声明式 | 给出成功标准，让 AI 循环直到达标 |

具体战术：
1. **先写测试，再让它通过**
2. **接上浏览器 MCP 让它自己验证**
3. **先写朴素但大概率正确的版本，再让它在保持正确性的前提下优化**
4. **从 imperative 转向 declarative，让 Agent 循环得更久，获取更大杠杆**

---

### 6️⃣ Fun —— 编程变得更有趣了

去掉了填空式的脏活，留下的是创造的部分。他感觉被卡住的次数大幅减少，**勇气**更多了——因为"总有办法跟它一起推进"。

但他也观察到**反方观点**：LLM 编码会把工程师分成两类——**喜欢 coding 的**和**喜欢 building 的**，前者可能觉得失落。

---

### 7️⃣ Atrophy（能力退化）——坦诚的自我观察

Karpathy 发现自己**手写代码的能力在缓慢退化**。他提出了一个有意思的区分：

- **Generation**（写代码）和 **Discrimination**（读/审查代码）是大脑里**两种不同的能力**
- 由于编程涉及大量语法细节，你能 review 代码，不代表你能从零写出来

> 📌 **解读**：这是一个值得警惕的信号——团队里 senior 的手写能力退化后，review 质量可能没问题，但脱离 AI 后的独立战斗力会下降。

---

### 8️⃣ Slopacolypse（垃圾内容末日）

他预测 2026 是 **"slop 泛滥之年"**——GitHub、Substack、arxiv、X/Instagram 全数字媒体都会被低质量 AI 生成内容淹没。同时也会出现更多"AI 生产力表演秀"。

---

### 9️⃣ 他抛出的四个开放问题

1. **10X 工程师**会发生什么？平均值和最大值之间的差距可能**大幅扩大**
2. **通才 vs 专才**——有了 LLM，通才会不会越来越碾压专才？（LLM 擅长填空/微观，不擅长战略/宏观）
3. **未来编程像什么？** 打星际？玩 Factorio？演奏音乐？
4. **社会有多少瓶颈在于数字知识工作？**

---

### 🔟 TLDR —— 他的终局判断

> 2025 年 12 月，LLM Agent（尤其是 Claude 和 Codex）跨过了某个**连贯性阈值**，引发了软件工程的**相变**。

**智力部分**已经大幅领先于**其他部分**——工具集成、知识管理、组织工作流、流程设计、以及能力扩散本身。

**2026 年将是行业"消化"新能力的高能之年。**

---

### 💡 对我们的启示

1. **工作流要转**：从"我写代码"变成"我描述需求 + 审查结果"，这个角色转变越早适应越好
2. **IDE 不能丢**：Karpathy 本人也强调要盯着看，团队里不能因为用了 AI 就放弃 code review
3. **声明式指令 > 命令式指令**：给目标不给步骤，这是最核心的使用心法
4. **能力退化是真实的**：团队需要有意识地保持手写能力，不能完全依赖 AI
5. **10X 差距会拉大**：会用 AI 和不会用 AI 的工程师之间的差距会越来越夸张
