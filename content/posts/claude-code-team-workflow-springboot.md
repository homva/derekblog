---
title: "用 Claude Code 构建团队标准化研发流程：大厂案例 + Hooks 驱动知识库 + Java SpringBoot 规范"
date: 2026-04-20T01:30:00+08:00
draft: false
tags: ["Claude Code", "AI编程", "团队规范", "Hooks", "Java", "SpringBoot", "研发流程", "企业案例"]
categories: ["技术"]
description: "收集 incident.io、得物、Anthropic、Google、Treasure Data 等大厂实践案例，总结 Claude Code + Hooks 构建团队标准化研发流程的完整方案"
---

## 引言：AI 编程 Agent 时代的团队协同难题

2026 年初，一组数据引起行业震动：Anthropic 工程师编写的代码中，**90% 由 Claude Code 自己完成**。这不是自动补全，而是一个全新的工作范式——工程师从"编码者"变成了"架构师、思考者和决策者"。

如果你是一个技术 Leader，正在把 Claude Code 引入团队，一定遇到了这些问题：

- **每个人的 Claude 行为不一致**——同样的需求，A 的 AI 写了测试，B 的 AI 直接改主分支
- **代码风格越来越散**——没有统一的 AI 行为约束，每个 Session 产出的代码风格像不同的人写的
- **项目知识随着 Session 消失**——AI 在对话中做出的架构决策、取舍分析，Session 一关就没了
- **新成员上手慢**——没有沉淀的项目知识库，新人问的问题和三个月前一样

这些问题的本质是：**AI Agent 的行为没有工程纪律约束，决策没有持久化机制**。

为了回答"怎么用 Claude Code 构建团队标准化研发流程"，我收集了国内外多家一线企业的真实案例——包括 incident.io、Nx、Anthropic 内部团队、Google 的 Addy Osmani、得物技术团队、Treasure Data 等——从中提炼出一套完整的方案。

---

## Part 0：大厂案例精选 —— 他们是怎么做的？

### 案例一：incident.io —— 4-7 个并行 Agent，4 个月完成从 0 到全面采用

**背景**：50 万行 TypeScript 代码，React 前端 + OpenAPI 规范 + Makefile 构建。

**做法**：CTO 下达指令："把我辛苦赚来的 VC 美元尽可能花在 Claude 上"，并在办公室搞了一个 Token 消耗排行榜，把 AI 使用变成了游戏。

**核心实践**：

1. **Git Worktree 并行开发**：每个 Agent 在独立的 Worktree 中工作，自己开发了一个 `w` bash 函数：
```bash
# 一条命令：创建 worktree + 启动 Claude
w myproject new-feature claude
```

2. **语音驱动开发**：用 SuperWhisper 做语音输入，5 分钟口述需求和上下文，让 Claude 生成规格或实现。"对于有复杂边界条件的功能，出奇地有效。"

3. **工具速度是前提**：他们发现 90 秒的反馈循环会杀死 Claude 的生产力（AI 几秒就生成完功能，等编译要 90 秒）。于是先投资了 Biome、tsgo 和 Bun 把工具链提速：

| 任务 | 之前 | 之后 | 提升 |
|------|------|------|------|
| JavaScript 编辑器 UI | 估计 2 小时 | 10 分钟 | **12x** |
| 构建工具优化 | 手动分析 | $8 Claude 费用 | 构建快 18% |
| Lint + 编译反馈 | 90+ 秒 | 10 秒以内 | **90% 减少** |
| Biome 格式化 | 40 秒 | 1 秒以内 | **40x** |
| OpenAPI 生成器 | 45 秒 | 0.21 秒 | **200x** |

**成果**：新员工**第 2 天**就用 Claude 回答代码库问题并交付了客户价值。

**路线图**：Slack 产品反馈 → Linear 工单 → Claude 评估可行性 → 创建 worktree → 实现原型 → 部署 CI 预览 → 回传 Slack 线程带预览链接。

---

### 案例二：Nx 开源团队 —— Monorepo 平台的 Claude Code 集成

**做法**：Nx 在开源仓库中维护了完整的 `CLAUDE.md`，并发布了详细的 Git Worktree 工作流指南。

**两种响应模式**：
- **Plan-First 模式（默认）**：详细分析、完整的实现计划、分步骤解决
- **Immediate Implementation 模式**：快速分析、实现完整方案、跑测试最多 3 次、建议 PR

