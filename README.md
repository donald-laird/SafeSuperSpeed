# SuperSpeed 安全优化版 (SuperSpeed Safe & Optimized)

这是一个基于 [BlueSkyXN](https://github.com/BlueSkyXN/SpeedTestCN) 的 `superspeed.sh` 脚本进行安全重构和功能优化的版本。本脚本旨在提供一个更安全、更干净、用户友好的方式来测试 Linux 服务器到国内三大运营商（电信、联通、移动）主要节点的网络速度。

## ✨ 核心特性

与原版脚本相比，本版本主要有以下几方面的增强：

- **🛡️ 更高的安全性**：
  - **无需 Root 权限**：脚本已移除强制 `root` 用户运行的限制，使用普通用户即可执行，显著降低了安全风险。
- **🧹 自动清理机制**：
  - **无残留文件**：集成了强大的 `trap` 清理机制。无论脚本是正常完成、中途出错还是被用户手动中断 (`Ctrl+C`)，都会**自动删除**所有下载的临时文件 (`speedtest.tgz`, `speedtest-cli/`) 和日志 (`speedtest.log`)，确保系统干净整洁。
- **👨‍💻 用户友好**：
  - **依赖预检查**：脚本会首先检查 `wget` 和 `tar` 命令是否存在。如果不存在，会给出清晰的提示，让用户自行安装，而不是在后台静默地对系统进行修改。
  - **清晰的菜单**：提供简单的交互式菜单，方便用户选择进行“三网综合测速”或针对某一运营商进行专项测试。
  - **友好的错误处理**：在下载和解压等关键步骤加入了错误判断，如果失败会立即停止并提示，避免后续问题。
- **🌐 核心功能**：
  - **三网覆盖**：内置了大量中国电信、中国联通、中国移动的 Speedtest 测速节点 ID。
  - **真实 Speedtest**：调用 Ookla 官方的 Speedtest® CLI 工具进行测速，结果准确可靠。

## 🚀 快速开始

您可以通过以下任一方法运行此脚本。

### 方法一：一键执行 (优雅 & 推荐)

这种方法最为便捷，它会直接下载脚本并立即执行，不会在您的系统上留下脚本文件。

**使用 `wget`:**

```
wget -qO- https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh | bash
```

**使用 `curl`:**

```
curl -sL https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh | bash
```

### 方法二：下载后执行 (更安全)

如果您想在执行前先审查脚本内容，推荐使用此方法。

1. **下载脚本:**

   ```
   # 使用 wget
   wget -O safe_superspeed.sh https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh
   # 或者使用 curl
   # curl -o safe_superspeed.sh https://raw.githubusercontent.com/donald-laird/SafeSuperSpeed/refs/heads/main/safesuperspeed.sh
   ```

2. **(可选) 审查脚本:**

   ```
   cat safe_superspeed.sh
   ```

3. **运行脚本:**

   ```
   chmod +x safe_superspeed.sh && ./safe_superspeed.sh
   ```

## 📋 先决条件

在运行此脚本之前，请确保您的系统已经安装了以下工具：

- `wget` 或 `curl` (用于下载脚本)
- `tar` (用于解压 Speedtest 工具)

如果脚本提示命令未找到，您可以使用系统的包管理器进行安装。例如：

- **Debian / Ubuntu**

  ```
  sudo apt update && sudo apt install wget tar -y
  ```

- **CentOS / RHEL**

  ```
  sudo yum install wget tar -y
  ```

## 📸 运行截图

```
正在检查依赖...
正在安装 Speedtest-cli...
——————————————————— SuperSpeed 安全优化版 ——————————————————
  本脚本移除了Root要求，并增加了自动清理机制，可以安全使用
——————————————————————————————————————————————————————————
  测速类型:    1. 三网测速    2. 取消测速
               3. 电信节点    4. 联通节点    5. 移动节点
  请输入数字选择测速类型 [1-5]: 1
——————————————————————————————————————————————————————————
ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms
3633  电信|上海                    ↑ 94.33     ↓ 94.75     4.56
27594 电信|广东广州５Ｇ            ↑ 88.12     ↓ 93.40     11.23
5396  电信|江苏苏州５Ｇ            ↑ 91.50     ↓ 94.01     8.15
...
——————————————————————————————————————————————————————————
  测试完成, 耗时: 1 分 28 秒
  当前时间: 2025-09-15 23:47:00
——————————————————————————————————————————————————————————

正在清理临时文件...
清理完成。
```

## 🙏 致谢

- **原始脚本作者**: [BlueSkyXN](https://github.com/BlueSkyXN/SpeedTestCN)
- **安全与功能优化**: Gemini

## 📄 许可证

本项目采用 [MIT License](https://www.google.com/search?q=LICENSE) 授权。