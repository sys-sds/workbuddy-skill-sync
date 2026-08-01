# 中文设置指南：把 WorkBuddy 技能开源到 Gitee + GitHub

本指南面向使用者，全程中文界面操作。

## 一、准备 Gitee（国内直连，首选主仓库）

1. 打开 https://gitee.com 注册账号（免费）。
2. 点右上角「+」→「新建仓库」。
3. 填写：
   - 仓库名称：与你的技能同名（如 `psych-ally`）
   - 路径：自动生成，保持与名称一致
   - 是否开源：公开 或 私有 随你
   - **不要勾**「使用 Readme 文件初始化这个仓库」（否则会和本地已有内容冲突）
4. 创建。记下你的 Gitee 用户名（网址 `gitee.com/你的用户名` 里的英文名）。

## 二、准备 GitHub（国际镜像，可选）

1. 打开 https://github.com 注册/登录。
2. 仓库稍后由「GitHub Desktop 发布」自动创建，无需手动建。
3. 记下你的 GitHub 用户名。

## 三、GitHub Desktop（汉化版，用于发布到 GitHub）

1. 安装 GitHub Desktop。
2. **关闭** GitHub Desktop，运行汉化补丁 `GitHubDesktop2Chinese.exe`，重新打开即为中文。
3. 顶部菜单「文件 → 选项 → 登录 GitHub.com」，浏览器授权登录（不用手动填令牌）。
4. 「文件 → 添加本地仓库」，选择你的 F 盘仓库目录。
5. 点右上角「发布仓库」：
   - 仓库名填技能名
   - 选「公开」（即开源）或「私有」
   - 点发布 → 自动建仓库并推送

## 四、推送通道说明

| 平台 | 是否需梯子 | 说明 |
|------|-----------|------|
| Gitee | 否，国内直连 | 首选主推送目标 |
| GitHub | 是，需梯子 | 镜像；用 GitHub Desktop 发布最稳 |

> 如果 GitHub 推送卡住：临时开梯子，或在 GitHub Desktop 点「推送」前开着即可；推完可关。

## 五、以后更新流程

1. 在 `~/.workbuddy/skills/<技能名>/` 改技能（真正被加载的那份）。
2. 运行 `scripts/sync-skill.ps1`，把你的信息作为参数传入：

```powershell
.\sync-skill.ps1 -SkillName <技能名> `
  -RepoPath "F:\repo\<技能名>" `
  -GiteeRemote https://gitee.com/<你的Gitee用户名>/<技能名>.git `
  -GitHubRemote https://github.com/<你的GitHub用户名>/<技能名>.git
```

3. 脚本自动同步 + 推送双平台。

## 六、双副本防漂移提醒

- 用户级 `~/.workbuddy/skills/<技能名>/` = 活跃技能（平时改它）
- 非系统盘仓库 = 开源镜像（推远程用）
- 两份不会自动同步，改完记得跑同步脚本。
