# 公开 IM iOS 项目筛选记录

## 选择结果

第一阶段采用“双层教材”：

- 动手主线：SwiftMessengerLab，体量小、无凭证、失败可重复、每条链路都能打断点。
- 源码对照：Tinode iOS，只读观察公开生产项目如何组织会话列表、消息页、发送栏、SDK 和本地数据库。

## 候选比较

| 项目 | 公开证据 | 适合学什么 | 当前不作为主线的原因 |
|---|---|---|---|
| [Tinode iOS](https://github.com/tinode/ios) | Swift；Apache-2.0；公开 README 列出会话、离线、发送/送达/已读状态 | UIKit IM 主链路、VIP 分层、SDK 与 DB 边界 | 完整运行还需要后端和 CocoaPods |
| [Nextcloud Talk iOS](https://github.com/nextcloud/talk-ios) | Swift/ObjC；GPL；公开 README 给出 CocoaPods、server 和测试环境 | 复杂消息 cell、输入区、通话与扩展 | 首次运行需要服务端、bundle id 和 app group 配置 |
| [Signal iOS](https://github.com/signalapp/Signal-iOS) | 大型 Swift/ObjC 生产仓；AGPL | 复杂消息渲染、隐私与数据库 | 规模过大，不符合第一轮 5 个断点的认知预算 |
| [Convos iOS](https://github.com/xmtplabs/convos-ios) | SwiftUI App + 独立 Core；公开 README 描述 XMTP、GRDB 和测试 | 现代 Core/UI 分离、SwiftUI 与自定义消息布局 | 目标 iOS 26，完整 setup 依赖 Docker、1Password 和团队环境 |

## Tinode 第一轮只读入口

按 `/source-learn` 的顺序，不从全仓开始：

1. 概览：README、根目录和 `Tinodios / TinodeSDK / TinodiosDB` 三层。
2. 追踪：`ChatListViewController -> ChatListInteractor -> ChatListPresenter -> ChatListRouter`。
3. 追踪：`MessageViewController -> SendMessageBar -> MessageInteractor -> TinodeSDK`。
4. 精读：每次只读一个 30-50 行片段，并先回答“输入、输出、owner、异步边界”。
5. 提炼：只把公开通用模式写成自己的最小例子，不复制源文件。

## 与大型商业客户端的关系

这里比较的是公开的产品拓扑：会话列表、消息时间线、输入区、发送状态、缓存和路由。它们不是任何公司的专有设计。具体类型、协议、线程模型、数据库和业务规则全部以公开项目或本实验为准。