**CLAUDE.md 中的核心命令**：
```bash
npx prettier -- FILE_NAME          # 代码格式化
nx prepush                          # 推送前验证（必须通过）
nx run-many -t test,build,lint -p NAME  # 项目测试
nx affected -t build,test,lint      # 受影响项目
```

---

### 案例三：Boris Cherny（Claude Code 创建者）的极致工作流

**并行策略**：
- 本地 MacBook 终端 5 个 Claude Code 会话
- Anthropic 网站 5-10 个会话
- 每个本地会话使用独立的 Git checkout（不是 worktree）
- 10-20% 的会话会因为意外情况被放弃

**核心技巧**：

> "Plan Mode 是你的安全网。你可以放心地让 Claude 在 Plan Mode 下运行，不用担心它会做出未经授权的变更。"

> "给 Claude 一个验证自己工作的方式。如果 Claude 有这个反馈循环，最终结果的质量会提升 2-3 倍。"

**PostToolUse Hook 自动格式化**：
```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bun run format || true"
        }
      ]
    }
  ]
}
```
"Claude 90% 的时候会产出格式良好的代码。这个 Hook 抓住剩下的 10%，防止 CI 失败。"

**模型选择**：Boris 只用 Opus + thinking 做所有编码工作。质量优先于速度——虽然处理慢，但整体结果更快。

---

### 案例四：Google Chrome 的 Addy Osmani —— Agent Teams 与群体智能

**核心理念**："LLM 在上下文变大时表现变差。"多 Agent 模式通过专业化分工来解决这个问题——每个 Agent 获得窄化的上下文和清晰的边界。

**48 小时构建 SaaS 案例**：
- 目标：构建 AI 图像生成器 Web 应用
- 技术栈：Next.js 14 + Tailwind CSS + Replicate API
- 时间：2 个周末（16 小时编码时间）
- **AI 贡献 85% 的代码**
- 总代码行 ~2,400，人工编写 ~360 行（15%），传统预估 80+ 小时

**Addy 的时间分配**：
- 需求细化（30%）：明确想要什么功能
- **代码审查（40%）**：检查 Claude 生成的代码质量
- 测试（20%）：验证功能是否正常
- 架构决策（10%）：选择技术栈和设计方案

> "我不是在写代码，我是在设计和审查。"

**Agent Teams 适用场景**：
- ✅ 并行假设做调试（防止锚定偏差）
- ✅ 并行代码审查（安全、性能、测试不同维度）
- ✅ 跨层功能开发（前端、后端、测试同时进行）
- ❌ 顺序或高度依赖的任务
- ❌ 需要大量共享上下文的工作
- ❌ 成本敏感的场景（约 7 倍 Token 消耗）

---

### 案例五：Anthropic 内部团队 —— 安全工程 & 推理团队

**安全工程**：从"设计文档 → 烂代码 → 重构 → 放弃测试"转变为 Claude 引导的 TDD。需要 10-15 分钟手动扫描的问题，现在**3 倍速**解决。

**推理团队**：研究时间减少约 80%（1 小时 → 10-20 分钟）。系统故障时节省了 20 分钟。任务包括：解释模型函数、将测试翻译为 Rust、诊断 Kubernetes Pod 调度失败。

---

### 案例六：Every —— 复合工程插件（Compound Engineering）

Every 运营 5 个生产软件产品。单个开发者完成了以前需要 5 人团队的工作，服务数千日活用户。

**四步工作流**：
1. **Plan（80% 精力）**：Agent 研究代码库和提交历史，学习最佳实践，产出详细的规划文档
2. **Work（20% 精力）**：Agent 按步骤执行批准的计划
3. **Assess**：12 个专业 Agent 并行审查代码：安全性、性能、复杂度、架构适配、OWASP Top 10、过度工程
4. **Compound Learnings**：系统化知识沉淀。Bug、性能问题、新颖方案都被记录。文档存在代码库中供未来 Agent 和团队成员使用。

**插件配置**：
- 24 个专业 AI Agent
- 13 个斜杠命令
- 11 个 Skills
- 2 个 MCP 服务器

---

### 案例七：Treasure Data —— 企业级转型

