# 同步与本地边界

这份 reference 用于处理 Y3 地图代码中的同步、本地玩家、本地计时器和 UI 回调风险。

## 基本判断

Y3 地图逻辑通常有同步状态。涉及本地玩家、UI 回调、客户端计时器、随机数、平台回调时，不要直接假设能安全修改同步状态。

## 关键模块

- `util/sync.lua`：本地数据同步给所有玩家。
- `object/runtime_object/timer.lua`：同步计时器。
- `util/local_timer.lua`：本地计时器。
- `util/client_timer.lua`：客户端计时器。
- `object/runtime_object/local_player.lua`：本地玩家包装。
- `object/scene_object/ui.lua`：本地 UI 事件提示。
- `meta/must_sync.lua`：必须同步 API 列表。
- `doc/API/Sync.md`、`doc/API/LocalTimer.md`、`doc/API/ClientTimer.md`、`doc/API/Timer.md`。

## 常见风险点

1. 本地 UI 回调只在本地客户端执行。
2. `y3.timer`、`y3.ltimer`、`y3.ctimer` 不是同一类能力，不能按名字相近互换。
3. `ClientTimer` 由本机时间驱动，源码注释明确是完全异步；不要用它驱动同步状态。
4. `LocalTimer` 支持本地或同步创建场景，但调用者仍要自己保证不会导致不同步。
5. `Sync.send` 要从本地环境发出，`Sync.onSync` 的回调在同步后执行；同一个 id 后注册会覆盖前注册。
6. `Sync.send(id, data, done)` 的 `done` 是发送方本地完成回调，不是所有玩家都会执行的同步回调。
7. `Player.with_local` 当前源码直接传入本地玩家并执行回调；`must_sync` 代理检查代码存在，但当前被早退路径绕过，不能当作运行时保护。
8. UI 的 `add_local_event`、`LocalUILogic:on_event/on_refresh/on_init` 都是本地玩家侧回调。
9. 平台回调、网络回调、本地玩家逻辑不应直接修改需要所有玩家一致的状态。
10. 必须同步 API 要参考 `meta/must_sync.lua`，但不要假设框架一定会自动拦截。
11. 不确定时读源码和 API 文档，不给兜底建议。

## 重点 API 边界

| 能力 | 文件 | 边界 |
|---|---|---|
| `Sync.send/onSync` | `util/sync.lua` | 本地发起，同步接收；数据经 `y3.dump` 编解码 |
| `Timer` | `object/runtime_object/timer.lua` | 同步计时器 |
| `LocalTimer` | `util/local_timer.lua` | 本地计时器，依赖逻辑帧推进 |
| `ClientTimer` | `util/client_timer.lua` | 客户端计时器，完全异步，游戏暂停时仍会继续 |
| `LocalPlayer` | `object/runtime_object/local_player.lua` | 包装本地玩家环境；当前 `Player.with_local` 早退，不能依赖其自动拦截危险 API |
| `UI:add_local_event` | `object/scene_object/ui.lua` | 本地客户端立即回调，不与其他玩家同步 |
| `LocalUILogic` | `util/local_ui.lua` | 本地 UI 初始化、事件和刷新回调 |

## 回答要求

涉及同步/本地边界时，回答必须说明：

- 当前代码可能运行在哪一侧。
- 是否读过 `meta/must_sync.lua` 或相关 API 文档。
- 哪些操作需要同步派发或服务器/同步上下文。
- 哪些结论仍需在具体地图运行时验证。

## 证据路径

- `util/sync.lua`
- `util/local_timer.lua`
- `util/client_timer.lua`
- `object/runtime_object/local_player.lua`
- `object/scene_object/ui.lua`
- `meta/must_sync.lua`
- `doc/API/Sync.md`
- `doc/API/Timer.md`
- `doc/API/LocalTimer.md`
- `doc/API/ClientTimer.md`
