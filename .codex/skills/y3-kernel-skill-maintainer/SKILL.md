---
name: y3-kernel-skill-maintainer
description: 仅在 y3-lualib 开发仓维护 Y3 内核导航 skill 时使用。适用于检查或更新 .codex/skills/y3-kernel-navigator、同步 reference 与 init.lua、game、util、object、ui_framework、meta、doc/API、.luarc.json 的源码事实，以及发布前验证 navigator 能为 Y3 地图开发需求提供内核相关 API、源码证据和项目侧衔接边界且没有混入开发仓维护流程。不用于普通地图项目。
---

# Y3 内核导航维护

这个 skill 只服务 `y3-lualib` 开发仓，用来维护 `y3-kernel-navigator`。普通地图项目不应携带或触发这个 skill。

## 仓库门禁

使用前必须确认当前工作区是 `y3-lualib` 开发仓：

1. 存在 `init.lua`、`README.md`、`.luarc.json`。
2. 存在 `game/`、`util/`、`object/`、`tools/`、`doc/API.md`。
3. 存在 `.codex/skills/y3-kernel-navigator/SKILL.md`。

不满足时停止，不把地图项目当成开发仓维护。

## 职责

1. 检查 `navigator` 是否仍反映当前源码事实。
2. 更新 `navigator` 的 reference，但不把开发仓维护流程写入 `navigator`。
3. 检查 `init.lua` 的 `y3.*` 挂载、LuaLS 配置、公开 API 文档和内核目录变化。
4. 验证 `navigator` 能服务地图开发需求，提供 Y3 内核相关能力、API、源码证据和项目侧衔接边界。
5. 验证 `navigator` 可以独立用于普通地图项目。

## 按需加载

| 维护任务 | 先读 |
|---|---|
| 确认维护源头 | `references/source-of-truth.md` |
| 检查 navigator 边界 | `references/navigator-contract.md` |
| 判断源码变化影响 | `references/change-detection.md` |
| 执行同步维护 | `references/sync-workflow.md` |
| 发布前验收 | `references/validation-checklist.md` |

## 同步检查脚本

运行只读检查：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/skills/y3-kernel-skill-maintainer/scripts/check-y3-kernel-skill-sync.ps1 -Json
```

脚本只检查当前开发仓状态，不修改文件。出现错误时返回固定 JSON 状态，不做兜底修复。

## 职责边界

- 只在 `y3-lualib` 开发仓运行维护流程。
- 维护脚本、同步门、发布检查只留在 maintainer 内。
- `演示/` 只作为参考证据，不写成 navigator 默认实现路径。
- 源码重构不属于本 skill 职责。
- 业务兜底逻辑或兼容分支不属于本 skill 职责。
