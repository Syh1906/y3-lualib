# 上游同步

> Parent: [index.md](index.md)

本文说明同步上游 y3-lualib 时需要记录的内容。

## 同步前

同步前记录当前状态：

- 当前 `release.lua` 中的 `upstream.tag`
- 当前 `release.lua` 中的 `upstream.commit`
- 当前本地分支标签
- 本地未发布变更

## 同步后

同步后更新：

- `release.lua` 的 `upstream`
- `更新日志.md` 的“上游同步”
- 需要用户关注的兼容影响

## 冲突记录

如果同步时出现冲突，在提交或发布说明中记录：

- 冲突文件
- 保留上游实现还是本地实现
- 是否影响地图作者升级

不要把冲突处理细节写进 README。README 只保留版本入口。
