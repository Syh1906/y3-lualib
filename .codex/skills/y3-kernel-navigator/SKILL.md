---
name: y3-kernel-navigator
description: 当需要理解、定位、解释或使用 Y3 Lua 框架内核时使用。适用于 y3-lualib 开发仓或地图工程中的 script/y3 副本，覆盖 init.lua 启动链、模块分层、类系统、热重载、事件/触发器、对象包装、UI 内核、运行时同步/本地边界、API 文档定位和 LuaLS/LuaCATS 证据核验。不用于特定地图玩法业务流程或 skill 自身变更。
---

# Y3 内核导航

这个 skill 帮你从本地源码证据理解 Y3 Lua 框架内核。它只做导航、定位和解释，不设计地图玩法流程，也不维护 skill 自身。

## 工作原则

1. 先定位 Y3 根目录，再回答问题。
2. 先读任务对应的 reference，最多先读 1 到 2 个。
3. 事实优先级：本地源码 > `doc/API` > LuaLS 配置 > reference 摘要。
4. 引用接口时给出源码路径或 API 文档路径。
5. 证据不足时停止说明缺口，不编造 API。
6. 不把 `演示/`、`testcase/`、`unittest/`、`third_party/` 当成内核规则来源。

## 根目录定位

按顺序确认 Y3 根目录：

1. 当前目录存在 `init.lua`、`game/`、`object/`、`util/` 时，当前目录是 Y3 根。
2. 当前目录存在 `y3/init.lua`、`y3/game/`、`y3/object/` 时，`y3/` 是 Y3 根。
3. 从当前目录向父级查找以上两种形态。
4. 找不到时停止，说明没有发现 Y3 Lua 框架根目录。

## 按需加载

| 问题类型 | 先读 |
|---|---|
| 启动链、`y3` 全局、加载顺序 | `references/kernel-entry-and-load-order.md` |
| 模块分层、目录职责 | `references/kernel-module-map.md` |
| 类系统、热重载、沙盒 | `references/kernel-class-reload-sandbox.md` |
| 基础工具、对象池、GC、序列化、await | `references/tools-kernel.md` |
| 事件、触发器、对象事件 | `references/kernel-event-flow.md` |
| `GameAPI` 封装、表格、KV、常量 | `references/kernel-game-and-engine-api.md` |
| 单位、玩家、物品、技能、场景对象 | `references/kernel-object-model.md` |
| 物编数据和物编事件 | `references/kernel-editor-object.md` |
| UI handle、UI 框架、本地 UI | `references/kernel-ui.md` |
| 运行时同步、本地玩家、本地计时器 | `references/kernel-sync-local-boundaries.md` |
| 查某个 API 或文档入口 | `references/kernel-public-doc-map.md` |
| 回答前证据要求 | `references/evidence-rules.md` |

## 查询脚本

需要快速定位符号时，可运行：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/skills/y3-kernel-navigator/scripts/query-y3-kernel.ps1 -Query Unit -Kind all -Json
```

脚本只读本地源码，输出 JSON。找不到 Y3 根目录或索引源时会返回明确错误，不猜测。

## 禁止事项

- 不输出防守图、练功房、合成、商店、任务系统等玩法模板。
- 不把演示代码提升为框架规范。
- 不处理本 skill 自身变更。
- 不建议绕过 `y3` 封装直接调用底层 CAPI，除非用户明确要求研究底层差异。
- 不加入兜底行为、自动降级路径或业务兼容分支。
