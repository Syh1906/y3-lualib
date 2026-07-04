# 版本规则

> Parent: [index.md](index.md)

本文说明 y3-lualib 的双版本机制。双版本用于同时记录上游基准和本地分支迭代。

## 字段

`release.lua` 是版本信息的数据源。

- `upstream.code`：上游基准数字版本，继续用于兼容 `y3.version`。
- `upstream.tag`：上游基准标签；如果当前上游没有标签，写 `未配置`。
- `upstream.commit`：当前分支采用的上游基准提交。
- `upstream.source`：上游基准来源。
- `local_branch.code`：本地迭代数字版本。
- `local_branch.tag`：本地迭代标签。
- `local_branch.name`：本地分支名称。
- `compatibility.y3_editor`：当前分支面向的 Y3 编辑器版本。
- `compatibility.y3_helper`：当前分支建议配套的 y3-helper 版本；未确认前写 `待确认`，发布前必须在检查清单中复核。
- `full_name`：日志和反馈中使用的完整展示文本。

## 运行时接口

- `y3.version`：上游基准数字版本，保留旧接口语义。
- `y3.release`：完整版本信息。
- `y3.upstream_version`：上游基准数字版本。
- `y3.local_version`：本地迭代数字版本。
- `y3.full_version`：完整展示文本。

## 命名

上游标签使用上游自己的命名；没有上游标签时用 `upstream.code` 和 `upstream.commit` 定位。当前分支的本地标签使用：

```text
moy-YYYY.MM.DD.N
```

`N` 表示当天第几次本地发布。
