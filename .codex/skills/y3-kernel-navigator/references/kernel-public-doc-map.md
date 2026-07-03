# API 文档定位

这份 reference 用于从公开 API 文档快速回到源码。

## 文档入口

- `doc/API.md` 是 API 总索引。
- `doc/API/*.md` 是单类或单模块文档。
- 文档说明调用方式、参数、返回值，但不是源码加载顺序。

## 查找顺序

1. 在 `doc/API.md` 查 API 名或类型名。
2. 打开对应 `doc/API/<Name>.md`。
3. 回到 `init.lua` 查 `y3.xxx` 挂载。
4. 打开实现文件。
5. 必要时读 `meta/` 获取类型、事件、枚举和引擎 API 声明。

## 常见映射

| API 文档 | 主要源码 |
|---|---|
| `Game.md` | `game/game.lua` |
| `Unit.md` | `object/editable_object/unit.lua` |
| `Player.md` | `object/runtime_object/player.lua` |
| `Ability.md` | `object/editable_object/ability.lua` |
| `Item.md` | `object/editable_object/item.lua` |
| `Buff.md` | `object/editable_object/buff.lua` |
| `Destructible.md` | `object/editable_object/destructible.lua` |
| `Projectile.md` | `object/editable_object/projectile.lua` |
| `Point.md` | `object/scene_object/point.lua` |
| `Area.md` | `object/scene_object/area.lua` |
| `Trigger.md` | `util/trigger.lua` |
| `Timer.md` | `object/runtime_object/timer.lua` |
| `LocalTimer.md` | `util/local_timer.lua` |
| `ClientTimer.md` | `util/client_timer.lua` |
| `UI` | `object/scene_object/ui.lua`，当前可能没有同名 `doc/API/UI.md` |
| `UIPrefab.md` | `object/scene_object/ui_prefab.lua` |
| `SceneUI` | `object/scene_object/scene_ui.lua`，当前可能没有同名 `doc/API/SceneUI.md` |
| `LocalUILogic.md` | `util/local_ui.lua` |
| `EditorObject.md` | `util/object.lua`、`meta/editor_object.lua` |
| `Sync.md` | `util/sync.lua` |
| `SaveData.md` | `util/save_data.lua` |
| `Network.md` | `util/network.lua` |
| `KKNetwork.md` | `util/network.lua` 使用的底层网络对象文档入口 |
| `ECAFunction.md` | `util/eca_function.lua` |
| `ECAHelper.md` | `util/eca_helper.lua` |
| `Pool.md` | `tools/pool.lua` |
| `Reload.md` | `tools/reload.lua` |
| `Await.md` | `tools/await.lua` |
| `SandBox.md` | `tools/sandbox.lua` |

## 查询脚本

可用 `query-y3-kernel.ps1` 搜索 class、function、mount、doc：

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/skills/y3-kernel-navigator/scripts/query-y3-kernel.ps1 -Query Player -Kind all -Json
```

脚本输出只是定位辅助，最终行为以源码为准。

## 不要做的事

- 不把 `doc/API.md` 的顺序当加载顺序。
- 不因为文档缺失就编造接口。
- 不把 `演示/` 中的调用方式当 API 契约。
