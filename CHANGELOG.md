# Changelog

All notable changes to SwiftMessengerLab are documented here. The project follows Semantic Versioning.

## [Unreleased]

### Added

- GitHub Pages Type Explorer 现在公开 52 张可搜索、可按模块和种类筛选、可展开的完整类型卡。
- 新增 Swift `TypeCatalog` 到 Pages JSON 的确定性导出器，并由 Core 测试逐字段验证公开数据未漂移。
- 新增冷启动中断恢复：缓存中的 outgoing `queued / sending` 会保留原 id 并恢复为可重试的 `failed`。
- 新增损坏 cache 自修复：启动时用 public sample 原子替换无法解码的 JSON，避免每次启动重复 fallback。
- 新增 App 内 Messenger Reset 与 `make run-fresh`，明确区分 Messenger Cache、学习进度与单个实验 Reset。
- 新增 App Guide 控制台 UI 场景，验证三个操作入口、无长文本视图及 Messenger Reset。
- 每个可点击实验新增可验证的真实 `file + symbol` Code cue、一个 Xcode action、预期结果元数据和 docs 路径。
- 新增由 Swift catalog 确定性生成的 70 个 Markdown 操作卡，逐 ID 覆盖 52 个 type experiment 与 18 个 concept experiment。
- 新增 `experiment-card-exporter --check` 与项目审计：校验 70 ID 一一对应、完整字段、真实 source anchor、LLDB、Reset 和思考题。

### Changed

- 公开页把共享 App renderer 标为“实验族”，明确网页知识元数据与本地 App / LLDB / 源码实验的边界。
- Simulator 默认 OS 改为匹配当前 Xcode SDK，避免 `latest` 误选更高 runtime；本地 SwiftPM/DerivedData 缓存在仓库移动后会自动重建。
- 普通 build 改用 generic Simulator；`release-check` 现在会执行真正的 Release build。
- 共享 Run scheme 显式启用 Main Thread Checker、Thread Performance Checker、queue debugging 与 view debugging，并提供默认关闭的 reset 参数。
- Guided Learning 对齐真实的 `queued → sending → sent/failed` 日志与三次 cache 持久化边界。
- Learn 搜索与课程入口直接进入实验，移除冗余 Type Detail 中间页；App 统一为紧凑控制台，详细讲义和 LLDB 命令只保留在 docs。
- 控制台不再提前渲染预期结果，课程与搜索入口不复制 Code/Xcode 信息；运行结果只由状态和 Logs 给出。
- Learn 课程列表与类型搜索结果进一步收敛为标题-only，不再显示 module、lesson 或进度副标题。
- Release 显式固定 `-O`、whole-module 与 dSYM，并新增项目审计门禁校验紧凑 App 和调试 Scheme。
- 18 个语言概念按语义映射到 property、value/reference、state machine、ownership、Foundation、concurrency、navigation、view、button、text input 与 collection renderer，不再泛化为同一个 Stepper。
- Xcode action 改为操作后必经的事件方法或真实 transport `send`，避免在进入页面后设置初始化断点却无法复验。
- property、value/reference、text 与 state machine renderer 改为真实运行 `PropertyBox`、`ValueCounter` / `ReferenceCounter`、`MessageDraft` 与 `DeliveryState`，并由 16 个 UI 场景覆盖操作、Reset 与异步取消。

## [1.0.0] - 2026-07-13

### Added

- Messenger 本地发送、确定性失败、同 id 重试与 JSON 缓存链路。
- 20 节可自由访问的零基础 Swift / Foundation / UIKit / IM 短课。
- 全局唯一的 52 张类型卡与独立 `LanguageConcept` 模型。
- 每张类型卡的 App、LLDB、源码三层白名单实验及独立 Reset。
- Learn 类型/API 搜索、已操作/已回答进度和 v1 进度迁移。
- 5 个 Swift → SIL → LLVM IR → ARM64 编译器显微镜样本。
- 9 个 Core、9 个 UI 场景以及 compiler/public/showcase 发布门禁。
- GitHub Pages 公开展示、真实 Simulator 截图和 pinned-actions 自动部署。
- GitHub Pages 接入与个人主站一致的 Jason DS 2.2.0 vendor copy、证据标签与返回主站入口。

### Boundaries

- 仅包含公开 API、虚构数据与原创实现。
- 不连接真实服务，不提供 IPA，不包含商业客户端实现或非公开材料。

### Fixed

- 修复 GitHub Pages 指标栏绕过共享容器、在桌面视口向左错位的问题，并增加结构审计防止同类回归。
- 修复 Simulator 截图在响应式宽度下可能保留固定高度而纵向拉伸的问题，并统一声明固有尺寸与自动高度。

[1.0.0]: https://github.com/estelledc/SwiftMessengerLab/releases/tag/v1.0.0
