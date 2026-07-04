# 发布检查清单

> Parent: [index.md](index.md)

发布本地迭代版本前，按本清单检查。

## 版本信息

- [ ] `release.lua` 的 `upstream.code` 与 `y3.version` 兼容。
- [ ] `release.lua` 的 `upstream.tag`、`upstream.commit`、`upstream.source` 已更新。
- [ ] `release.lua` 的 `local_branch.code` 和 `local_branch.tag` 已更新。
- [ ] `release.lua` 不依赖 `GameAPI`、`log`、`y3`、计时器、网络或文件 I/O。
- [ ] `compatibility.y3_helper` 已确认；如果仍为 `待确认`，发布说明必须写明原因。

## 运行时

- [ ] `init.lua` 在创建 `y3` 后加载 `y3.release`。
- [ ] `y3.version` 继续来自 `y3.release.upstream.code`。
- [ ] 启动日志输出 `y3.full_version`。

## 文档

- [ ] `更新日志.md` 已归档“未发布”内容。
- [ ] README 的“当前版本”与 `release.lua` 一致。
- [ ] Issue 模板包含上游基准、本地迭代、Y3 编辑器和 y3-helper 版本字段。

## 验证

```powershell
rg --line-number "GameAPI|log\\.|y3\\.|require|io\\.|os\\.|ltimer|timer|network" release.lua
rg --line-number --fixed-strings "y3.version = y3.release.upstream.code" init.lua
rg --line-number --fixed-strings "log.info('LuaLib版本：', y3.full_version)" init.lua
rg --line-number --fixed-strings "## 未发布" 更新日志.md
rg --line-number --fixed-strings "## 当前版本" README.md
```
