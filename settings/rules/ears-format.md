# EARS Format Guidelines

## Overview
EARS (Easy Approach to Requirements Syntax) 是 spec-driven development 中验收标准的标准格式。

EARS patterns 描述需求的逻辑结构（条件 + 主体 + 响应），不依赖于任何特定自然语言。
所有验收标准应使用中文编写。
保持 EARS 触发关键词和固定短语为英文（`When`、`If`、`While`、`Where`、`The system shall`、`The [system] shall`），仅将可变部分（`[event]`、`[precondition]`、`[trigger]`、`[feature is included]`、`[response/action]`）本地化为中文。不要在触发词或固定英文短语内部插入中文文本。

## Primary EARS Patterns

### 1. Event-Driven Requirements
- **Pattern**: When [event], the [system] shall [response/action]
- **Use Case**: 对特定事件或触发器的响应
- **Example**: When 用户点击结账按钮, the 结账服务 shall 验证购物车内容

### 2. State-Driven Requirements
- **Pattern**: While [precondition], the [system] shall [response/action]
- **Use Case**: 依赖于系统状态或前置条件的行为
- **Example**: While 支付正在处理中, the 结账服务 shall 显示加载指示器

### 3. Unwanted Behavior Requirements
- **Pattern**: If [trigger], the [system] shall [response/action]
- **Use Case**: 系统对错误、故障或非预期情况的响应
- **Example**: If 输入了无效的信用卡号, then the 网站 shall 显示错误消息

### 4. Optional Feature Requirements
- **Pattern**: Where [feature is included], the [system] shall [response/action]
- **Use Case**: 可选或条件性功能的需求
- **Example**: Where the 汽车有天窗, the 汽车 shall 具有天窗控制面板

### 5. Ubiquitous Requirements
- **Pattern**: The [system] shall [response/action]
- **Use Case**: 始终有效的需求和基本系统属性
- **Example**: The 移动电话 shall 重量小于100克

## Combined Patterns
- While [precondition], when [event], the [system] shall [response/action]
- When [event] and [additional condition], the [system] shall [response/action]

## Subject Selection Guidelines
- **Software Projects**: 使用具体的系统/服务名称（例如，"结账服务"、"用户认证模块"）
- **Process/Workflow**: 使用负责的团队/角色（例如，"支持团队"、"审查流程"）
- **Non-Software**: 使用适当的主体（例如，"营销活动"、"文档"）

## Quality Criteria
- 需求必须是可测试、可验证的，并描述单一行为。
- 使用客观语言：使用 "shall" 表示强制行为，使用 "should" 表示建议；避免模糊术语。
- 遵循 EARS syntax：[condition], the [system] shall [response/action]。