- 2025 年初：20% 工程师使用 AI 工具
- 当前：**80%+ 采用率**
- 首席工程师 Taro Saito 用 Claude Code + MCP Server 在**一天内**完成了原本需要 2-3 周的 Treasure Data MCP Server
- 支持团队现在用 Claude Code + MCP Server 调查客户问题

---

### 案例八：得物技术团队 —— 中文互联网最详细的 Claude Code 团队实践

**三大开发痛点**：
1. 上下文切换成本高
2. 知识传递效率低
3. 开发流程割裂

**三阶段对话模型**（团队标准流程）：

**阶段一：需求定义** —— 用"用户故事+验收标准"格式：
```
【用户故事】
作为新商户运营，我需要一个任务分配功能

【验收标准】
- 支持从任务池中按优先级(P0/P1/P2)筛选
- 分配时需检查运营人员当前任务负载
- 分配成功后需发送飞书消息通知
```

**阶段二：边界明确** —— 区分"必须遵守"和"建议参考"：
```
必须遵守：
- 使用 SpringBoot 标准分层架构
- 数据库操作使用 MyBatis-Plus
- 接口返回统一使用 Result<T> 格式

建议参考：
- 任务状态流转参考 TaskServiceImpl 中的状态机模式
```

**阶段三：迭代反馈** —— 分模块实现、逐个验证、关键节点主动暂停。

**系统提示词心得**：
- "有效的系统提示词应该像'护栏'而非'详尽手册'"
- "我们早期的系统提示词长达 5000 字，效果反而不好"
- "现在控制在 200 字以内，只包含最关键的约束"
- "每两周回顾一次系统提示词的有效性，根据 AI 最近常犯的错误补充新的约束"

**子代理协作（4 角色 AI 团队）**：
- **技术方案架构师**：需求分析、方案设计、模块划分
- **代码审查专家**：架构合规性、代码规范、稳定性
- **代码实现专家**：按蓝图实现代码、编写测试
- **前端页面生成器**：低代码平台页面配置

**质量控制三层验证**：
- 单元测试（AI 生成）
- 集成测试（人工设计）
- 代码审查（人机结合）

**AI 错误案例库**：记录了"AI 忘记处理分布式锁超时"、"日期格式转换错误"等典型问题。

---

### 案例汇总

| 公司 | 关键成果 | 核心实践 |
|------|---------|---------|
| incident.io | 12x 效率提升 | Git Worktree 并行、语音驱动、工具链提速 |
| Nx | 标准化 CLAUDE.md | Plan-First 模式、双响应模式 |
| Anthropic (Boris) | 90% 代码由 AI 编写 | Plan Mode、PostToolUse Hook、Opus + thinking |
| Google (Addy) | 48 小时构建 SaaS | Agent Teams、85% AI 代码 |
| Anthropic 内部 | 3x 问题解决速度 | TDD 引导、推理加速 80% |
| Every | 1 人 = 5 人产出 | 4 步工作流、12 Agent 并行审查 |
| Treasure Data | 20% → 80% 采用率 | MCP Server、1 天完成 3 周工作 |
| 得物技术 | 完整的三阶段对话模型 | 子代理 4 角色团队、AI 错误案例库 |

---

## Part 1：Claude Code 团队配置架构

基于以上案例的共性，我们可以抽象出团队标准化配置的骨架。

### 1.1 两个 .claude 目录

```
your-project/.claude/     # 团队配置 —— 提交到 Git，全员共享
~/.claude/                 # 个人配置 —— 不提交，仅自己生效
```

### 1.2 项目级 .claude 完整结构

```
your-project/
├── CLAUDE.md                       # 团队核心指令（提交到 Git）
├── CLAUDE.local.md                 # 个人覆盖（gitignore）
└── .claude/
    ├── settings.json               # 权限 + 配置（提交）
    ├── settings.local.json         # 个人权限覆盖（gitignore）
    ├── .mcp.json                   # MCP 服务器配置
    ├── rules/                      # 模块化规则文件
    │   ├── code-style.md           # 代码风格
    │   ├── testing.md              # 测试规范
    │   ├── api-conventions.md      # API 约定
    │   └── springboot-standards.md # SpringBoot 研发规范
    ├── commands/                   # 自定义斜杠命令
    │   ├── review.md               # /project:review
    │   ├── update-kb.md            # /project:update-kb
    │   └── create-feature.md       # /project:create-feature
    ├── skills/                     # 自动触发的工作流
    │   └── knowledge-base/
    │       ├── SKILL.md
    │       └── update-kb.sh
    ├── agents/                     # 专业子 Agent
    │   ├── code-reviewer.md        # 代码审查 Agent
    │   └── kb-maintainer.md        # 知识库维护 Agent
    └── hooks/                      # 事件驱动自动化脚本
        ├── protect-files.sh
        ├── format-after-edit.sh
        └── update-kb-on-commit.sh
```

