---
name: workbuddy-skill-sync
description: "Open-source a WorkBuddy skill to dual Git platforms (Gitee as primary for domestic direct access plus GitHub as mirror) with a one-click sync script. Unlike the personal version, this skill is interactive: it asks the user for their own skill name, paths, Git usernames, and public/private choice via questions before doing anything. Use this skill when the user wants to publish, mirror, version-control, or set up git for a WorkBuddy skill and expects to fill in their own details."
version: 1.0.0
agent_created: true
license: MIT
---

# WorkBuddy 技能开源同步（开源交互版）

把 WorkBuddy 技能开源到 **Gitee（主）+ GitHub（镜像）** 双平台，并提供 **一键同步脚本**。本版本是**面向所有人可复用的开源版**：它不会写死任何人的用户名或路径，而是**先用提问把用户自己的信息收集齐**，再执行。

> 个人专属版是 `workbuddy-skill-opensource-sync`（已写死 sys-sds 默认值，给自己用）。这个版本是给任何人用的通用版。

## 何时使用

- 用户说「把这个技能开源」「推到 GitHub/Gitee」「做个同步脚本」「版本管理我的技能」。
- 用户希望**自己补充**用户名、路径、公私设置，而不是用别人写死的默认值。

## 第一步：用提问收集用户的专属信息（关键差异）

在动任何文件之前，**先用 `AskUserQuestion` 向用户收集以下信息**（一次问完，不要分多次）：

| 提问项 | 说明 | 示例 |
|--------|------|------|
| 要开源的技能名 | 技能文件夹名 | `psych-ally` |
| 源技能路径 | 真正被 WorkBuddy 加载的那份 | `C:\Users\你的用户名\.workbuddy\skills\技能名` |
| 本地仓库路径 | 非系统盘上的开源副本目录 | `F:\repo\技能名` |
| Gitee 用户名 | 码云主页英文名 | `你的用户名` |
| GitHub 用户名 | GitHub 主页用户名 | `你的用户名` |
| 公开 / 私有 | 两个平台是否公开 | 公开 |

如果用户已在前文给过这些信息，跳过对应项，不要重复问。

## 关键事实（避免踩坑）

1. **WorkBuddy 技能两级目录**：
   - 用户级：`~/.workbuddy/skills/<name>/` —— 所有项目可用，是实际加载位置。
   - 项目级：`<workspace>/.workbuddy/skills/<name>/` —— 仅本工作区可用。
   - 开源副本放非系统盘（如 F 盘）即可，**真正被加载的仍是用户级那份**。

2. **双副本防漂移**：用户级 = 活跃技能（平时改它）；非系统盘 = 开源镜像（推远程用）。两者不自动同步，靠 `scripts/sync-skill.ps1` 同步。

3. **国内网络现实**：GitHub 的 git 通道常不稳定，推送需开梯子；**Gitee 国内直连，推送无需梯子** → 因此 Gitee 作主推送目标，GitHub 作镜像。

4. **WorkBuddy 内置 GitHub 连接器即使 disconnected 也不影响**：用 **GitHub Desktop**（独立桌面程序，走浏览器 OAuth 授权）即可正常推送。

5. **绝不修改源技能**：本技能只复制/同步，绝不改动 `~/.workbuddy/skills/` 下的源技能内容。

## 标准流程（收集完信息后执行）

### 1. 准备本地仓库副本

```powershell
robocopy "<源技能路径>" "<仓库路径>" /E /XD .git /NFL /NDL /NJH /NJS
```

### 2. 初始化 git（纯本地，不联网、不碰令牌）

```bash
cd "<仓库路径>"
git init
# 写 .gitignore：忽略 OS/编辑器/缓存垃圾
git add -A
git commit -m "Initial commit: <技能名> v<版本>"
```

### 3. 配置双远程（用收集到的用户名）

```bash
git remote add origin  https://github.com/<GitHub用户名>/<技能名>.git   # 镜像
git remote add gitee   https://gitee.com/<Gitee用户名>/<技能名>.git      # 主
```

> Gitee 仓库需用户先在 gitee.com 创建**同名空仓库**（不要勾「用 README 初始化」，否则冲突）。

### 4. 首次推送

- **Gitee（主）**：`git push -u gitee master` —— 国内直连，无需梯子。
- **GitHub（镜像）**：在 GitHub Desktop 里「发布仓库」（选公开/私有）或 `git push -u origin master`（需梯子）。

### 5. 生成一键同步脚本

用 `scripts/sync-skill.ps1`，把收集到的信息作为命令行参数传入即可：

```powershell
.\sync-skill.ps1 -SkillName <技能名> `
  -RepoPath "<仓库路径>" `
  -GiteeRemote https://gitee.com/<Gitee用户名>/<技能名>.git `
  -GitHubRemote https://github.com/<GitHub用户名>/<技能名>.git
```

脚本核心：**复制 → 有变更才 commit → 推 gitee → 推 origin（任一步失败不致命）**。

### 6. 教用户用 GitHub Desktop（中文界面）

若用户装了汉化版 GitHub Desktop，引导路径见 `references/setup-guide.md`：
安装 → 跑汉化补丁（`GitHubDesktop2Chinese.exe`）→ 浏览器登录 → 添加本地仓库（选 F 盘路径）→ 发布仓库（选公开即开源）。

## 复用资源

- `scripts/sync-skill.ps1` —— 参数化一键同步脚本（无写死用户名，纯参数驱动）。
- `references/setup-guide.md` —— 面向用户的完整中文设置指南。
- `LICENSE` —— MIT 许可证，本技能可自由分发与二次创作。
- `README.md` —— 安装与使用说明。

## 检查清单

- [ ] 已用提问收集用户的技能名 / 源路径 / 仓库路径 / 双平台用户名 / 公私设置
- [ ] 源技能未改动，仅复制出开源副本
- [ ] `.gitignore` 已写，首次提交成功
- [ ] 双远程（gitee 主 / origin 镜像）已用用户的用户名配置
- [ ] Gitee 空仓库已创建且用户名正确
- [ ] 一键同步脚本可用，跑一次验证同步 + 双平台推送
