# 内核模块分层

这份 reference 用于快速判断问题属于哪个内核区域。不要把目录名当成完整结论；定位后仍要读对应源码。

## 总览

```text
init.lua
  -> tools/           Lua 基础设施
  -> game/            Y3 引擎桥接与全局游戏能力
  -> util/            框架胶水和跨对象能力
  -> object/          Lua 对 Y3 对象的包装
  -> ui_framework/    面板、弹窗、Tips、UI 管理器
  -> meta/            LuaLS 与引擎 API 元信息
  -> doc/API/         对外 API 文档
```

## `tools/`

基础设施层。包括：

- 类系统：`tools/class.lua`
- 热重载：`tools/reload.lua`
- 沙盒加载：`tools/sandbox.lua`
- 协程等待：`tools/await.lua`
- JSON、inspect、utility、pool、gc、linked-table、SDBMHash、serialization、synthesis。

遇到对象模型、生命周期、重载、基础工具问题时先读这里。

## `game/`

引擎桥接层。包括：

- `game/game.lua`：`Game` 能力和 `GameAPI` 封装。
- `game/game_event.lua`：全局游戏事件。
- `game/core_object_event.lua`：对象事件入口。
- `game/py_event_subscribe.lua`：Python/Y3 事件到 Lua 事件的桥。
- `game/py_converter.lua`：py 对象与 Lua 对象转换。
- `game/const.lua`、`game/config.lua`、`game/kv.lua`、`game/helper.lua`、`game/math.lua`、`game/steam.lua`。

遇到表格、全局游戏接口、引擎事件、平台接口时先读这里。

## `util/`

框架胶水层。包括：

- 事件：`event.lua`、`event_manager.lua`、`trigger.lua`、`custom_event.lua`
- 数据：`storage.lua`、`save_data.lua`、`fs.lua`
- 同步/本地：`sync.lua`、`local_timer.lua`、`client_timer.lua`
- ECA：`eca_function.lua`、`eca_helper.lua`、`eca_runtime.lua`
- UI 辅助：`local_ui.lua`
- 加密/编码：`aes.lua`、`rsa.lua`、`base64.lua`
- 物编封装：`object.lua`

遇到跨对象能力、同步边界、物编数据、ECA 时先读这里。

## `object/`

对象包装层。分三组：

- `object/editable_object/`：单位、技能、物品、Buff、可破坏物、投射物、科技。
- `object/runtime_object/`：玩家、单位组、玩家组、计时器、运动器、伤害实例、治疗实例、声音、粒子、光束。
- `object/scene_object/`：点、区域、镜头、灯光、路径、形状、UI、UI 预制体。

遇到 `y3.unit`、`y3.player`、`y3.ui` 等对象 API 时先读这里。

## `ui_framework/`

UI 管理框架。包括：

- `ui_framework/init.lua`：入口。
- `ui_framework/api.lua`：公开 API。
- `ui_framework/UIManager.lua`：UI 管理器。
- `ui_framework/base/`：`BaseView`、`BasePanel`、`BaseTips`、`EventBus`。
- `ui_framework/share.lua`：内部共享状态，不建议用户直接 require。

遇到 `y3.ui_manager`、面板、弹窗、Tips、ESC 栈时先读这里。

## `meta/`

类型和引擎元信息层。包括：

- `meta/gameapi*.lua`、`meta/globalapi.lua`：引擎 API 声明。
- `meta/event.lua`：事件配置。
- `meta/editor_object.lua`：物编字段类型。
- `meta/enum.lua`：枚举。
- `meta/must_sync.lua`：必须同步 API 列表。

这层主要服务 LuaLS 和类型理解，不是运行时业务入口。

## 排除范围

- `演示/`：学习样例，不是内核规范。
- `testcase/`、`unittest/`：测试。
- `third_party/`：第三方库。
- `develop/`：开发模式能力，普通地图项目不要优先依赖。
