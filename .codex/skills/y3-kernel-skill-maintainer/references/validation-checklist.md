# 验收清单

维护完成前逐项检查。

## Skill 结构

- `y3-kernel-navigator/SKILL.md` frontmatter 合法。
- `y3-kernel-skill-maintainer/SKILL.md` frontmatter 合法。
- 两套 skill 都有 `agents/openai.yaml`。
- `agents/openai.yaml` 的 `default_prompt` 显式提到 `$skill-name`。
- skill 主目录在 `.codex/skills` 下，供 Codex App 识别。

## Navigator 边界

- 不引用 maintainer skill。
- 不包含开发仓同步门。
- 不要求普通地图项目重建索引。
- 能从地图开发需求定位到 Y3 内核能力、API 证据和项目侧衔接边界。
- 保留项目侧扩展工具库、业务封装和公共模块的接入空间。
- 没有把某一种地图项目架构写成通用规则。
- 不把演示代码写成框架规范。

## Maintainer 边界

- 明确只用于 `y3-lualib` 开发仓。
- 明确普通地图项目不使用。
- 只维护 navigator 与源码事实同步。
- 不修改地图业务代码。

## 源码证据

- `init.lua` 加载顺序说明仍准确。
- `.luarc.json` 和 `.luals/resolve-y3-require.lua` 说明仍准确。
- `object/` 三类对象说明仍准确。
- `ui_framework/` 和底层 UI 区分仍准确。
- `doc/API` 路由仍准确。

## 脚本

- `query-y3-kernel.ps1` 能返回 JSON。
- `check-y3-kernel-skill-sync.ps1` 能返回 JSON。
- 脚本输出状态只用 `ok`、`warning`、`error`。
- 脚本不修改文件。
