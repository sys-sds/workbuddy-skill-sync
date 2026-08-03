---
name: workbuddy-skill-sync
description: "GENERIC, redistributable tool that helps ANY user open-source a WorkBuddy skill to Gitee (primary, works without VPN in China) plus GitHub (mirror). Asks the user for their own skill name, paths, Gitee/GitHub usernames and public/private choice via questions BEFORE touching any file, then sets up the repo, dual remotes and a one-click sync script. Ships with MIT LICENSE and README so it can be shared with others. Do NOT use for the maintainer's own pre-configured sys-sds workflow - that is workbuddy-skill-opensource-sync."
version: 1.1.0
agent_created: true
license: MIT
---

# WorkBuddy 技能开源同步（通用交互版）

把任意 WorkBuddy 技能开源到 **Gitee（主）+ GitHub（镜像）**，并留下一键同步脚本。本版本**不写死任何人的用户名或路径**，先提问收集信息再执行，因此可以自由分发给别人用。

> **选错了？** 如果你是本机主人、要发布自己那套已配好的仓库（固定用户名 + 固定 F 盘路径 + SSH/443）→ 用 `workbuddy-skill-opensource-sync`（零提问直接执行）。本技能会先问你一堆问题，自己用反而慢。

## 第一步：提问收集专属信息（本技能的核心差异）

动任何文件之前，**先用 `AskUserQuestion` 一次问完**：

| 提问项 | 说明 | 示例 |
|--------|------|------|
| 要开源的技能名 | 技能文件夹名 | `psych-ally` |
| 源技能路径 | 真正被 WorkBuddy 加载的那份 | `C:\Users\你的用户名\.workbuddy\skills\技能名` |
| 本地仓库路径 | 非系统盘上的开源副本目录 | `F:\repo\技能名` |
| Gitee 用户名 | 码云主页英文名 | — |
| GitHub 用户名 | GitHub 主页用户名 | — |
| 公开 / 私有 | 两个平台是否公开 | 公开 |

用户前文已给过的项直接跳过，不要重复问。

## 关键事实（避免踩坑）

1. **WorkBuddy 技能两级目录**
   - 用户级 `~/.workbuddy/skills/<name>/` —— 所有项目可用，**这是实际被加载的那份**。
   - 项目级 `<workspace>/.workbuddy/skills/<name>/` —— 仅当前工作区可用。
   - 开源副本放非系统盘即可，但被加载的仍是用户级那份。

2. **双副本会漂移**：用户级 = 活跃技能（平时改它）；仓库副本 = 开源镜像（推远程用）。两者不自动同步，必须靠同步脚本。

3. **国内网络**：Gitee 直连、无需梯子 → 作主推送目标。GitHub 的 **HTTPS** 通道常被重置，但 **SSH 走 443 端口通常可直连**（见下方"GitHub 推不动"）。

4. **绝不修改源技能**：本技能只复制/同步，不改 `~/.workbuddy/skills/` 下的内容。

## 标准流程（收集完信息后）

### 1. 复制出仓库副本

```powershell
robocopy "<源技能路径>" "<仓库路径>" /E /XD .git /NFL /NDL /NJH /NJS
```

`/XD .git` 保护仓库历史。robocopy 退出码 0–7 均为成功，≥8 才是失败。

### 2. 初始化 git（纯本地，不联网、不碰令牌）

```bash
cd "<仓库路径>"
git init
git add -A
git commit -m "Initial commit: <技能名> v<版本>"
```

`.gitignore` 模板见 `references/setup-guide.md`。

### 3. 配置双远程（用收集到的用户名）

```bash
git remote add gitee  https://gitee.com/<Gitee用户名>/<技能名>.git    # 主
git remote add origin https://github.com/<GitHub用户名>/<技能名>.git  # 镜像
```

> Gitee 需先在网站建**同名空仓库**，**不要勾**「用 Readme 初始化」，否则首推冲突。

### 4. 首次推送

- **Gitee（主）**：`git push -u gitee master` —— 国内直连。
- **GitHub（镜像）**：`git push -u origin master`，或用 GitHub Desktop「发布仓库」。

### 5. 生成一键同步脚本

```powershell
.\sync-skill.ps1 -SkillName <技能名> `
  -RepoPath "<仓库路径>" `
  -GiteeRemote https://gitee.com/<Gitee用户名>/<技能名>.git `
  -GitHubRemote https://github.com/<GitHub用户名>/<技能名>.git
```

核心逻辑：**复制 → 有变更才 commit → 推 gitee → 推 origin（任一步失败不致命）**。

## 常见问题

### GitHub 推不动（`Connection was reset`）

国内 HTTPS 直推 GitHub 经常被重置。按可靠性排序：

1. **SSH over 443（首选，多数情况无需梯子）**——在 `~/.ssh/config` 写：
   ```
   Host github.com
       HostName ssh.github.com
       Port 443
       IdentityFile <你的私钥路径>
   ```
   然后把远程改成 SSH 形式：`git remote set-url origin git@github.com:<用户名>/<仓库>.git`
   公钥需先加到 https://github.com/settings/keys （可能要求二次密码确认）。

   ⚠️ **Windows 陷阱**：`~/.ssh/config` 若带 BOM，git 会报 `Bad configuration option: \357\273\277`。用 PowerShell 写文件时务必：
   ```powershell
   [System.IO.File]::WriteAllText("$env:USERPROFILE\.ssh\config", $cfg, (New-Object System.Text.UTF8Encoding $false))
   ```

2. **配代理**（已有梯子时）：
   ```bash
   git config --global http.proxy http://127.0.0.1:7890
   ```

3. **只用 Gitee**，GitHub 放弃或偶尔手动同步。

> 手机 VPN 开热点给电脑**通常无效**——热点只共享上网，不共享 VPN 隧道，电脑仍是国内出口 IP，除非手机 VPN 支持「允许局域网连接」。

### git 命令找不到

Windows 便携版 git 不在 PATH 里，需手动加，例如：
```powershell
$env:PATH = "<你的 PortableGit 路径>\mingw64\bin;" + $env:PATH
```

## 复用资源

- `scripts/sync-skill.ps1` —— 纯参数驱动，无写死用户名。
- `references/setup-guide.md` —— 完整中文设置指南。
- `LICENSE`（MIT）+ `README.md` —— 使本技能可自由分发与二次创作。

## 检查清单

- [ ] 已提问收集：技能名 / 源路径 / 仓库路径 / 双平台用户名 / 公私设置
- [ ] 源技能未改动，仅复制出副本
- [ ] `.gitignore` 已写，首次提交成功
- [ ] 双远程已用**用户自己的**用户名配置
- [ ] Gitee 空仓库已建（未勾 Readme 初始化）
- [ ] 同步脚本跑通一次，双平台均有提交
