# 同步维护流程

这个流程只在 `y3-lualib` 开发仓使用。

## 步骤

1. 确认仓库门禁通过。
2. 运行同步检查脚本。
3. 查看变更影响哪些 source-of-truth。
4. 读取对应源码和现有 navigator reference。
5. 更新 navigator reference。
6. 检查 navigator 契约，确保没有混入开发仓维护内容。
7. 运行 skill quick validation。
8. 运行同步检查脚本复核。

## 命令

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/skills/y3-kernel-skill-maintainer/scripts/check-y3-kernel-skill-sync.ps1 -Json
```

```powershell
python C:/Users/Administrator/.codex/skills/.system/skill-creator/scripts/quick_validate.py .codex/skills/y3-kernel-navigator
```

```powershell
python C:/Users/Administrator/.codex/skills/.system/skill-creator/scripts/quick_validate.py .codex/skills/y3-kernel-skill-maintainer
```

## 输出要求

维护结果说明：

- 改了哪些 navigator 文件。
- 为什么改。
- 依据哪些源码。
- 是否触及普通地图项目边界。
- 验证命令和结果。

## 停止条件

- 当前目录不是 `y3-lualib` 开发仓。
- `navigator` 缺失。
- 源码事实不清楚。
- 用户要求添加业务兜底逻辑但未确认。
