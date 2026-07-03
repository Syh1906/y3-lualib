# 对象模型

这份 reference 用于理解 `object/` 中 Lua 对 Y3 引擎对象的包装方式。

## 三类对象

```text
object/editable_object/   运行时实体对象包装
object/runtime_object/    运行时抽象对象
object/scene_object/      场景放置或 UI/空间对象
```

## 物编对象包装

`object/editable_object/` 包括：

- `unit.lua`
- `ability.lua`
- `item.lua`
- `buff.lua`
- `destructible.lua`
- `projectile.lua`
- `technology.lua`

这些文件通常包装运行中的对象实例，不等同于 `util/object.lua` 的物编数据创建器。

## 运行时对象

`object/runtime_object/` 包括：

- `player.lua`
- `timer.lua`
- `force.lua`
- `mover.lua`
- `selector.lua`
- `unit_group.lua`
- `player_group.lua`
- `item_group.lua`
- `projectile_group.lua`
- `damage_instance.lua`
- `heal_instance.lua`
- `cast.lua`
- `sound.lua`
- `particle.lua`
- `beam.lua`
- `local_player.lua`
- `current_select.lua`

这些对象多用于运行时状态和临时实例。

## 场景对象

`object/scene_object/` 包括：

- `point.lua`
- `area.lua`
- `camera.lua`
- `light.lua`
- `road.lua`
- `shape.lua`
- `ui.lua`
- `ui_prefab.lua`
- `scene_ui.lua`

这些对象多对应场景、空间、UI handle 或编辑器放置对象。

## 包装模式

常见模式：

1. 类由 `Class` 定义。
2. 对象保存 py handle。
3. 通过 `Ref` 或弱表缓存 py handle 到 Lua 对象。
4. 通过 `game/py_converter.lua` 注册 py/lua 转换。
5. 通过继承获得 `GCHost`、`Storage`、`CustomEvent`、`CoreObjectEvent`、`KV`。
6. `__encode` / `__decode` 用于序列化或跨边界引用。

## 生命周期与身份缓存

对象生命周期由类系统和对象自身共同决定：

- `Delete(obj)` 调用 `tools/class.lua` 的 `delete`，设置 `__deleted__`，再按扩展初始化顺序的反序执行 `__del`。
- `IsValid(obj)` 只判断 Lua 类实例是否未被 `Delete`，不等同于引擎对象一定仍存在；很多对象还有自己的 `is_removed` 或 `is_exist` 检查。
- 对象类常在 `__del` 中调用 `remove`、`remove_scene_ui` 或底层 `GameAPI` 删除 handle。
- `GCHost:bindGC(obj)` 会把对象绑定到宿主生命周期；宿主已失效时，传入对象会被立即 `Delete` 并返回 `nil`。

身份缓存主要看 `util/ref.lua`：

- `Ref:get(key, ...)` 会先查强引用缓存，再创建 Lua 包装对象。
- 引擎销毁实体时，`notify_entity_destroyed` 会按实体模块找到对应 `Ref` 管理器并调用 `removeNow`。
- `removeNow` 会把对象标记为 `_removed_by_py`、替换 dummy handle、`Delete` Lua 对象，并把强引用转成弱引用。

py/lua 转换主要看 `game/py_converter.lua`：

- `register_py_to_lua(py_type, converter)` 注册 py handle 到 Lua 对象。
- `register_lua_to_py(py_type, converter)` 注册 Lua 对象到 py handle。
- `register_type_alias(py_type_name, lua_type_name)` 让 Lua 类型名映射到真实 py 类型。
- 对象文件中常见 `register_py_to_lua('py.Unit', M.get_by_handle)` 这一类注册。

## 继承能力索引

查一个对象为什么能存储、绑定 GC 或注册事件，优先看类头注解和 `Extends` 调用：

| 能力 | 来源 | 常见用途 |
|---|---|---|
| `GCHost` | `tools/gc.lua` | 绑定 trigger、UI、临时对象生命周期 |
| `Storage` | `util/storage.lua` | 对象私有存储 |
| `CustomEvent` | `util/custom_event.lua` | Lua 自定义事件 `event_on/event_notify/event_dispatch` |
| `CoreObjectEvent` | `game/core_object_event.lua` | 对象级引擎事件 |
| `KV` | `game/kv.lua` | 引擎 KV 读写 |

示例：`Unit` 同时继承 `GCHost`、`Storage`、`CustomEvent`、`CoreObjectEvent`、`KV`；`LocalUILogic` 通过 `Extends` 获得 `Storage` 和 `GCHost`。

## 定位步骤

查某个对象 API：

1. 从 `init.lua` 找 `y3.xxx = require ...`。
2. 打开对应 `object/**.lua` 文件。
3. 查类继承注解和 `Class` 定义。
4. 查 `get_by_handle`、`get_by_id`、`create` 等包装入口。
5. 查方法体里的 `GameAPI` 调用。
6. 对照 `doc/API/*.md`。

## 易混点

不要把 `object/editable_object/*.lua` 和 `util/object.lua` 混为一类：

- `object/editable_object/*.lua` 是运行中的单位、技能、物品、Buff、可破坏物、投射物等对象包装。
- `util/object.lua` 是物编配置数据入口，对应 `EditorObject.md` 和 `meta/editor_object.lua`。
- 看到 `EditorObject.*`、`Game.get_table`、物编事件时，转去读 `kernel-editor-object.md`。

## 证据路径

- `init.lua`
- `object/editable_object/**`
- `object/runtime_object/**`
- `object/scene_object/**`
- `util/ref.lua`
- `game/py_converter.lua`
- `tools/class.lua`
- `tools/gc.lua`
- `game/kv.lua`
- `util/storage.lua`
- `util/custom_event.lua`
- `game/core_object_event.lua`
