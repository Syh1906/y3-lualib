# Game 与引擎 API 桥

这份 reference 用于定位 `y3.game`、`GameAPI`、表格、KV、常量和平台接口。

## `game/game.lua`

`game/game.lua` 定义 `Game`，主体是对 `GameAPI` 和全局引擎 API 的 Lua 封装。

常见入口：

- 游戏状态与全局设置。
- 表格读取。
- 客户端 tick。
- HTTP 请求。
- 胜负、暂停、时间、镜头等全局能力。

查 `y3.game.xxx` 时，先看 `init.lua` 挂载，再看 `game/game.lua`。

## 表格读取

`Game.get_table` 是表格数据读取入口，可按参数选择是否转 Lua 表。涉及编辑器表格、资源表、物编相关数据时，先查：

- `game/game.lua`
- `doc/API/Game.md`
- `game/helper.lua`

## 常量与配置

- `game/const.lua` 提供 `y3.const`。
- `game/config.lua` 处理框架配置。
- `meta/enum.lua` 提供枚举类型声明。

不要把常量名字当运行时行为；行为仍需回到具体封装函数。

## KV

`game/kv.lua` 定义 `KV` 能力，很多对象通过继承或组合获得 KV 读写。

查对象 KV 能力时：

1. 看对象类是否继承 `KV`。
2. 看 `game/kv.lua`。
3. 看对象具体是否把 KV 转发到引擎对象。

## py/lua 转换

`game/py_converter.lua` 是 py 对象和 Lua 对象互转入口。对象包装、事件参数转换、API 返回对象都可能经过这里。

## 平台接口

`game/steam.lua` 处理平台好友、组队、房间、平台交易、匹配等接口。它属于平台桥接，不是通用地图业务流程。

## 证据路径

- `init.lua`
- `game/game.lua`
- `game/helper.lua`
- `game/kv.lua`
- `game/config.lua`
- `game/const.lua`
- `game/py_converter.lua`
- `game/steam.lua`
- `meta/gameapi*.lua`
- `meta/globalapi.lua`
- `doc/API/Game.md`