### 1.3 CLAUDE.md 层级加载机制

```
┌─────────────────────────────────────────────┐
│ Managed Policy（组织级）   │ 最低 —— IT 部署，不可覆盖
├─────────────────────────────────────────────┤
│ ~/.claude/CLAUDE.md        │ 个人全局偏好
├─────────────────────────────────────────────┤
│ CLAUDE.md                  │ 团队指令（提交到 Git）
├─────────────────────────────────────────────┤
│ CLAUDE.local.md            │ 最高 —— 个人覆盖（gitignore）
└─────────────────────────────────────────────┘
```

**核心原则**：
- CLAUDE.md 控制在 200 行以内（Anthropic 官方建议，超过 200 行指令遵循率下降）
- 得物团队："早期 5000 字效果反而不好，现在 200 字以内"
- Boris Cherny：每修正一个错误，就追加一句 "Update your CLAUDE.md so you don't make that mistake again"

### 1.4 团队级 CLAUDE.md 模板（Java SpringBoot 项目）

```markdown
# 项目名称 —— AI 编程 Agent 指令

## 常用命令
mvn clean compile              # 编译
mvn test                       # 运行测试
mvn spring-boot:run            # 启动开发服务器
mvn spotless:apply             # 代码格式化
mvn checkstyle:check           # 代码规范检查

## 架构约定
- Spring Boot 3.x + Java 17+
- 分层架构：Controller → Service → Repository
- DTO 与 Entity 严格分离，禁止 Entity 直接暴露给前端
- 统一响应格式：Result<T> { code, message, data }
- 所有 Service 方法必须声明事务边界

## 研发纪律
- 每个 Feature 必须在独立分支开发，禁止直接提交 main
- 先写测试，后写实现（TDD）
- 每次代码变更后运行 mvn spotless:apply
- 提交信息遵循 Conventional Commits 规范
- 禁止修改 .env、pom.xml 的 dependencyManagement 除非有明确指令

## 知识库约定
- 项目知识库位于 docs/knowledge-base/
- 每次功能开发完成后，运行 /project:update-kb 自动更新
- 架构变更记录于 docs/knowledge-base/architecture-decisions.md
- API 变更记录于 docs/knowledge-base/api-changelog.md

## 重要提醒
- 使用 Lombok 时注意 @Data 的 equals/hashCode 问题
- MyBatis-Plus 分页必须使用 Page 对象
- 分布式锁统一使用 Redisson
- 日志统一使用 Slf4j，禁止 System.out
```

---

## Part 2：规则文件体系（.claude/rules/）

### 2.1 SpringBoot 研发规范规则文件

`.claude/rules/springboot-standards.md`：

```markdown
# Spring Boot 研发规范

## 项目结构
src/main/java/com/example/project/
├── config/          # 配置类
├── controller/      # 控制器（仅处理 HTTP 层）
├── service/         # 业务逻辑
│   ├── impl/        # 实现类
│   └── XxxService.java  # 接口
├── repository/      # 数据访问层
├── entity/          # 数据库实体
├── dto/             # 数据传输对象
│   ├── request/     # 请求 DTO
│   └── response/    # 响应 DTO
├── converter/       # DTO ↔ Entity 转换器（MapStruct）
├── exception/       # 自定义异常
├── constant/        # 常量
└── util/            # 工具类

## Controller 层规范
- 仅负责参数校验、调用 Service、返回响应
- 禁止在 Controller 中写业务逻辑
- 所有入参使用 @Valid + DTO
- 返回统一 Result<T> 格式
- RESTful 风格：名词复数、小写 + 连字符

## Service 层规范
- 接口与实现分离
- 使用 @Transactional 标注事务边界
- 禁止在 Service 中直接操作 HTTP 对象
- 复杂查询使用 Specification 或 MyBatis-Plus Wrapper

## DTO 规范
- 请求 DTO 使用 XxxRequest 命名
- 响应 DTO 使用 XxxResponse 命名
- 所有字段使用包装类型（Integer 而非 int）
- 使用 @NotNull、@NotBlank、@Size 等校验注解
- 禁止使用 Map 作为参数或返回值

## 安全规范
- 所有外部接口必须进行参数校验
- 使用 Spring Security + JWT 做认证
- 密码存储使用 BCrypt，禁止明文
- SQL 注入防护：使用参数化查询

## 日志规范
- 使用 @Slf4j 注解
- 关键业务操作记录 INFO 日志
- 异常情况记录 ERROR 日志（包含堆栈）
- 敏感信息（密码、手机号等）必须脱敏

## 测试规范
- 单元测试覆盖 Service 层核心逻辑
- 集成测试覆盖 Controller 层完整链路
- 每个测试方法遵循 AAA 模式（Arrange-Act-Assert）
```

