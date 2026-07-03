# 变化检测

当开发仓发生变化时，用这份清单判断是否要更新 `y3-kernel-navigator`。

## 必须复核 navigator 的变化

- `init.lua` 新增、删除、移动 `y3.*` 挂载。
- `tools/class.lua`、`tools/reload.lua`、`tools/sandbox.lua` 行为变化。
- `game/game_event.lua`、`game/py_event_subscribe.lua`、`game/core_object_event.lua` 事件链变化。
- `util/event*.lua`、`util/trigger.lua`、`util/sync.lua`、`util/local_timer.lua`、`util/client_timer.lua` 变化。
- `object/` 下新增对象类型或迁移对象文件。
- `ui_framework/` 或 `object/scene_object/ui*.lua` 变化。
- `util/object.lua`、`meta/editor_object.lua` 变化。
- `.luarc.json`、`.luals/resolve-y3-require.lua` 变化。
- `doc/API.md` 或 `doc/API/*.md` 增删改名。
- `meta/event.lua`、`meta/must_sync.lua`、`meta/gameapi*.lua`、`meta/globalapi.lua` 变化。

## 通常不更新 navigator 的变化

- `演示/` 业务样例变化。
- `testcase/`、`unittest/` 测试变化。
- `.github/`、`.vscode/`、仓库 CI 配置变化。
- `third_party/` 第三方库内部变化，除非用户明确要把行为树作为独立 reference。

## 变更判断输出

维护时给出：

- 变更文件。
- 影响的 navigator reference。
- 是否需要更新。
- 不更新的理由。
