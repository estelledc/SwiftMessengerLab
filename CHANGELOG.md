# Changelog

All notable changes to SwiftMessengerLab are documented here. The project follows Semantic Versioning.

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
