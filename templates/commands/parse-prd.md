---
description: 为 PRD 生成完整的结构化需求文档（EARS 格式）
argument-hint: <PRD文档路径> [输出路径] [额外说明]
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a technical plan for the structured requirements. I am building with...
  - label: Clarify Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true
scripts:
  sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
---

## User Input

```text
$ARGUMENTS
```

你**必须**在处理之前先查看用户输入（如果非空）。

## Outline

用户输入中的 **PRD 文档路径**（及可选的输出路径、额外说明）即本次处理的依据。PRD 路径为必填；假定已在对话中提供，**不要重复索要**（仅当用户未提供任何输入时再提示）。给定上述输入，按下列步骤执行。

## Core Task

基于 PRD 中的项目描述，为功能生成完整、可测试的 EARS 格式需求。

**Success Criteria**:
- 创建与项目定位对齐的完整需求文档
- 所有验收标准遵循项目的 EARS 规则与约束
- 专注于核心功能，不包含实现细节

## Execution Steps

### 1. Validate（前置校验）

- 用户输入必须包含 **PRD 文档路径**（必填）。若未提供，终止并提示："请提供 PRD 文档路径，例如：/speckit.parse-prd path/to/prd.md"
- 若提供了 **输出路径**（如 `specs/001-功能名/结构化需求.md`），则使用该路径；若未提供，则由步骤 2 根据 PRD 确定输出路径并在必要时创建分支与目录
- 校验 PRD 路径指向的文件存在且可读；若不存在或不可读，终止并提示

### 2. 确定输出路径并确保 feature 分支与目录存在

与 `/speckit.specify` 一致：在写入 结构化需求.md 前，若目标 feature 分支或 `specs/<编号>-<短名>/` 不存在，先调用 create-new-feature 脚本创建分支与目录，再使用其输出路径。

- **2.1 确定目标路径**
  - 若用户提供了**完整输出路径**（如 `specs/001-返点返货发放/结构化需求.md`）：解析得到编号 `NNN` 与短名 `short-name`（目录名为 `NNN-short-name`）。
  - 若未提供：从 PRD 内容（标题或首段）提炼 2–4 词短名（规则参考 specify 的 short name 约定），编号待定（见 2.3）。
- **2.2 检查目录/分支是否存在**
  - 目标目录：`specs/<NNN>-<short-name>/`（若尚未定编号，先通过 2.3 的“三源”定号）。
  - 若仓库有 git：检查是否存在分支 `NNN-short-name`，或 `specs/NNN-short-name` 目录已存在即视为已就绪。
  - 若目标目录已存在（且可选地分支存在）：跳过创建，直接使用该路径写 `结构化需求.md`。
- **2.3 若目录或分支不存在：执行与 specify 一致的分支创建**
  - 执行 `git fetch --all --prune`。
  - **编号规则**：若用户已给出路径中的编号 NNN，使用该 NNN。若未给出：从三处取最大编号——远程分支 `git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`、本地分支 `git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`、已有目录 `specs/[0-9]+-<short-name>`；取最大 N，新分支用 N+1（无匹配时用 1）。
  - 调用 `{SCRIPT}`：`{SCRIPT} --json --number <N> --short-name "<short-name>" "<description>"`。description 使用 PRD 文档标题或 `From PRD: <用户提供的PRD路径>`；单引号等需转义时与 specify 相同（如 `'I'\''m Groot'`）。
  - 从脚本 JSON 输出读取 `BRANCH_NAME`；最终输出路径为 `specs/<BRANCH_NAME>/结构化需求.md`。
- **2.4 约束**：仅当目标 specs 目录或对应分支不存在时调用脚本；已存在则不再创建。与 specify 一致：只运行一次创建脚本，通过脚本输出确定最终 `specs/...` 路径。若需创建分支与目录，使用 frontmatter 中的 scripts 调用 create-new-feature 并解析 JSON 得到 BRANCH_NAME。

### 3. Load Context

- 若用户提供了已有的 `结构化需求.md` 路径，详细阅读其内容，评估修改方案
- 如果用户提供了原始 PRD，详细阅读 PRD 的所有内容：
  - 功能需求描述、用户故事、业务流程图
  - **所有附图/表格（必须读取，图片中往往包含关键的业务规则和数据结构）**
    - 如无法直接读取，尝试使用图片读取工具
    - 若仍无法读取，必须向用户说明并请求协助
- **加载 context**：选择性读取 `.specify/memory/` 目录中的文件，包括应用架构、应用职责

### 4. Read Guidelines

- 读取 `.specify/settings/rules/ears-format.md` 获取 EARS 语法规则
- 读取 `.specify/templates/requirements-template.md` 获取文档结构

### 5. Clarify Ambiguities（如需要）

