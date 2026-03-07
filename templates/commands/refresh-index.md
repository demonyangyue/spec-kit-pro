---
description: 刷新应用知识库索引文件 AGENTS.md
argument-hint: [额外要求]
---

## User Input

```text
$ARGUMENTS
```

你**必须**在处理之前先查看用户输入（如果非空）。

## Core Task

刷新 `.specify/memory/AGENTS.md` 索引文件，通过**调用 index-refresher agent** 完成：扫描 `.specify/memory/` 下应用知识文档，更新 `<project_rules>` 标签内的索引表格。

## Execution Steps

调度 **index-refresher agent**，刷新 `.specify/memory/AGENTS.md` 应用知识索引。

1. **若当前环境支持按名称/类型调用 subagent**（例如 `Task(subagent_type="index-refresher", ...)` 或等价方式）：
   - 使用该机制调度 index-refresher agent。
   - 将用户额外说明（`$ARGUMENTS`）作为 prompt 传入（可选）。

2. **若当前环境不支持 subagent 调用**：
   - 改为**执行** `.specify/agents/index-refresher.md` 中定义的步骤，完成同一目标（路径与行为与 agent 一致）。
