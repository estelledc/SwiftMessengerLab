# Public Research Boundary

## 结论

SwiftMessengerLab 是原创教学代码。它只研究“任何 IM 客户端都公开存在的通用问题”，不研究或复刻某家公司的私有实现。

## 允许使用的依据

- Apple Developer Documentation 中公开的 Swift、UIKit、Foundation 和并发概念。
- 开源仓库公开可见的 README、目录、许可证和源码。
- RFC、标准协议和公开 API 文档。
- 本项目自己生成的虚构数据、日志、测试和截图。

## 禁止进入仓库的内容

- 公司源码、patch、调用栈、内部仓库路径和私有类型名。
- 内部 API、域名、请求字段、错误码、埋点名和配置。
- 雇主内部文档 token、原文、截图和未经脱敏的业务材料。
- 根据内部实现“换个名字重写”的影子代码。
- 真实用户、会话、消息、账号或凭证。

## 如何参考大型商业客户端而不泄密

只在抽象问题层对齐，不在实现层对齐：

| 公开通用问题 | 本实验如何表示 | 不做什么 |
|---|---|---|
| 会话列表 | `ConversationListViewController` | 不复制商业客户端的 Feed 分层或命名 |
| 消息时间线 | `ChatViewController` | 不复制真实 datasource / VM |
| 输入与发送 | `MessageComposerView` + `DeliveryCoordinator` | 不复制真实发送服务或生命周期协议 |
| 发送状态 | `sending / sent / failed` | 不使用内部状态枚举、错误码或回执协议 |
| 本地恢复 | 小型 JSON cache | 不复刻公司数据库 schema |
| 路由 | `UINavigationController.pushViewController` | 不复制商业客户端的 router / navigator |

## 独立实现检查

每次新增实验前回答：

1. 这个问题是否能在 Apple 文档或至少一个公开 IM 仓库中独立证明存在？
2. 类型名、数据和控制流能否只靠本项目需求推导出来？
3. 删除所有公司上下文后，公开读者是否仍能理解它？
4. 是否误带了内部路径、token、接口、常量或原文？

任一答案不确定，就停止写代码，回到公开资料重新设计。

## 公开参照

- [Tinode iOS](https://github.com/tinode/ios)：Apache-2.0；公开展示会话列表、消息页、发送栏、离线和回执等完整 IM 能力。
- [Nextcloud Talk iOS](https://github.com/nextcloud/talk-ios)：GPL-3.0-or-later；用于观察复杂消息类型和成熟 UIKit 页面组织。
- [Signal iOS](https://github.com/signalapp/Signal-iOS)：AGPL-3.0；只作为大型生产客户端的规模对照，不作为第一阶段精读入口。
- [Convos iOS](https://github.com/xmtplabs/convos-ios)：现代 SwiftUI + 独立 Core 的架构对照；运行需要额外服务与凭证，不作为本实验基线。