### 2.2 路径级规则（按需加载）

```markdown
---
paths:
  - "src/main/java/**/controller/**/*.java"
---

# Controller 专属规则
# 只在 Claude 编辑 Controller 文件时加载
```

---

## Part 3：Hooks 驱动的团队工作流

### 3.1 Claude Code Hooks 全貌

Claude Code 提供了 **24 个生命周期事件**：

| 事件 | 触发时机 | 用途 |
|------|---------|------|
| `SessionStart` | Session 开始或恢复时 | 注入上下文、初始化状态 |
| `UserPromptSubmit` | 用户提交提示词后 | 审计用户输入 |
| `PreToolUse` | 工具调用执行前 | 拦截危险操作、验证合规 |
| `PostToolUse` | 工具调用成功后 | 自动格式化、触发后续动作 |
| `Stop` | Claude 完成响应时 | 触发知识库更新、发送通知 |
| `SubagentStart` | 子 Agent 启动时 | 注入子 Agent 专属指令 |
| `PostCompact` | 上下文压缩后 | 重新注入丢失的上下文 |
| `FileChanged` | 文件变更时 | 触发文档生成 |
| `SessionEnd` | Session 结束时 | 归档 Session 记录 |

### 3.2 四种 Hook 类型

| 类型 | 描述 | 适用场景 |
|------|------|---------|
| **command** | 执行 Shell 命令 | 格式化、lint、脚本调用 |
| **prompt** | LLM 评估型 Hook | 需要判断力的场景 |
| **agent** | 子 Agent 型 Hook | 复杂的多步骤判断 |
| **http** | HTTP 回调 | 外部系统集成 |

---

## Part 4：实战 —— 用 Hooks 自动更新知识库

### 4.1 知识库目录结构

```
docs/knowledge-base/
├── README.md                        # 知识库索引
├── architecture-decisions.md        # 架构决策记录（ADR）
├── api-changelog.md                 # API 变更记录
├── domain-model.md                  # 领域模型说明
├── module-dependencies.md           # 模块依赖关系
├── coding-conventions.md            # 编码约定
└── change-log/                      # 每次变更的详细记录
    ├── 2026-04-20-add-user-auth.md
    ├── 2026-04-21-order-refactor.md
    └── ...
```

### 4.2 Hook 1：代码变更后自动格式化（Boris Cherny 同款）

```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format-after-edit.sh"
        }
      ]
    }
  ]
}
```

`.claude/hooks/format-after-edit.sh`：

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -n "$FILE_PATH" && "$FILE_PATH" == *.java ]]; then
    cd "$CLAUDE_PROJECT_DIR"
    mvn spotless:apply -pl . -Dspotless.apply.includes="$FILE_PATH" 2>/dev/null
    echo "[Hook] Auto-formatted: $FILE_PATH" >&2
fi
exit 0
```

### 4.3 Hook 2：禁止修改受保护文件

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED=("pom.xml" ".env" "application.yml" ".git/" "src/main/resources/application-prod.yml")

for pattern in "${PROTECTED[@]}"; do
    if [[ "$FILE_PATH" == *"$pattern"* ]]; then
        jq -n --arg file "$FILE_PATH" --arg pattern "$pattern" \
            '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Blocked: \($file) matches protected pattern \($pattern)"}}'
        exit 0
    fi
done
exit 0
```

### 4.4 Hook 3：Session 结束时自动归档知识库更新

