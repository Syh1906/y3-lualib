# 入口与加载顺序

先用这份 reference 判断 Y3 框架从哪里启动、哪些模块被挂到 `y3`，以及 LuaLS 如何解析 `y3.*` 模块。

## 入口文件

- `init.lua` 是框架真实加载顺序的主证据。
- `README.md` 说明项目定位和工程结构，但不要用 README 推断实际加载链。
- `.luarc.json` 和 `.luals/resolve-y3-require.lua` 决定 LuaLS 如何解析 `require 'y3.xxx'`。

## 加载骨架

按 `init.lua` 读取：

1. `GameAPI.lua_get_start_args()` 读取启动参数。
2. `require 'y3.debugger'` 加载调试器。
3. 创建全局 `y3` 并设置 `y3.version`。
4. 先加载 `tools` 基础能力：`proxy`、`class`、`utility`、`json`、`inspect`、`await`，并用 `pcall` 可选加载 `doctor`。
5. 导出全局类系统便捷函数：`Class`、`New`、`Extends`、`Delete`、`IsValid`、`Type`、`Alias`、`IsInstanceOf`。
6. 加载日志、热重载、沙盒、哈希、链表、对象池、GC、`util/synthesis.lua`。
7. 加载事件、触发器、自定义事件、存储、引用、GC buffer。
8. 加载 `game`、`timer`、`py_event_subscribe` 等运行期底座。
9. 挂载 `object/editable_object`、`object/runtime_object`、`object/scene_object`。
10. 挂载高级 util：`save_data`、`sync`、`network`、`eca`、`local_ui`、`fs`、`rsa`。
11. 可选加载 `y3-helper.meta`。
12. 加载 `develop` 调试助手和 `ui_framework`。
13. 配置 `await`，派发 `$Y3-初始化`，启动 Lua GC collector。

## LuaLS 解析

- `.luarc.json` 中 `runtime.pathStrict = true`。
- `.luarc.json` 通过 `runtime.plugin` 使用 `.luals/resolve-y3-require.lua`。
- `.luarc.json` 将 `include` 标记为 `require` 语义。
- `.luals/resolve-y3-require.lua` 只处理 `y3` 和 `y3.*` 模块名。

## 证据路径

- `init.lua`
- `.luarc.json`
- `.luals/resolve-y3-require.lua`
- `README.md`

## 使用提醒

回答启动链问题时，先读 `init.lua`。如果用户问“为什么 LuaLS 能识别 y3 模块”，再读 `.luarc.json` 和 `.luals/resolve-y3-require.lua`。
