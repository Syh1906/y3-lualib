# 维护真相源

这个文件只服务 `y3-lualib` 开发仓。维护 `y3-kernel-navigator` 时，必须从源码事实出发。

## 必查源头

- `init.lua`：`y3.*` 挂载、加载顺序、全局别名、初始化流程。
- `.luarc.json`：LuaLS 行为、排除目录、插件、`include` 特殊语义。
- `.luals/resolve-y3-require.lua`：`y3.*` 模块解析。
- `README.md`：项目定位和公开工程结构。
- `doc/API.md`、`doc/API/*.md`：公开 API 文档。
- `game/`：引擎桥接。
- `tools/`：类系统、热重载、沙盒、基础工具。
- `util/`：事件、同步、ECA、存储、物编等胶水。
- `object/`：对象包装。
- `ui_framework/`：UI 管理框架。
- `meta/`：类型、事件、枚举、引擎 API 元信息。

## 次级参考

- `演示/` 只作为样例，不作为 navigator 内核规则。
- `testcase/`、`unittest/` 只作为测试参考。
- `third_party/` 不写入 Y3 内核导航主体。
- `develop/` 是开发模式能力，普通地图项目不可优先依赖。

## 维护原则

1. `navigator` 只能写可由当前开发仓源码证明的事实。
2. `navigator` 不包含开发仓同步门。
3. `navigator` 聚焦 Y3 内核事实，并能说明当前源码支持的能力如何接入地图项目已有代码。
4. 源码和文档冲突时，以源码为准，并在维护结果中记录冲突。
5. 找不到证据时，不更新为推测内容。