**反问决策树**（按顺序判断）:
```
PRD 分析结果?
├─ 所有核心需求已明确? → 跳过反问，进入步骤 6
├─ 仅个别细节未说明? → 跳过反问，用 [待确认] 标注
└─ 关键不确定性 ≥ 1 项? → 触发反问（最多 2 个问题）
```

检查是否存在**关键不确定性**（满足任意 1 项即触发反问）:
- 功能边界不清：未明确是新增功能还是修改现有功能
- 业务规则缺失：关键条件判断、数据校验规则未在 PRD 中说明
- 验收标准模糊：成功/失败的判定条件不明确
- 数据来源未知：关键字段的来源不清楚
- 集成方式不明：需对接外部系统但方式未说明
- PRD 提出的问题没有在回答中覆盖的，视为不确定

**反问格式**（建议使用表格呈现选项与影响）:
```markdown
## 需求澄清

基于 PRD，以下方面需要确认:

### 问题 1 (Q1): [维度] - [具体问题]?

**上下文**：[引用 PRD 相关片段]

**需要确认**：[从关键不确定性提炼的具体问题]

**Suggested Answers**:

| Option | Answer | Implications |
|--------|--------|--------------|
| A      | [第一个选项描述] | [对需求/范围的影响] |
| B      | [第二个选项描述] | [对需求/范围的影响] |
| C      | [第三个选项，可选] | [对需求/范围的影响] |
| Custom | 用户自填 | 请直接写出你的答案 |

**你的选择**：_[等待用户回复]_

### 问题 2 (Q2): [维度] - [具体问题]?
（格式同上）

请一次性回复所有问题的选择，例如："Q1: A, Q2: B" 或 "1A, 2B"
```

**CRITICAL - 表格格式**：
- 表格对齐：管道符 `|` 对齐，单元格内保留空格（如 `| Content |` 而非 `|Content|`）
- 表头分隔行至少 3 个短横线：`|--------|--------|--------------|`
- 建议在 markdown 预览中检查表格渲染是否正确

**反问约束**:
- 最多 2 个问题，每题最多 3 个选项
- 必须是封闭式选择题
- 禁止询问实现细节（技术选型）
- 禁止询问 PRD 中已明确说明的内容
- 题目编号为 Q1、Q2；一次性展示所有问题后再等待用户回复
- 用户回复后，将所选答案写回 结构化需求.md 中对应位置，并可根据需要再次执行步骤 7 质量校验

**示例**:

✅ 好的反问:
```markdown
## 需求澄清

### 1. 功能范围: "用户认证"是指?
- 选项 A: 新增第三方登录(微信/支付宝)
- 选项 B: 为现有登录添加双因素认证

### 2. 失败处理: 登录连续失败时?
- 选项 A: 失败 3 次锁定 15 分钟
- 选项 B: 失败 5 次要求验证码

请回复(如: 1A, 2B)
```

❌ 避免:
- "你想要什么效果?"（开放式）
- "用 REST 还是 GraphQL?"（实现细节）
- "给哪个角色用?"（PRD 中已说明）

**不满足反问条件**：直接进入步骤 6，小的不确定性用 `**[待确认]**` 标注。

### 6. Generate Requirements

- 替换占位符：`{{USER_ADDITIONAL_NOTES}}` → 用户输入的额外说明（原样保留，不要修改）
- 基于 PRD 描述创建初始需求
- 将相关功能分组为逻辑需求区域
- 对所有验收标准应用 EARS 格式
- 使用中文
- 输出到步骤 2 确定的路径：`specs/<BRANCH_NAME>/结构化需求.md`（目录已由步骤 2 的 create-new-feature 或既有结构保证存在）

### 7. 需求质量校验（Requirements Quality Validation）

写入 结构化需求.md 后，按下列检查项做一次自检：

**检查项**：
- [ ] 无实现细节（技术栈、API、代码结构）
- [ ] 需求可测试、无歧义
- [ ] 验收标准已应用 EARS 格式
- [ ] 需求标题为前导数字 ID（如「需求 1」），无字母 ID
- [ ] 关键 [待确认] 已通过步骤 5 澄清闭环，或已明确标注为可选/备选

**处理**：
- **全部通过**：进入步骤 8 报告
- **有不通过项**：列出不通过项及在文档中的位置，修正内容后重检（最多 1–2 轮）；若仍不通过，在报告中说明剩余问题并建议用户修订后再执行 `/speckit.plan`

### 8. 报告完成

见下方 **Output Description** 与 **Next Phase**，报告须包含输出路径、需求摘要、质量校验结果与下一步建议。

## Quick Guidelines

- 关注 **WHAT** 用户需要与 **WHY**，避免 **HOW**（不写技术实现、API、代码结构）
- 面向业务与产品方，而非开发实现细节
- 澄清仅在步骤 5 进行；数量与优先级明确（范围 > 安全/合规 > 体验 > 技术细节）

