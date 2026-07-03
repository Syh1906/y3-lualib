---
name: y3-kernel-navigator
description: 当用户提出 Y3 地图开发需求，或需要理解、定位、解释、使用 Y3 Lua 框架内核相关能力时使用。适用于 y3-lualib 开发仓或地图工程中的 script/y3 副本，帮助识别需求涉及的 init.lua 启动链、模块分层、类系统、热重载、事件/触发器、对象包装、UI 内核、运行时同步/本地边界、API 文档和 LuaLS/LuaCATS 证据，并说明这些 Y3 能力如何与地图项目已有扩展工具库、业务封装或公共模块衔接。不用于维护 skill 自身。
---

# Y3 内核导航

这个 skill 帮你在 Y3 地图开发需求中识别 Y3 内核相关的能力、API、源码实现和使用边界。它提供 Y3 库证据和接入点；地图项目已有的扩展工具库、业务封装和公共模块也应纳入方案判断。

## 工作原则

1. 先定位当前工作区形态：`y3-lualib` 开发仓、地图工程中的 `script/y3` 副本，或带有项目扩展代码的地图工程。
2. 把用户需求拆成 Y3 相关能力和项目侧能力：对象、事件、UI、同步、本地上下文、表格、物编、工具层，以及项目已有扩展或业务封装。
3. 先读任务对应的 reference，最多先读 1 到 2 个；需要更细的 API 时再查源码或 `doc/API`。
4. 事实优先级：项目代码和本地源码 > `doc/API` > LuaLS 配置 > reference 摘要。
5. 回答实现类需求时给出 Y3 相关入口、关键 API、注意边界、源码路径，以及与项目既有封装的衔接建议。
6. 证据不足时停止说明缺口，不编造 API。
7. `演示/`、`testcase/`、`unittest/`、`third_party/` 只作为参考证据，不当成内核规则来源。

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

## 使用边界

- 面向用户需求提供 Y3 内核相关证据、API 入口和接入边界；最终方案可以结合项目侧扩展工具库、业务封装和公共模块。
- 当地图项目已有扩展工具库、业务封装或公共模块时，把它们视为项目侧实现入口，再说明它们与 Y3 能力的关系。
- 不预设某一种地图项目业务架构。
- skill 自身变更交给维护类 skill。
- 默认以 `y3` 封装为入口；只有用户明确研究底层差异时再定位底层 CAPI。
- 代码建议保持源码事实边界，不引入兜底行为、自动降级路径或业务兼容分支。