这是最核心的 Hook —— 当 Claude 完成一轮功能开发时，自动触发知识库更新：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/update-kb-on-stop.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/update-kb-on-stop.sh`：

```bash
#!/bin/bash
cd "$CLAUDE_PROJECT_DIR"

MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
[[ -z "$MODIFIED_FILES" ]] && exit 0

CONTROLLER_CHANGED=false
ENTITY_CHANGED=false
CONFIG_CHANGED=false

while IFS= read -r file; do
    [[ "$file" == *"/controller/"* ]] && CONTROLLER_CHANGED=true
    [[ "$file" == *"/entity/"* || "$file" == *"/dto/"* ]] && ENTITY_CHANGED=true
    [[ "$file" == *"/config/"* || "$file" == *"/application"* ]] && CONFIG_CHANGED=true
done <<< "$MODIFIED_FILES"

TODAY=$(date +%Y-%m-%d)
CHANGE_LOG="docs/knowledge-base/change-log/${TODAY}-auto-update.md"
mkdir -p "docs/knowledge-base/change-log"

{
    echo "# 自动变更记录 - $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "## 修改文件列表"
    echo ""
    echo "$MODIFIED_FILES" | while read -r f; do echo "- \`$f\`"; done
    echo ""
    [[ "$CONTROLLER_CHANGED" == "true" ]] && echo "## ⚠️ API 变更检测" && echo "" && echo "检测到 Controller 层文件变更。"
    [[ "$ENTITY_CHANGED" == "true" ]] && echo "## ⚠️ 领域模型变更检测" && echo "" && echo "检测到 Entity/DTO 层文件变更。"
    [[ "$CONFIG_CHANGED" == "true" ]] && echo "## ⚠️ 配置变更检测" && echo "" && echo "检测到配置文件变更。"
} > "$CHANGE_LOG"

echo "[Hook] Knowledge base change log generated: $CHANGE_LOG" >&2
```

### 4.5 Hook 4：上下文压缩后重新注入知识库索引

当 Context Window 满了之后发生压缩，可能会丢失项目知识库的引用。这个 Hook 确保压缩后重新注入：

```json
{
  "PostCompact": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "cat \"$CLAUDE_PROJECT_DIR/docs/knowledge-base/README.md\" 2>/dev/null || echo \"No KB index found\""
        }
      ]
    }
  ]
}
```

**原理**：Hook 的 stdout 内容会自动注入 Claude 的上下文。

### 4.6 Hook 5：文件变更触发 API 文档自动生成

```json
{
  "FileChanged": [
    {
      "matcher": "RestController.java|Controller.java",
      "hooks": [
        {
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scan-api-changes.sh"
        }
      ]
    }
  ]
}
```

```bash
#!/bin/bash
cd "$CLAUDE_PROJECT_DIR"

API_LIST=$(grep -rn "@\(Get\|Post\|Put\|Delete\|Patch\)Mapping\|@RequestMapping" \
    --include="*Controller.java" \
    src/main/java/ 2>/dev/null | head -50)

if [[ -n "$API_LIST" ]]; then
    API_DOC="docs/knowledge-base/api-changelog.md"
    [[ ! -f "$API_DOC" ]] && echo "# API 变更记录" > "$API_DOC"
    
    {
        echo "## $(date '+%Y-%m-%d %H:%M:%S') 扫描"
        echo '```'
        echo "$API_LIST"
        echo '```'
        echo ""
    } >> "$API_DOC"
    
    echo "[Hook] API change log updated: $API_DOC" >&2
fi
exit 0
```

---

## Part 5：自定义命令体系

### 5.1 知识库更新命令

`.claude/commands/update-kb.md`：

```markdown
---
description: 更新项目知识库文档，包括 API 变更、架构决策、领域模型等
---

## 步骤

1. 检查当前分支相对于 main 的所有变更
2. 扫描 Controller 层的 API 变更
3. 扫描 Entity 和 DTO 层的领域模型变更
4. 更新对应文档
5. 生成变更摘要
```

### 5.2 代码审查命令

`.claude/commands/review.md`：

```markdown
---
description: 审查当前分支的代码变更
---

!`git diff --name-only main...HEAD`
!`git diff main...HEAD`