## Important Constraints

- **分支与目录**：在写入 结构化需求.md 前，按与 `/speckit.specify` 相同的规则确保 feature 分支与 `specs/<编号>-<短名>/` 存在；若不存在则调用 create-new-feature 脚本（见 frontmatter scripts）创建，再写入需求文件。
- 专注于 **WHAT**，而非 **HOW**（无实现细节）
- 需求必须可测试和可验证
- 为 EARS 语句选择适当的主语（软件使用 系统/服务 名称）
- 结构化需求.md 中的需求标题必须包含前导数字 ID（例如："需求 1"）；不要使用字母 ID 如 "需求 A"
- **反问时机**：仅在步骤 5 进行，一旦开始步骤 6 生成需求，禁止再反问
- **反问数量**：严格限制 1–2 个封闭式选择题，总字数不超过 200 字
- **不确定性处理**：小的不确定性用 `**[待确认]**` 标注，不触发反问

## 生成时（For AI Generation）

- **合理推断**：基于 PRD 与 `.specify/memory/` 上下文做合理推断，不必事事澄清
- **记录假设**：在文档中记录关键假设与默认选择（如占位或「假设」小节）
- **限制澄清**：仅对关键不确定性发起澄清（最多 2 个问题）；按影响排序：范围 > 安全/合规 > 体验 > 技术细节
- **可测试优先**：每条需求必须可测试、无歧义；模糊表述视为不通过质量校验

## 验收标准 / Success Criteria 指南

验收标准（EARS）须满足：

1. **可测量**：含具体指标（时间、比例、数量、频率等）
2. **技术无关**：不出现框架、语言、数据库、工具名
3. **用户视角**：从用户/业务结果描述，而非系统内部实现
4. **可验证**：可不依赖实现细节进行测试或验收

**好示例**：
- 「用户可在 3 分钟内完成下单」
- 「系统支持 1 万并发用户」
- 「95% 的查询在 1 秒内返回结果」

**坏示例**（偏实现）：
- 「API 响应时间低于 200ms」（过技术化，应改为用户可感知的结果）
- 「数据库支持 1000 TPS」（实现细节）
- 「Redis 缓存命中率高于 80%」（技术绑定）

## Tool Guidance

- **Read first**：在生成之前加载所有上下文（PRD、memory、rules、templates）
- **Write last**：仅在完成生成后写入 结构化需求.md
- 仅在需要外部领域知识时使用 **WebSearch/WebFetch**

## Output Description

报告完成时**必须**包含以下内容：

1. **输出路径**：生成的 结构化需求.md 的完整路径（如 `specs/[编号]-[需求名称]/结构化需求.md`）
2. **Generated Requirements Summary**：主要需求区域的简要概述（3–5 条要点）
3. **质量校验结果**：步骤 7 自检通过/不通过；若不通过，列出剩余问题及建议
4. **Next Steps**：下一步建议——若需求已就绪，建议运行 `/speckit.plan` 制定技术方案；若需修订，建议先修改 结构化需求.md 再执行 `/speckit.plan`

**Format Requirements**:
- 使用 Markdown 标题以保持清晰
- 在代码块中包含文件路径
- 保持摘要简洁（300 字以内）

## Safety & Fallback

### Error Scenarios

- **Ambiguous Requirements**:
  - 如果满足反问条件（关键不确定性 ≥ 1 项），执行步骤 5 反问
  - 如果不满足，直接生成需求，用 `**[待确认]**` 标注不确定点
  - 标注示例:
    ```markdown
    **[待确认]** 连续登录失败处理:
    - 推荐: 失败 3 次锁定 15 分钟
    - 备选: 失败 5 次要求验证码
    ```
- **Template Missing**：如果 template 或 ears-format 文件不存在，使用内联 fallback 结构并发出警告
- **Incomplete Requirements**：生成后，明确询问用户需求是否涵盖所有预期功能
- **Steering Directory Empty**：若 `.specify/memory/` 缺失或为空，警告用户项目上下文缺失可能影响需求质量，建议先执行 `specify init` 或 `/speckit.constitution` 初始化项目与知识库
- **Non-numeric Requirement Headings**：如果现有标题不包含前导数字 ID（例如使用 "需求 A"），将其规范化为数字 ID 并保持该映射一致（永远不要混合数字和字母标签）

### Next Phase

**需求批准后**：
- 查看生成的结构化需求文档：`specs/[编号]-[需求名称]/结构化需求.md`
- **下一步**：运行 `/speckit.plan` 制定技术方案；若需求尚需修订，先修改 结构化需求.md 再执行 `/speckit.plan`
- 报告完成时须明确写出上述输出路径、需求摘要、质量校验结果及下一步建议（见 **Output Description**）
