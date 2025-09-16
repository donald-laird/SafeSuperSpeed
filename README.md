# SuperSpeed 全面测速脚本 (安全增强版)

这是一个基于 [BlueSkyXN](https://github.com/BlueSkyXN/SpeedTestCN) 的 `superspeed.sh` 脚本进行优化和增强的版本。我们保留了原脚本所有经过验证的功能和便利性，同时专注于弥补其唯一的缺陷：**缺乏一个健壮的自动清理机制**。

这个增强版的目标是：**功能上与原版完全一致，但在安全性和整洁性上超越原版**。



## ✨ 核心特性

- **功能完整**: 完整保留了原作者的所有功能，包括：
  - **自动依赖安装**: 自动检测并安装 `python`, `curl`, `wget` 等缺失的依赖，在新服务器上真正实现“开箱即用”。
  - **系统兼容性**: 能够识别 CentOS, Debian, Ubuntu 等主流 Linux 发行版。
  - **丰富的测速节点**: 提供针对国内三大运营商（电信、联通、移动）的全面测速节点。
- **🚀 关键优化 - 自动清理**:
  - **无残留**: 无论脚本是正常执行完毕、中途出错、还是被用户手动中断 (`Ctrl+C`)，都会**自动、可靠地**清理所有下载的临时文件 (`speedtest.tgz`, `speedtest-cli`, `speedtest.log`)。
  - **优雅退出**: 优化了中断信号处理，使用 `Ctrl+C` 可以干净利落地退出脚本，不会卡在循环中。

## 🚀 快速开始

请在拥有 `root` 权限的环境下执行以下命令。脚本会自动处理依赖安装和测速。

**使用 cURL (推荐):**

```
sudo bash <(curl -Lso- https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh)
```

**使用 Wget:**

```
sudo bash <(wget -qO- https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh)
```

## 📝 使用说明

1. 脚本会要求 `root` 权限，这是为了能够自动安装可能缺失的依赖包。
2. 运行后，您会看到一个菜单，可以选择不同的测速模式：
   - **三网测速**: 快速测试到三大运营商部分精华节点的速度。
   - **电信/联通/移动节点**: 分别对指定运营商的更多节点进行全面测试。
3. 测试结束后，所有临时文件将被自动删除，无需手动干预。

## 🤔 为何选择这个版本？

我们相信，最好的优化是尊重并保留原作经过大量用户验证的核心功能。此版本没有对原脚本的测速逻辑、节点选择做任何改动，只专注于解决“临时文件残留”这一个痛点，使其成为一个功能强大且使用舒心的服务器测速工具。