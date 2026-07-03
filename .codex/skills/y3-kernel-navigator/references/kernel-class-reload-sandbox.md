# 类系统、热重载与沙盒

这份 reference 用于理解 Y3 Lua 内核的对象创建、继承、生命周期、热重载和沙盒加载。

## 类系统入口

`init.lua` 将 `tools/class.lua` 挂到 `y3.class`，并导出全局便捷函数：

- `Class`
- `New`
- `Extends`
- `Delete`
- `IsValid`
- `Type`
- `Alias`
- `IsInstanceOf`

不要只看全局函数名判断语义；要回到 `tools/class.lua` 查实现。

## `tools/class.lua`

关注点：

- 类注册表、别名表、类配置表。
- `declare` 创建类。
- `extends` 建立继承关系。
- 初始化链和析构链。
- 热重载时的 `Config:reset`。
- getter/setter、字段压缩、预分配能力。

常见定位：

- 新类定义：查 `M.declare`。
- 继承关系：查 `M.extends` 和 `Config`。
- 对象释放：查 `delete`、`__del`、析构链。
- 热重载异常：查 `Config:reset`。

## `tools/gc.lua`

`GCHost` 是很多对象的生命周期能力来源。看到类继承 `GCHost` 时，要检查它是否绑定资源、触发器、引用或 UI 事件。

## `tools/reload.lua`

热重载相关能力：

- `Reload` 类管理重载。
- `M.include` 是可重载加载入口。
- 全局 `require` 被重写，用于记录 include 栈。
- `include = y3.reload.include` 在 `init.lua` 中导出。

注意：`include` 被 `.luarc.json` 标记为 `require` 特殊语义，LuaLS 会按模块加载理解它。

## `tools/sandbox.lua`

沙盒能力用于隔离加载环境。读这部分时关注：

- 环境白名单。
- 沙盒 `require`。
- 模块加载环境替换。

不要把沙盒当成地图业务隔离框架；它是内核加载工具。

## 证据路径

- `init.lua`
- `tools/class.lua`
- `tools/gc.lua`
- `tools/reload.lua`
- `tools/sandbox.lua`
- `.luarc.json`
