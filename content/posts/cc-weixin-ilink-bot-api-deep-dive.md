---
title: "cc-weixin 深度解析：基于腾讯官方 iLink 协议的微信 Bot API"
date: 2026-06-28T01:22:00+08:00
draft: false
tags: ["微信", "Bot API", "iLink", "Claude", "Agent", "OpenClaw"]
categories: ["技术"]
description: "深入分析 cc-weixin 项目底层原理，完整还原腾讯官方 iLink Bot 协议的技术细节，探讨微信个人号合法开放 Bot API 的里程碑意义。"
---

## 引言

2026 年，腾讯通过 OpenClaw 框架正式开放了微信个人号的 Bot API。官方名称叫**微信 ClawBot 插件功能**，底层协议名为 **iLink（智联）**，接入域名是 `ilinkai.weixin.qq.com`。

这是历史性的一刻。在此之前，开发者想要程序化控制微信，只有灰色地带的选项。现在不同了——iLink Bot API 是腾讯的官方产品，有《微信ClawBot功能使用条款》法律文件背书，标准 HTTP/JSON 协议，无需 SDK，可直接调用。

本文通过深入分析 [cc-weixin](https://github.com/hao-ji-xing/cc-weixin) 项目和 `@tencent-weixin/openclaw-weixin` 源码，完整还原这套协议的技术细节，并回答一个关键问题：**是否需要依赖真实的微信客户端？**

## 微信 Bot 的历史演进

在 iLink Bot API 出现之前，程序控制微信只有三条路：

| 方式 | 典型实现 | 性质 |
|---|---|---|
| 逆向 iPad 协议 | WeChatPadPro、itchat | 灰色地带，违反协议，随时封号 |
| PC 客户端 Hook | 注入 DLL、内存读写 | 违法，高封号风险 |
| 企业微信 API | 官方开放，但只面向企业 | 合法，但不是"微信" |

iLink Bot API 的出现在这四个方面实现了质的飞跃：

- **合法性**：官方开放，有法律文件背书
- **稳定性**：服务器端 API，不受微信客户端更新影响
- **安全性**：正常使用无封号风险
- **协议层**：标准 HTTP/JSON，不再是逆向模拟

## 两个关键的 npm 包

腾讯在 npm 上发布了两个包，scope 为 `@tencent-weixin`：

### @tencent-weixin/openclaw-weixin-cli（v1.0.2）

一个 **CLI 安装工具**，仅 3 个文件。核心作用：

1. 检测本机是否安装了 `openclaw` CLI
2. 调用 `openclaw plugins install` 安装插件
3. 触发扫码登录引导
4. 重启 OpenClaw Gateway

安装命令：
```bash
npx @tencent-weixin/openclaw-weixin-cli install
```

### @tencent-weixin/openclaw-weixin（v1.0.2）

这是真正的**协议实现包**，41 个 TypeScript 源文件：

```
src/
├── auth/          # QR 码登录、账号存储
├── api/           # iLink HTTP API 封装
├── cdn/           # 媒体文件 AES-128-ECB 加解密 + CDN 上传
├── messaging/     # 消息收发、inbound/outbound 处理
├── monitor/       # 长轮询主循环
├── config/        # 配置 schema
└── storage/       # 状态持久化
```

## cc-weixin 项目是什么

[cc-weixin](https://github.com/hao-ji-xing/cc-weixin) 是一个独立的微信 Claude Code Agent 桥接器，核心代码约 200 行。它的架构非常简单：

```
微信用户                    cc-weixin                     Claude Code Agent
   │                           │                                │
   │── 发消息 ────────────────▶│                                │
   │                           │── askClaude(text) ────────────▶│
   │                           │                                │── 执行工具
   │                           │                                │   (Bash, Read,
   │                           │                                │    WebSearch...)
   │                           │◀── 返回结果 ──────────────────│
   │◀── 回复 ─────────────────│                                │
```

不依赖 OpenClaw 框架，纯 Node.js 实现。用户发微信消息 → cc-weixin 转发给 Claude → Claude 执行工具 → 结果回复到微信。

## iLink Bot API 协议详解

### 鉴权流程

```
开发者               iLink 服务器               微信用户
   │                      │                        │
   │── GET get_bot_qrcode ──▶│                        │
   │◀──── { qrcode, url } ──│                        │
   │                      │◀─── 用户扫码 ────────────│
   │── GET get_qrcode_status ──▶│（长轮询）              │
   │◀── { status: "confirmed",  │                        │
   │      bot_token, baseurl } ──│                        │
   │                      │                        │
   │  持久化 bot_token，后续所有请求 Bearer 鉴权         │
```

**请求头固定格式：**

```javascript
{
  "Content-Type": "application/json",
  "AuthorizationType": "ilink_bot_token",
  "X-WECHAT-UIN": base64(String(randomUint32())),  // 每次随机
  "Authorization": `Bearer ${bot_token}`            // 登录后才有
}
```

`X-WECHAT-UIN` 是一个有趣的设计：随机生成一个 uint32，转十进制字符串，再 base64 编码。每次请求都变化，起到防重放攻击的作用。

### 完整 API 列表

| Endpoint | Method | 功能 |
|---|---|---|
| `/ilink/bot/get_bot_qrcode` | GET | 获取登录二维码（`?bot_type=3`） |
| `/ilink/bot/get_qrcode_status` | GET | 轮询扫码状态（`?qrcode=xxx`） |
| `/ilink/bot/getupdates` | POST | **长轮询收消息**（核心） |
| `/ilink/bot/sendmessage` | POST | 发送消息（文字/图片/文件/视频/语音） |
| `/ilink/bot/getuploadurl` | POST | 获取 CDN 预签名上传地址 |
| `/ilink/bot/getconfig` | POST | 获取 typing_ticket |
| `/ilink/bot/sendtyping` | POST | 发送"正在输入"状态 |

CDN 域名：`https://novac2c.cdn.weixin.qq.com/c2c`

### 消息收取：长轮询机制

与 Telegram Bot API 的 `getUpdates` 设计几乎一致：

```javascript
POST /ilink/bot/getupdates
{
  "get_updates_buf": "<上次返回的游标，首次为空字符串>",
  "base_info": { "channel_version": "1.0.2" }
}
```

服务器会**hold 住连接最多 35 秒**，直到有新消息才返回。响应体：

```json
{
  "ret": 0,
  "msgs": [ ...WeixinMessage[] ],
  "get_updates_buf": "<新游标，下次请求带上>",
  "longpolling_timeout_ms": 35000
}
```

**`get_updates_buf` 是关键**，类似数据库的 cursor，必须每次更新，否则会重复收到消息。

### 消息结构

每条消息（`WeixinMessage`）的核心字段：

```json
{
  "from_user_id": "o9cq800kum_xxx@im.wechat",
  "to_user_id": "e06c1ceea05e@im.bot",
  "message_type": 1,
  "message_state": 2,
  "context_token": "AARzJWAFAAABAAAAAAAp...",
  "item_list": [
    {
      "type": 1,
      "text_item": { "text": "你好" }
    }
  ]
}
```

**ID 格式规律：**

- 用户 ID：`xxx@im.wechat`
- Bot ID：`xxx@im.bot`

**消息类型（`item_list[].type`）：**

| type | 含义 |
|---|---|
| 1 | 文本 |
| 2 | 图片（CDN 加密存储） |
| 3 | 语音（silk 编码，附带转文字） |
| 4 | 文件附件 |
| 5 | 视频 |

### context_token：对话关联的核心

这是整个协议里最关键、也最容易踩坑的细节。

**每条收到的消息都带有 `context_token`**，你在回复时**必须原样带上这个 token**，否则消息不会关联到正确的对话窗口。

```javascript
// 发送消息时必须带上 context_token
POST /ilink/bot/sendmessage
{
  "msg": {
    "to_user_id": "o9cq800kum_xxx@im.wechat",
    "message_type": 2,       // BOT 发出
    "message_state": 2,      // FINISH（完整消息）
    "context_token": "<从 inbound 消息里取>",  // ← 必填！
    "item_list": [
      { "type": 1, "text_item": { "text": "你好！" } }
    ]
  }
}
```

### 媒体文件：AES-128-ECB 加密

微信 CDN 上的所有媒体文件都经过 **AES-128-ECB** 加密：

```typescript
// 上传前加密
const encrypted = encryptAesEcb(fileBuffer, aesKey);
// CDN 下载后解密
const plaintext = decryptAesEcb(encryptedBuffer, aesKey);
```

发送图片的完整流程：

1. 生成随机 AES-128 key
2. 用 AES-128-ECB 加密文件
3. 调用 `getuploadurl` 获取预签名 URL
4. PUT 加密文件到 CDN
5. 在 `sendmessage` 中带上 `aes_key`（base64）和 CDN 引用参数

## 最简裸调 Demo

以下是不依赖 OpenClaw 的纯 HTTP 实现：

```javascript
const BASE_URL = "https://ilinkai.weixin.qq.com";

// 1. 登录：获取 QR 码
const { qrcode, qrcode_img_content } = await fetch(
  `${BASE_URL}/ilink/bot/get_bot_qrcode?bot_type=3`
).then(r => r.json());

// 2. 等待扫码确认
let botToken, botBaseUrl;
while (true) {
  const status = await fetch(
    `${BASE_URL}/ilink/bot/get_qrcode_status?qrcode=${qrcode}`
  ).then(r => r.json());

  if (status.status === "confirmed") {
    botToken = status.bot_token;
    botBaseUrl = status.baseurl;
    break;
  }
  await sleep(1000);
}

// 3. 长轮询收消息
let getUpdatesBuf = "";
while (true) {
  const { msgs, get_updates_buf } = await apiPost(
    "ilink/bot/getupdates",
    { get_updates_buf: getUpdatesBuf },
    botToken
  );
  getUpdatesBuf = get_updates_buf ?? getUpdatesBuf;

  for (const msg of msgs ?? []) {
    if (msg.message_type !== 1) continue; // 只处理用户消息
    const text = msg.item_list?.[0]?.text_item?.text;

    // 4. 回复（必须带 context_token）
    await apiPost("ilink/bot/sendmessage", {
      msg: {
        to_user_id: msg.from_user_id,
        message_type: 2,
        message_state: 2,
        context_token: msg.context_token,
        item_list: [{ type: 1, text_item: { text: `回复：${text}` } }]
      }
    }, botToken);
  }
}
```

## 接入 Claude Code Agent

配合 Anthropic 的 `@anthropic-ai/claude-agent-sdk`，可以在很短时间内搭出一个有实际能力的 AI 助手：

```javascript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function askClaude(userText) {
  async function* messages() {
    yield {
      type: "user",
      session_id: "",
      parent_tool_use_id: null,
      message: { role: "user", content: userText },
    };
  }

  let result = "";
  for await (const msg of query({
    prompt: messages(),
    options: {
      model: "sonnet",
      baseTools: [{ preset: "default" }],  // Bash, Read, WebSearch...
      deniedTools: ["AskUserQuestion"],
      cwd: process.cwd(),
      env: process.env,
      abortController: new AbortController(),
    },
  })) {
    if (msg.type === "result") result = msg.result ?? "";
  }
  return result;
}

// 收到微信消息后
const reply = await askClaude(inboundText);
await sendWeixinMessage(toUserId, reply, contextToken);
```

**实测效果：**

> 用户发：「告诉我现在我是什么电脑，什么电量」
>
> Claude 调用 Bash 工具执行 `system_profiler`、`pmset -g batt`，回复了完整的机型 + 电量信息。

这不是一个普通的聊天机器人——Claude Code Agent 拥有完整的工具调用能力，能在你的机器上执行命令、读写文件、搜索网页，然后把结果发回微信。

## 核心问题：是否依赖真实微信客户端？

**答案：完全不需要。**

| 维度 | 旧方案（WeChatPadPro 等） | iLink Bot API |
|---|---|---|
| 合法性 | 违反微信服务协议 | 官方开放，合法 |
| 是否需要运行微信 | Hook 方案必须运行 | **完全不需要** |
| 协议层 | 模拟 iPad/移动端协议 | HTTP/JSON 标准接口 |
| 稳定性 | 每次更新可能失效 | 服务器端 API，稳定 |
| 封号风险 | 极高 | 正常使用无风险 |

理由如下：

1. **纯 HTTP 协议** — 所有通信都是对 `ilinkai.weixin.qq.com` 的 HTTP 请求，不依赖任何微信二进制文件或本地进程
2. **扫码仅用于授权** — 首次运行展示 QR 码，用户微信扫码确认授权后拿到 `bot_token`，之后 token 持久化，后续自动复用
3. **无客户端注入** — 不存在 DLL 注入、内存读写、进程 Hook 等任何需要微信客户端运行的操作

## 官方条款：你需要知道的边界

腾讯随这套 API 发布了《微信ClawBot功能使用条款》，有几条技术开发者必须了解：

### 腾讯只是"管道"

> 我们仅提供微信ClawBot插件与第三方AI服务的信息收发，不存储你的输入内容与输出结果，不提供AI相关服务。

**iLink 只是一条消息通道**。你接入的 Claude、GPT 等 AI 服务由你自己负责。

### 腾讯保留控制权

> 我们有权决定支持本功能的微信软件客户端类型以及可使用本功能的条件、范围等规则，**有权决定你可连接的第三方AI服务的类型、范围、信息收发规模或频率等事项**。

翻译成技术语言：

- 腾讯可以随时限速或封禁特定 AI 服务的接入
- 腾讯可以对内容进行过滤和拦截
- 腾讯可以终止你的连接

### 数据隐私

| 数据类型 | 处理方式 |
|---|---|
| 你发送的消息 | 转发给第三方 AI，**不在腾讯服务器存储** |
| AI 返回的输出结果 | 转发给你，**不在腾讯服务器存储** |
| IP 地址、操作记录、设备信息 | **会被收集**，用于安全审计 |

### 禁止行为

条款明确禁止：

- 利用本功能**绕过、破解微信软件的技术保护措施**
- 违反国家法律法规
- 危害网络安全、数据安全及微信产品安全
- 侵犯他人合法权益

### 腾讯可以随时终止服务

> 腾讯有权根据业务发展需要，自行决定变更、中断、中止或终止本功能服务。

这意味着**不应将核心业务完全依赖这套 API**，需要有降级方案。

## 技术层面的限制与未知

1. **`bot_type=3` 的含义未完全明确** — 源码硬编码了这个值，可能对应特定的微信账号类型或套餐
2. **需要 OpenClaw 账号体系** — 登录流程需要连接腾讯的 iLink 服务器，目前推测需要通过 OpenClaw 平台审核或注册
3. **群聊支持** — 源码有 `group_id` 字段，群聊可能需要额外权限
4. **消息历史** — 没有拉取历史消息的 API，只有 `get_updates_buf` 游标机制
5. **速率限制** — 官方未公开，需要实测

## cc-weixin 项目结构

```
cc-weixin/
├── cc-weixin.mjs        # 主入口（TUI / CLI 模式切换）
├── package.json         # 依赖声明
├── lib/
│   ├── auth.mjs         # 登录、token 管理
│   ├── messaging.mjs    # 消息收发封装
│   ├── claude.mjs       # Claude Agent 调用
│   └── tui/             # TUI 界面组件
│       └── index.mjs
├── bin/
│   └── cc-weixin        # CLI 入口
└── .env                 # 环境变量（ANTHROPIC_AUTH_TOKEN）
```

核心依赖：

| 依赖 | 用途 |
|---|---|
| Node.js >= 22 | 运行环境 |
| `@anthropic-ai/claude-agent-sdk` | Claude Agent 调用（带工具） |
| `ink` + `react` | TUI 界面 |
| `qrcode` | 终端显示登录二维码 |
| `dotenv` | 环境变量加载 |

## 合规前提下能做什么

基于这套 API，可以合法构建：

- **个人 AI 助手** — 直接在微信里使用 Claude / GPT
- **通知机器人** — 监控报警、部署状态推送到微信
- **客服系统** — 多账号管理 + 自动分流
- **工作流自动化** — 接收微信指令触发 CI/CD、文件处理等
- **家庭群助手** — 家庭群内的 AI 助手
- **个人知识库** — 发消息自动归档到 Notion/飞书

## 总结

iLink Bot API 的开放标志着微信生态迎来了真正的合法 Bot 时代。cc-weixin 项目用约 200 行核心代码，将微信消息与 Claude Code Agent 桥接起来，架构简洁、实现清晰。

对于技术开发者而言，这是一套标准的 HTTP/JSON API，不需要任何逆向工程或客户端注入，扫码授权后即可使用。但也要清醒认识到：腾讯保留了服务的完全控制权，不应将关键业务完全依赖于此，需要设计降级方案。

微信 Bot 的大门已经打开，接下来就看开发者们能做出什么了。

## 参考资源

| 资源 | 链接 |
|---|---|
| cc-weixin 仓库 | https://github.com/hao-ji-xing/cc-weixin |
| OpenClaw 文档 | https://docs.openclaw.ai |
| 微信插件包 npm | https://www.npmjs.com/package/@tencent-weixin/openclaw-weixin |
| Claude Agent SDK | https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk |
