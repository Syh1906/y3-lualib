# 基础工具层

这份 reference 用于定位 `tools/` 中支撑 Y3 内核的基础设施。它只描述框架能力，不描述具体地图玩法组织方式。

## 关键文件

| 文件 | 作用 |
|---|---|
| `tools/class.lua` | `Class`、`New`、`Delete`、`IsValid`、`Extends`、字段压缩、析构顺序 |
| `tools/reload.lua` | `include`、热重载回调、按 include 名称清理旧回调 |
| `tools/sandbox.lua` | 沙盒执行环境 |
| `tools/pool.lua` | 带权重对象池 |
| `tools/gc.lua` | `GCHost`、`GC`、`GCNode` 生命周期绑定 |
| `tools/serialization.lua` | `y3.dump` 使用的序列化基础能力 |
| `tools/await.lua` | 协程式异步调度，睡眠唤醒器由 `init.lua` 配到 `y3.ltimer.wait` |

## 类系统入口

`init.lua` 会把类系统导出成全局快捷入口：

- `Class = y3.class.declare`
- `New = y3.class.new`
- `Extends = y3.class.extends`
- `Delete = y3.class.delete`
- `IsValid = y3.class.isValid`
- `Type = y3.class.type`
- `Alias = y3.class.alias`
- `IsInstanceOf = y3.class.isInstanceOf`

追对象生命周期时，先看 `tools/class.lua` 的 `delete`、`isValid`、`Config:runDel`，再看对象类自己的 `__del`。

## 生命周期绑定

`tools/gc.lua` 的 `GCHost:bindGC(obj)` 用于把触发器、计时器、临时对象或回调节点绑定到宿主对象。宿主被 `Delete` 后，绑定对象也会被 `Delete`。

常见来源：

- 对象类通过 `---@class X: GCHost` 或 `Extends('X', 'GCHost')` 获得能力。
- `CoreObjectEvent:core_subscribe` 注册对象事件后，会在对象支持 `bindGC` 时把 trigger 绑定到对象生命周期。
- `LocalUILogic` 继承 `GCHost`，会把动态创建的 UI 实例绑定到本地 UI 逻辑实例。

## 热重载与 include

`y3.reload.include` 被导出为全局 `include`。它和普通 `require` 的区别是：`include` 参与热重载管理，能记录当前 include 名称，并让 trigger、timer、LocalUILogic 等对象判断回调来源。

查热重载问题时：

1. 读 `tools/reload.lua`。
2. 查对象是否记录 `include_name` 或调用 `y3.reload.getIncludeName`。
3. 查是否注册 `onBeforeReload` 或 `onAfterReload`。

## Pool、Serialization、Await

- `tools/pool.lua` 对应公开文档 `doc/API/Pool.md`，用于按权重选择对象。
- `tools/serialization.lua` 由 `util/dump.lua` 使用，影响 `Sync.send`、网络消息和跨边界数据编码。
- `tools/await.lua` 提供 `await.call`、`yield`、`sleep` 等协程式流程；`init.lua` 最后会设置错误处理和 sleep 唤醒器。

## 证据路径

- `init.lua`
- `tools/class.lua`
- `tools/reload.lua`
- `tools/sandbox.lua`
- `tools/pool.lua`
- `tools/gc.lua`
- `tools/serialization.lua`
- `tools/await.lua`
- `util/dump.lua`
- `doc/API/Pool.md`
- `doc/API/Reload.md`
- `doc/API/Await.md`
