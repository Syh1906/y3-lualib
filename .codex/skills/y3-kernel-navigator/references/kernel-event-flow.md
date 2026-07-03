# 事件与触发器流

这份 reference 用于理解 Y3 Lua 事件如何从引擎进入 Lua，并如何注册、匹配、派发和释放。

## 五层分辨

Y3 事件不要只看 `Game:event`。先区分五层：

| 层 | 入口 | 主要文件 |
|---|---|---|
| 全局事件 | `Game:event`、`Game:subscribe_event` | `game/game_event.lua`、`game/py_event_subscribe.lua` |
| 对象事件 | `Unit:event`、`Player:event` 等继承 `CoreObjectEvent` 的对象 | `game/core_object_event.lua`、`meta/event.lua` |
| 自定义事件 | `event_on`、`event_notify`、`event_dispatch` | `util/custom_event.lua`、`util/event_manager.lua` |
| Trigger 生命周期 | `Trigger:disable_once/remove/on_remove/unique` | `util/trigger.lua`、`util/event.lua` |
| py 事件桥 | py 参数转换、全局触发器注册 | `game/py_event_subscribe.lua`、`game/py_converter.lua` |

## 全局事件流向

```text
Game:event
  -> EventManager:event
  -> Trigger
  -> py_event_subscribe.event_register
  -> 引擎全局触发器
  -> py 参数转换
  -> EventManager 通知 Lua callback
```

## 全局游戏事件

`game/game_event.lua` 让 `Game` 具备 `CustomEvent` 能力，并持有全局 `EventManager`。

查全局事件时：

1. 看 `Game:event`。
2. 看 `Game:get_event_manager`。
3. 看 `Game:subscribe_event` 如何调用 `y3.py_event_sub.event_register`。

## 引擎事件桥

`game/py_event_subscribe.lua` 负责：

- 注册全局触发器。
- 将 py 参数转换为 Lua 参数。
- 管理事件引用。
- 将事件派发回 Lua 事件管理器。

如果用户问“为什么回调参数是 Lua 对象”，要继续读 `game/py_converter.lua`。

## 对象事件

`game/core_object_event.lua` 负责对象级事件。它不是 `Game:event` 的语法糖，而是按 `meta/event.lua` 的事件配置恢复对象、过滤目标，并绑定对象 GC。

普通对象事件流向：

```text
Object:event
  -> CoreObjectEvent:event
  -> CoreObjectEvent:core_subscribe
  -> object_event_manager:event
  -> regist_object_event(handle, config.key, callback, ...)
  -> py 参数转换
  -> trigger:execute(lua_params)
```

只有 `meta/event.lua` 中配置了 `from_global` 的对象事件，才会走 `core_subscribe_from_global` 转到 `y3.game:event`，再由 `get_master` 从全局事件参数中筛选当前对象。

对象事件定位步骤：

1. 读对象类是否继承 `CoreObjectEvent`。
2. 读 `CoreObjectEvent:event`。
3. 读 `CoreObjectEvent:core_subscribe`。
4. 读 `meta/event.lua` 中对应事件参数配置，包括 `object`、`extraObjs`、`params`、`from_global`、`resolve`。
5. 如果事件配置 `from_global = true`，继续读 `core_subscribe_from_global` 和 `util/get_master.lua`。

对象事件注册后，底层会调用 `regist_object_event`，移除 trigger 时会通过 `trigger:on_remove` 调用 `unregist_object_event`。如果对象支持 `GCHost:bindGC`，trigger 会跟随对象生命周期释放。

## 自定义事件

`util/custom_event.lua` 给对象提供 Lua 层自定义事件能力：

- `event_on` 注册事件。
- `event_notify` 是通知模式，嵌套通知会被 `EventManager` 排队。
- `event_dispatch` 是回执模式，某个回调返回非 `nil` 后停止后续回调。
- `event_dispatch` 不走 `notify` 的嵌套排队分支；需要判断重入时，直接读 `EventManager:dispatch`。

不要把自定义事件和引擎事件混在一起判断。自定义事件不会自动注册 py 触发器。

## 触发器与事件容器

`util/event_manager.lua` 管理事件表和对象表。
`util/event.lua` 表示单个事件容器。
`util/trigger.lua` 表示一次注册的触发器。

关注点：

- `EventManager` 正在派发时，嵌套 `notify` 会进入队列，派发结束后再释放队列。
- `Event` 遍历期间增删触发器会放到 `wait_pushing` / `wait_poping`，派发结束后统一处理。
- `Trigger:disable_once` 只影响一次派发。
- `Trigger:remove` 走 `Delete`，触发 `__del`，再从 `Event` 中移除并执行 `_on_remove`。
- `Trigger:unique(name)` 会先移除同名旧 trigger，再记录当前 trigger。
- 事件参数匹配模式包括 `none`、`custom`、`array`。

## 证据路径

- `game/game_event.lua`
- `game/py_event_subscribe.lua`
- `game/core_object_event.lua`
- `util/event_manager.lua`
- `util/event.lua`
- `util/trigger.lua`
- `util/custom_event.lua`
- `util/get_master.lua`
- `meta/event.lua`
