# Swift 课程到实战项目映射

## 一句话结论

课程里的概念不按章节孤立练习，而是全部挂到“一条消息从输入到终态”的业务链路上。

## 当前学习入口

- IM 业务链路：`docs/guided-learning.md`
- 20 节类型短课：`docs/20-session-curriculum.md`
- 52 type + 18 concept 独立操作卡：`docs/experiment-cards.md`
- App / LLDB / 源码三层改值：`docs/type-lab.md`
- Swift → SIL → LLVM IR → ARM64：`docs/compiler-lab.md`

App 不承载讲义。课程和搜索入口直接进入共享 renderer；进入后只显示 Goal、真实 Code cue、一个 Xcode action 与 docs 短路径，结果由状态和 Logs 给出。下面的完整映射与解释以 docs 为准。

| 课程主题 | 项目落点 | 可观察证据 |
|---|---|---|
| `let` / `var` | 消息 id 不变，delivery state 会变 | 同一 id 从 sending 变 sent |
| Array / Dictionary | 会话数组、按 conversation id 分组的消息 | snapshot item 顺序 |
| Optional | server id 在收到回执前为空 | 断点观察 `serverID` |
| enum | `DeliveryState`、`MessageAuthor` | UI 的状态文字 |
| Closure / Protocol | composer 回调、`MessageTransport` | Call Stack 和替身传输 |
| Codable | `InboxSnapshot` JSON 缓存 | 重启后恢复消息 |
| UIKit | 会话列表、消息列表、输入区、导航 | Simulator 操作 |
| 响应链 | UITextField、Send 按钮、cell 点击 | action / delegate 断点 |
| 并发 | 模拟网络延迟与回执 | sending 先出现，sent 后出现 |
| 主线程 | 回执后刷新 diffable snapshot | Main Thread Checker + 断点 |
| DI / 测试 | 注入 `MessageTransport` | 成功、失败、重试单测 |
| SPM | Core 独立 target | `swift test` |
| SwiftUI 桥接 | 后续把日志面板改为 SwiftUI | v0.4 实验，不在 v0.1 |
| OC-Swift 混编 | 后续用极小 Adapter 包一段公开示例 | v0.5 实验，不在 v0.1 |

## 四阶段，而不是四份 Demo

1. v0.1：Swift 模型 + UIKit + async 发送 + JSON 缓存。
2. v0.2：未读数、分页、下拉刷新和稳定 identity。
3. v0.3：拆分 Core/UI 模块，增加 repository 与 transport 的替身测试。
4. v0.4：增加一个 SwiftUI 日志页，通过 `UIHostingController` 嵌入 UIKit。

每阶段都沿用同一个数据模型和用户动作，避免“每学一章就丢掉上一个 Demo”。
