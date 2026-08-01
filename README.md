# WorkBuddy 技能开源同步（开源交互版）

把 WorkBuddy 技能开源到 **Gitee（主，国内直连）+ GitHub（镜像）** 双平台，并提供一键同步脚本。

**这是面向所有人可复用的开源版**——它不会写死任何人的用户名或路径，而是先用提问把你的信息收集齐，再执行。如果你想要一个写死自己默认值、给自己用的版本，看同作者的个人版 `workbuddy-skill-opensource-sync`。

## 安装

把本仓库（或解压 zip）放到你的技能目录之一即可被 WorkBuddy 加载：

- 用户级（所有项目可用）：`~/.workbuddy/skills/workbuddy-skill-sync/`
- 项目级（仅本工作区）：`<workspace>/.workbuddy/skills/workbuddy-skill-sync/`

## 怎么用

直接对 WorkBuddy 说类似的话：

> 「把这个技能开源到 GitHub，用 Gitee 做主仓库」

技能会先问你几个问题（技能名、源路径、仓库路径、Gitee/GitHub 用户名、公开还是私有），收集完后自动：

1. 把活跃技能复制到非系统盘仓库目录（**不改动源技能**）
2. `git init` + 首次提交
3. 配置双远程（Gitee 主 / GitHub 镜像）
4. 推 Gitee（国内直连）→ 推 GitHub（镜像）
5. 生成一键同步脚本，以后改完技能跑一下就同步+推送

## 文件说明

| 文件 | 作用 |
|------|------|
| `SKILL.md` | 技能主入口，含交互式提问流程 |
| `scripts/sync-skill.ps1` | 参数化一键同步脚本（无写死用户名） |
| `references/setup-guide.md` | 中文设置指南（Gitee 注册、GitHub Desktop 汉化与发布） |
| `LICENSE` | MIT 许可证 |

## 注意事项

- GitHub 的 git 通道在国内常不稳定，推送需开梯子；Gitee 国内直连，无需梯子。
- WorkBuddy 内置 GitHub 连接器即使显示 disconnected 也不影响：用 GitHub Desktop（浏览器授权）即可正常推送。
- 开源副本与活跃技能是两份，靠同步脚本保持一致，不会自动同步。

许可证：MIT