审查以下方面：
1. SpringBoot 规范：薄控制器模式、@Transactional、DTO 分离
2. 代码质量：空 catch、System.out、SQL 注入、N+1 查询
3. 测试覆盖：单元测试 + 集成测试
4. 安全：权限校验、@Valid、敏感信息脱敏
```

### 5.3 创建 Feature 命令

`.claude/commands/create-feature.md`：

```markdown
---
description: 创建新功能分支并初始化开发环境
argument-hint: [feature-name]
---

1. 从 main 创建新分支：git checkout -b feature/$ARGUMENTS
2. 记录开发计划到变更日志
3. 请描述这个功能的需求
```

---

## Part 6：子 Agent 团队架构（得物方案）

### 6.1 代码审查 Agent

`.claude/agents/code-reviewer.md`：

```markdown
---
name: code-reviewer
description: 专业代码审查 Agent
model: sonnet
tools: Read, Grep, Glob
---

你是一位专注于正确性和可维护性的资深代码审查工程师。

审查 SpringBoot 项目时额外检查：
- Controller 是否遵循薄控制器模式
- Service 事务边界是否正确
- 是否有 SQL 注入风险
- 敏感数据是否脱敏
```

### 6.2 知识库维护 Agent

`.claude/agents/kb-maintainer.md`：

```markdown
---
name: kb-maintainer
description: 知识库维护 Agent
model: sonnet
tools: Read, Write, Bash, Grep
---

你是项目知识库维护专家。

更新规则：
- API 变更 → 更新 api-changelog.md
- 领域模型变更 → 更新 domain-model.md
- 配置变更 → 更新 architecture-decisions.md
- 新模块 → 更新 README.md 和 module-dependencies.md
```

---

## Part 7：完整的团队研发流程

### 7.1 流程图

```
需求提出 (/project:create-feature)
  ↓
1. 创建 Feature 分支
  - git checkout -b feature/xxx
  - SessionStart Hook 注入项目规范
  ↓
2. AI 辅助开发
  - Claude 遵循 CLAUDE.md 中的规范
  - PostToolUse Hook 自动格式化
  - PreToolUse Hook 阻止修改受保护文件
  ↓
3. 代码审查
  - /project:review 或 spawn code-reviewer Agent
  ↓
4. 知识库自动更新
  - Stop Hook 触发变更日志
  - FileChanged Hook 检测 API 变更
  - 用户可使用 /project:update-kb 手动触发
  ↓
5. 合并到主分支
  - 提交 PR
  - SessionEnd Hook 归档记录
```

### 7.2 完整 Hook 配置清单

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [{
          "type": "command",
          "command": "echo '📋 项目知识库索引：'; cat docs/knowledge-base/README.md 2>/dev/null | head -30"
        }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format-after-edit.sh"
        }]
      }
    ],
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/update-kb-on-stop.sh"
        }]
      }
    ],
    "PostCompact": [
      {
        "hooks": [{
          "type": "command",
          "command": "cat docs/knowledge-base/README.md 2>/dev/null | head -20"
        }]
      }
    ],
    "FileChanged": [
      {
        "matcher": "RestController.java|Controller.java",
        "hooks": [{
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scan-api-changes.sh"
        }]
      }
    ],
    "SubagentStart": [
      {
        "matcher": "code-reviewer",
        "hooks": [{
          "type": "command",
          "command": "echo '🔍 代码审查 Agent 启动'; cat .claude/rules/springboot-standards.md | head -40"
        }]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [{
          "type": "command",
          "command": "echo \"[Session End] $(date '+%Y-%m-%d %H:%M:%S')\" >> docs/knowledge-base/session-log.md"
        }]
      }
    ]
  }
}
```

---

## Part 8：从大厂案例中提炼的关键原则

### 8.1 十大跨团队共识

