---
title: "Hugo 在 WSL ARM 上安装踩坑记：wazero SIGILL 崩溃与解决方案"
date: 2026-04-19T18:09:00+08:00
draft: false
tags: ["hugo", "WSL", "ARM", "博客", "踩坑", "编译"]
categories: ["技术"]
description: "在 WSL2 ARM 环境安装 Hugo 时遇到 wazero SIGILL 崩溃的根因分析与从源码编译的完整解决方案"
---

# Hugo 在 WSL ARM 上安装踩坑记：wazero SIGILL 崩溃问题与解决方案

## 问题背景

在一台 **ARM 架构的 WSL2**（Windows Subsystem for Linux）环境中安装 Hugo 博客构建工具时，遇到了一个罕见但致命的问题：**所有 Hugo v0.122+ 的预编译二进制版本都无法运行**，启动即崩溃。

系统环境：

| 项目 | 值 |
|------|------|
| OS | Ubuntu 24.04.4 LTS (WSL2) |
| 架构 | aarch64 (ARM64) |
| Go 版本 | 1.24.4 |
| Hugo 版本 | 0.147.4 |
| Windows 主机 | ARM 架构（如 Surface Pro X / Parallels / WSL2 ARM） |

---

## 一、问题现象

### 1.1 直接下载 Hugo 二进制，启动即崩溃

```bash
$ curl -L https://github.com/gohugoio/hugo/releases/download/v0.147.4/hugo_extended_0.147.4_linux-arm64.tar.gz | tar -xz
$ ./hugo version
```

崩溃输出：

```
SIGILL: illegal instruction
PC=0x116e130 m=0 sigcode=2
instruction bytes: 0x0 0x6 0x38 0xd5 0xe0 0x7 0x0 0xf9 ...

goroutine 1 [running, locked to thread]:
github.com/tetratelabs/wazero/internal/platform.getisar0()
    cpuid_arm64.s:11
```

### 1.2 尝试非 extended 版本，同样崩溃

```bash
$ curl -L https://github.com/gohugoio/hugo/releases/download/v0.147.4/hugo_0.147.4_linux-arm64.tar.gz | tar -xz
$ ./hugo version
# 同样 SIGILL 崩溃
```

### 1.3 尝试旧版本，依然崩溃

```bash
$ curl -L https://github.com/gohugoio/hugo/releases/download/v0.138.0/hugo_0.138.0_linux-arm64.tar.gz | tar -xz
$ ./hugo version
# 同样 SIGILL 崩溃
```

---

## 二、根因分析

### 2.1 崩溃位置

通过 stack trace 定位到：

```
github.com/tetratelabs/wazero/internal/platform.getisar0()
    → cpuid_arm64.s:11
```

### 2.2 什么是 wazero？

**wazero** 是一个纯 Go 的 WebAssembly 运行时库，Hugo 用它来支持 `hugo mod` 中的 WASM 插件。

### 2.3 为什么会崩溃？

wazero 在 ARM64 Linux 上需要读取 CPU 特性寄存器（`ID_AA64ISAR0_EL1` 和 `ID_AA64ISAR1_EL1`），使用的是 **`MRS` 指令**：

```assembly
// cpuid_arm64.s
// 读取 instruction set attribute register
mrs x0, ID_AA64ISAR0_EL1  // ← 这条指令
ret
```

**问题核心**：在原生 Linux ARM 上，EL0（用户态）允许读取这些寄存器。但在 **WSL2 ARM** 中，Windows 内核模拟层**不支持这条 `MRS` 指令**，导致 CPU 触发 **SIGILL（非法指令）** 异常，进程直接终止。

### 2.4 验证：Hugo v0.121.2 可以运行

```bash
$ curl -L https://github.com/gohugoio/hugo/releases/download/v0.121.2/hugo_0.121.2_linux-arm64.tar.gz | tar -xz
$ ./hugo version
hugo v0.121.2 ... linux/arm64   # ✅ 正常运行
```

因为 Hugo v0.121.2 **还没有引入 wazero 依赖**。

### 2.5 新问题：旧版 Hugo 不兼容 PaperMod 主题

```
ERROR => hugo v0.146.0 or greater is required for hugo-PaperMod to build
```

PaperMod 主题（目前最流行的 Hugo 博客主题之一）从某个版本开始要求 Hugo ≥ 0.146.0。

**死锁局面**：
- v0.122+：有 wazero → WSL ARM 崩溃
- v0.121.2：没有 wazero → 但 PaperMod 不兼容

---

## 三、解决方案：从源码编译 + Patch wazero

### 3.1 整体思路

1. 安装 Go 编译工具链
2. 克隆 Hugo v0.147.4 源码
3. **修改 wazero 库的 CPU 寄存器读取逻辑**，改为返回安全的默认值
4. 用 `replace` 指令让 Hugo 使用 patch 后的 wazero
5. 从源码编译 Hugo

### 3.2 详细步骤

#### Step 1: 安装 Go

```bash
# 下载 Go
curl -fsSL "https://go.dev/dl/go1.24.4.linux-arm64.tar.gz" -o /tmp/go.tar.gz

# 解压到本地目录
mkdir -p ~/go_root
tar -xzf /tmp/go.tar.gz -C ~/go_root/

# 配置 PATH
export PATH="$HOME/go_root/go/bin:$PATH"

# 验证
go version
# go version go1.24.4 linux/arm64
```

#### Step 2: 克隆 Hugo 源码

