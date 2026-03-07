# [需求名称] Web接口设计文档

<!--
如果当前需求需要提供对外提供HTTP接口，则编写此文档。

- 遵守当前项目Web接口规范
- 请求参数类型(Type): string / boolean / number / ObjectName / string[] / boolean[] / number[] / ObjectName[]
- BigDecimal: string
- Date: number(timestamp) / string(yyyy-MM-dd HH:mm:ss)
-->

## 接口概览

| Controller名称 | 接口路径 | 涉及需求编号 |
| --- | --- | --- |
| [ControllerName1] | [接口路径1] | [1,12,13] |
| [ControllerName1] | [接口路径2] | [20] |
| [ControllerName2] | [接口路径3] | [需求编号] |

## [ControllerName1（中文名称1）]

### [接口名称1，中文]

**接口路径**: [具体路径，如"xxx/xxx/page]

**请求方法**: [如：GET/POST/...]

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| [参数名，如：currentPage] | [Type1] | [是/否] | [中文说明，如：当前页码] |
| [参数名2] | [Type1] | [是/否] | [说明2] |
| [参数名3] | [Type2] | [是/否] | [说明3] |

**[ObjectName1]**
<!--
仅给出json数据示例，如：
```json
{
  "type": "foo",  // enum: foo | bar | qux
  "xxx": "xxx"
}
```
-->

**[ObjectName2]**
<!--
仅给出json数据示例，如：
```json
{
  "qux": "bar",
  "xxx": "xxx"
}
```
-->

**响应数据**: 
<!--
仅给出成功响应的json数据示例，如：
```json
{
  "success": true,
  "content": {
    "data": [
      {
        "status": "qux",  // enum: qux | baz
        "xxx": "xxx"
      }
    ],
    "total": 100,
    "currentPage": 1,
    "pageSize": 20
  }
}
```
-->

### [接口名称2，中文]

[格式同上]

## [ControllerName2（中文名称2）]

[格式同上]
