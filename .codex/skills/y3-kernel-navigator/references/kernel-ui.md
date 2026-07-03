# UI 内核

这份 reference 用于区分底层 UI handle 包装、本地 UI 逻辑和 `ui_framework`。

## 四个子域

```text
object/scene_object/ui.lua      底层 UI handle 包装
object/scene_object/scene_ui.lua 场景 UI 节点
util/local_ui.lua               本地 UI 逻辑辅助
ui_framework/                   面板、弹窗、Tips、UI 管理器
```

## 底层 UI 对象

`object/scene_object/ui.lua` 定义 `UI`，包装玩家侧 UI handle。

关注点：

- `UI.get_by_handle` 使用玩家维度缓存 UI。
- UI 快速事件最终走玩家对象事件 `界面-消息`。
- 本地 UI 事件回调在本地玩家客户端执行，涉及同步风险。

涉及本地回调时，继续读 `kernel-sync-local-boundaries.md`。

## 场景 UI

`object/scene_object/scene_ui.lua` 定义 `SceneUI`，包装 `py.SceneNode`。它和普通 `UI` 控件不同：`SceneUI` 是挂在场景点或单位挂点上的场景节点，再通过 `get_ui_comp_in_scene_ui` 获取某个玩家视角下的 `UI` 控件。

关注点：

- `y3.scene_ui` 在 `init.lua` 中挂载。
- `SceneUI` 注册 `py.SceneNode` 到 `SceneUI` 的 py/lua 转换。
- 创建入口包括 `create_scene_ui_at_point`、`create_scene_ui_at_player_unit_socket`。
- 删除入口是 `remove_scene_ui`，本质调用 `Delete(self)`。

## 本地 UI 逻辑

`util/local_ui.lua` 处理本地 UI 实例、绑定、刷新、KV 应用等逻辑。它和同步状态边界关系密切。

公开入口挂在 `y3.local_ui`：

- `y3.local_ui.create(path_or_ui)` 创建并绑定本地 UI 逻辑。
- `y3.local_ui.prefab(prefab_name)` 创建可复用元件逻辑。
- `LocalUILogic:on_init/on_refresh/on_event` 的回调都在本地玩家环境中执行。
- `LocalUILogic` 继承 `Storage` 和 `GCHost`，会管理动态 UI 实例生命周期。
- 三类回调的错误处理以源码为准：`on_init`、`on_refresh` 由 `xpcall` 包裹，`on_event` 在 `register_events` 中直接调用回调。

## UI 框架

`ui_framework/init.lua` 是 UI 框架入口。框架初始化 `share.event` 和 `share.uiMgr`，并导出公开 API 到 `y3.ui_manager`。

关键文件：

- `ui_framework/api.lua`：公开 API。
- `ui_framework/UIManager.lua`：打开/关闭、栈、互斥、锁。
- `ui_framework/base/BaseView.lua`：视图控制器。
- `ui_framework/base/BasePanel.lua`：面板控制器。
- `ui_framework/base/BaseTips.lua`：提示控制器。
- `ui_framework/base/EventBus.lua`：事件总线。
- `ui_framework/share.lua`：内部共享状态，不建议用户直接 require。

## 定位步骤

1. 如果用户问具体 UI 控件方法，先读 `object/scene_object/ui.lua`。
2. 如果用户问场景 UI、单位头顶 UI、场景点 UI，先读 `object/scene_object/scene_ui.lua`。
3. 如果用户问面板/弹窗/Tips 管理，先读 `ui_framework/api.lua` 和 `UIManager.lua`。
4. 如果用户问本地 UI 状态和同步风险，读 `util/local_ui.lua` 与同步边界 reference。

## 样例定位

`演示/` 只能作为调用索引，不是框架规则。需要样例时可查：

- `演示/UI/场景UI.lua`
- `演示/UI/UI事件.lua`
- `演示/UI/UI演示-技能按钮.lua`
- `演示/demo/界面/*.lua`

## 证据路径

- `object/scene_object/ui.lua`
- `object/scene_object/ui_prefab.lua`
- `object/scene_object/scene_ui.lua`
- `util/local_ui.lua`
- `ui_framework/**`
- `doc/API/LocalUILogic.md`
- `doc/API/UIPrefab.md`