```bash
git clone --depth 1 --branch v0.147.4 https://github.com/gohugoio/hugo.git /tmp/hugo-src-new
cd /tmp/hugo-src-new
```

#### Step 3: 下载并 Patch wazero

```bash
# 先让 Go 下载 wazero 依赖
go mod download github.com/tetratelabs/wazero

# 找到 wazero 的位置（通常在 GOPATH/pkg/mod 下）
WAZERO_PATH=$(find ~/go_root/go/pkg/mod -name "cpuid_arm64.go" -path "*wazero*" | head -1 | xargs dirname)
echo "wazero 路径: $WAZERO_PATH"

# 复制到可写位置
cp -r "$WAZERO_PATH/.." /tmp/wazero-patched

# 修改 cpuid_arm64.go
# 核心改动：不再调用 MRS 指令读取寄存器，而是直接返回安全默认值
cat > /tmp/wazero-patched/internal/platform/cpuid_arm64.go << 'EOF'
//go:build gc

package platform

// CpuFeatures exposes the capability for this CPU, queried via the Has, HasExtra methods.
// On WSL ARM, reading instruction set registers via MRS crashes (SIGILL),
// so we return safe default values instead.
var CpuFeatures = &cpuFeatureFlags{
	isar0: uint64(CpuFeatureArm64Atomic),
	isar1: 0,
}

// cpuFeatureFlags implements CpuFeatureFlags interface.
type cpuFeatureFlags struct {
	isar0 uint64
	isar1 uint64
}

// Has implements the same method on the CpuFeatureFlags interface.
func (f *cpuFeatureFlags) Has(cpuFeature CpuFeature) bool {
	return (f.isar0 & uint64(cpuFeature)) != 0
}

// HasExtra implements the same method on the CpuFeatureFlags interface.
func (f *cpuFeatureFlags) HasExtra(cpuFeature CpuFeature) bool {
	return (f.isar1 & uint64(cpuFeature)) != 0
}

// Raw implements the same method on the CpuFeatureFlags interface.
func (f *cpuFeatureFlags) Raw() uint64 {
	var ret uint64
	if f.Has(CpuFeatureArm64Atomic) {
		ret = 1 << 0
	}
	return ret
}
EOF

chmod u+w /tmp/wazero-patched/internal/platform/cpuid_arm64.go  # 确保可写
```

#### Step 4: 添加 replace 指令

```bash
cd /tmp/hugo-src-new

# 在 go.mod 末尾添加 replace 指令
echo 'replace github.com/tetratelabs/wazero => /tmp/wazero-patched' >> go.mod

# 验证
grep "wazero" go.mod
```

#### Step 5: 编译 Hugo

```bash
go build -o ~/.local/bin/hugo .

# 验证
~/.local/bin/hugo version
# hugo v0.147.4-84c8426... linux/arm64 BuildDate=2025-05-20T10:41:19Z
```

🎉 成功！

#### Step 6: 构建博客

```bash
cd ~/your-blog-path
make build
```

> **注意**：如果博客项目位于 WSL 访问的 Windows 共享路径（如 `/mnt/c/` 或 `/mnt/mac/`），可能会遇到 `chtimes: operation not permitted` 错误。解决方法是先在 WSL 原生目录（如 `/tmp/`）构建，再把 `public/` 复制回去：

```bash
# 在 WSL 原生目录构建
mkdir -p /tmp/blog-build
cp -r ~/your-blog/* /tmp/blog-build/
cd /tmp/blog-build
make build

# 构建成功后复制回共享目录
cp -r /tmp/blog-build/public ~/your-blog/
```

---

## 四、另一个小坑：Hugo 配置 deprecation

### 问题

```
ERROR deprecated: site config key paginate was deprecated in Hugo v0.128.0
and subsequently removed. Use pagination.pagerSize instead.
```

### 修复

修改 `hugo.yaml`：

```yaml
# 修改前（旧格式）
paginate: 10

# 修改后（新格式）
pagination:
  pagerSize: 10
```

---

## 五、总结

### 问题链

```
WSL2 ARM 不支持 MRS 指令
    ↓
wazero 读取 CPU 寄存器触发 SIGILL
    ↓
Hugo v0.122+ 所有版本崩溃
    ↓
旧版 v0.121.2 可用，但 PaperMod 主题不兼容
    ↓
必须从源码编译 + patch wazero
```

### 解决要点

| 问题 | 解决方案 |
|------|---------|
| wazero SIGILL | patch cpuid_arm64.go，返回安全默认值 |
| Hugo 不兼容主题 | 从源码编译 v0.147.4 |
| WSL chtimes 权限 | 先在 WSL 原生目录构建，再 cp 回共享目录 |
| paginate 废弃 | 改为 pagination.pagerSize |

### 影响范围

这个问题**只影响 WSL2 ARM 环境**。以下环境不受影响：

- ✅ 原生 Linux ARM（树莓派、AWS Graviton 等）
- ✅ macOS ARM（Apple Silicon M1/M2/M3）
- ✅ Linux/Windows x86_64
- ❌ WSL2 ARM（Windows on ARM 下的 WSL）

### 长期展望

这个问题需要上游修复——要么 wazero 提供环境变量开关跳过寄存器读取，要么 WSL2 ARM 支持 MRS 指令模拟。在此之前，patch + 源码编译是唯一可行的方案。

---

**参考资料:**
- Hugo Releases: https://github.com/gohugoio/hugo/releases
- wazero: https://github.com/tetratelabs/wazero
- WSL2 ARM: https://learn.microsoft.com/en-us/windows/wsl/