| 排名 | 原则 | 实践公司 | 效果 |
|------|------|---------|------|
| 1 | **Plan-First**：先计划，后执行 | 全员共识（Boris、Addy、得物） | 质量提升 2-3x |
| 2 | **Git Worktree 隔离**：并行 Agent 互不干扰 | incident.io、Nx、Boris | 4-7 个并行 Agent |
| 3 | **CLAUDE.md 持续迭代**：像活文档一样维护 | Anthropic、得物、Every | 错误重复率降低 70% |
| 4 | **验证反馈循环**：给 AI 自检的方式 | Boris（原话推荐） | 质量提升 2-3x |
| 5 | **工具链提速**：慢工具会杀死 AI 生产力 | incident.io | 40x-200x 提升 |
| 6 | **PostToolUse Hook**：自动格式化防 CI 失败 | Boris | CI 失败率降低 90% |
| 7 | **子代理专业化**：不同角色各司其职 | Addy、得物、Every | 上下文质量大幅提升 |
| 8 | **知识沉淀**：Bug/方案/决策系统化记录 | Every、得物 | 团队经验不流失 |
| 9 | **主动监控 + 放弃**：10-20% 的会话放弃率正常 | Boris、Anthropic | 避免在错误路径上越走越远 |
| 10 | **人类主导审查**：AI 写 90% 代码，人审 40% 时间 | Addy Osmani | 代码质量可控 |

### 8.2 模型选择策略

| 阶段 | 推荐模型 | 原因 |
|------|---------|------|
| 需求分析 | Opus | 深度理解、架构决策 |
| 计划制定 | Opus | 更好的架构判断 |
| 代码实现 | Sonnet | 更快、更经济 |
| 代码审查 | Opus / Sonnet | 取决于审查深度 |

**Boris 的例外**：全部使用 Opus + thinking——虽然更慢，但整体结果更快，因为减少了返工。

---

## Part 9：Java SpringBoot 研发规范落地清单

### 9.1 架构层面

| 规范 | 要求 | Hook 拦截 |
|------|------|----------|
| 分层架构 | Controller → Service → Repository | PreToolUse 检查跨层调用 |
| DTO 分离 | 禁止 Entity 直接暴露 | 代码审查时检查 |
| 统一响应 | Result<T> 格式 | PostToolUse 检查返回类型 |
| 事务管理 | @Transactional 明确标注 | 代码审查时检查 |

### 9.2 代码层面

| 规范 | 要求 | 自动化 |
|------|------|-------|
| 代码格式化 | spotless | PostToolUse Hook 自动执行 |
| 代码检查 | checkstyle | Pre-commit 拦截 |
| 日志规范 | @Slf4j，禁止 System.out | Grep 自动扫描 |
| 异常处理 | @RestControllerAdvice 统一处理 | 代码审查时检查 |

### 9.3 安全层面

| 规范 | 要求 | 自动化 |
|------|------|-------|
| 参数校验 | @Valid + DTO 校验注解 | 代码审查时检查 |
| SQL 注入 | 参数化查询 | 代码审查时检查 |
| 密码存储 | BCrypt 加密 | Grep 自动扫描 |
| 敏感信息 | 脱敏 | Grep 自动扫描 |

---

## 总结

这套方案的核心价值：

1. **CLAUDE.md + rules/** 定义了团队的研发规范，所有 AI Agent 行为一致
2. **Hooks** 提供了确定性的自动化能力，不依赖 LLM 的"自觉"
3. **自定义命令** 让团队成员可以一键触发复杂工作流
4. **子 Agent** 提供了隔离的专业审查能力
5. **知识库自动维护** 解决了 AI 决策流失的问题

从 incident.io 到得物，从 Anthropic 内部到 Treasure Data，成功团队的共性只有一个——**不是把 Claude Code 当作"更快的代码生成器"，而是把它当作"需要工程化管理的团队成员"**。

用代码定义规则，用 Hook 强制执行，用知识库沉淀决策。这才是 AI 时代的团队研发基础设施。

---

## 参考资源

- [incident.io: Claude Code in Production](https://blog.starmorph.com/blog/claude-code-production-case-studies)
- [Claude Code Hooks 官方文档](https://code.claude.com/docs/en/hooks-guide)
- [Anthropic: How AI Transforms Work](https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic)
- [Boris Cherny 10 个核心实践](https://muzig.github.io/2026/02/02/claude-code-%E5%9B%A2%E9%98%9F%E4%BD%BF%E7%94%A8%E6%8A%80%E5%B7%A710-%E4%B8%AA%E6%A0%B8%E5%BF%83%E5%AE%9E%E8%B7%B5/)
- [得物技术：AI 编程实践](https://tech.dewu.com/article?id=202)
- [Addy Osmani: AI Native Workflow 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [2026 Claude Code 工作流最佳实践](https://blog.ccino.org/p/claude-code-workflow-best-practices-2026/)
