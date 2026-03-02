# 文档质量标准

本文档定义生成文档的质量标准和检查清单。

**前置阅读**：生成文档前，请先阅读 [doc-responsibility.md](./doc-responsibility.md) 了解文档职责边界。

## 准确性 (Accuracy)

### 核心要求

**MUST**：
1. **每块内容必须有代码引用**（文件全路径:行号）
2. **设计模式必须有实际代码支撑**
3. **技术栈必须有依赖或配置证明**

**示例**：

```markdown
"所有领域实体必须继承 BaseEntity 类"
代码引用：src/main/java/domain/model/UserEntity.java:15
```

### 信息来源优先级

1. **源代码**（最高优先级）：类、方法、注释、配置文件
2. **项目文档**：README.md等项目内文档、通过MCP工具读取到的文档内容

### 禁止内容

**MUST NOT**：
1. ❌ 没有代码引用的表述。宁可不写，别不能写找不到信息来源的内容
2. ❌ 过时或不存在的代码引用

### 准确性检查清单

- [ ] 每个原则/规范/模式/清单都有代码引用
- [ ] 所有代码引用准确（文件路径和行号正确）
- [ ] 没有不确定词汇（"可能"、"大概"、"也许"）

## 可读性 (Readability)

### 结构要求

**MUST**：
1. 使用清晰的标题层级（# 一级 ## 二级 ### 三级）

**SHOULD**：
1. 使用列表组织信息

### 表格使用

**SHOULD**：对于结构化信息，优先使用表格

### Mermaid 图表使用

**SHOULD**：对于复杂的架构、流程、依赖关系，使用 Mermaid 图表

### 代码引用格式

**MUST**：使用标准格式

```markdown
path/to/file:line

示例：
src/main/java/com/example/service/UserService.java:15

如果有多个文件引用，则多行：
src/main/java/com/example/service/UserService.java:15
src/main/java/com/example/service/OrderService.java:20
src/main/java/com/example/service/ProductService.java:30
```

### 避免内容重复

**MUST**：
- 不同文档之间不应重复相同内容
- 如需引用其他文档内容，使用文档链接
- 严格遵守 [doc-responsibility.md](./doc-responsibility.md) 定义的文档职责边界

### 可读性检查清单

- [ ] 标题层级清晰（1-3 级为主）
- [ ] 使用列表组织要点
- [ ] 结构化信息使用表格
- [ ] 复杂关系使用 Mermaid 图表
- [ ] 代码引用格式统一
- [ ] 没有内容重复

## 核心原则

高质量文档的核心原则：

1. **准确为先**：基于代码事实，有据可查
2. **可操作为要**：明确规范，提供示例
3. **可读为本**：结构清晰，格式规范
4. **完整为基**：覆盖必要信息，无遗漏
5. **一致为纲**：术语统一，描述一致
6. **维护为重**：便于更新，易于扩展

**最重要的一条**：

> 宁可少写，不可写错。
> 如果代码中找不到证据，宁可说"未发现"，也不要基于假设编写文档。
