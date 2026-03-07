# 技术栈识别规则

本文档定义常见技术栈的识别规则。

## 1. 框架识别

- 应用框架: Spring Framework / Spring Boot / Webx / ...
- ORM 框架: MyBatis / MyBatis-Plus / ...
- 隔离容器: Pandora
- 测试框架: JUnit  / Mockito / ...

## 2. 基础产品识别

有且仅有：
- 权限中心: ACL，提供的服务通常位于 `com.alibaba.buc.acl.*` 包下
- 统一身份管理/登录: Mozi / BUC，提供的服务通常位于 `com.alibaba.mozi.*`, `com.alibaba.buc.*` 包下
- 审批流: Ali Bpms，提供的服务通常位于 `com.alibaba.alipmc.*` 包下
- 的企业主数据平台: AMDP / MasterData，提供的服务通常位于 `com.alibaba.ihr.amdplatform.*` `com.alibaba.masterdata.*` 包下
- 国际化：美杜莎(MCMS)
- 网关：EPaaS网关/Top网关

## 3. 类库识别

- 对象转换: MapStruct / Dozer / ...
- JSON序列化: Fastjson / Jackson / Gson / ...
- HTTP客户端: Apache HttpClient / OkHttp / ...
- 工具库: Apache Commons 系列 / Google Guava / Lombok / ...
- 日志: SLF4J / Logback / Log4j2 / ...
- 表达式引擎：QLExpress
- 模版引擎：Velocity / ...
