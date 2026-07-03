# 物编数据

这份 reference 用于区分“运行中的单位/物品对象”和“物体编辑器数据”。

## 两条线

```text
运行中对象：
  object/editable_object/unit.lua
  object/editable_object/item.lua
  object/editable_object/ability.lua

物编数据：
  util/object.lua
  meta/editor_object.lua
  doc/API/EditorObject.md
```

不要把这两条线混在一起。

## `util/object.lua`

`util/object.lua` 定义 `EditorObject` 入口和数据模块。它用于读取、创建、修改物编数据，并把某些物编回调字段映射到实际游戏事件。

常见定位：

- 新建单位物编：查 `EditorObject.Unit`。
- 新建物品、Buff、技能物编：查对应内部类。
- 物编事件回调：查 callback 字段映射区域。

## `meta/editor_object.lua`

这里保存物编字段的 LuaCATS 类型声明。字段名、字段类型、可选项优先从这里确认。

## `doc/API/EditorObject.md`

这里是公开 API 文档。读写物编数据前先看这里的警告和限制，再回到源码确认行为。

## 使用边界

- 运行中 `Unit` 不是物编 `EditorObject.Unit`。
- 修改物编数据通常影响后续创建或编辑器数据，不等同于直接修改场上实例。
- 物编字段和事件映射要以源码和 meta 为准。

## 证据路径

- `util/object.lua`
- `meta/editor_object.lua`
- `doc/API/EditorObject.md`
- `object/editable_object/**`
