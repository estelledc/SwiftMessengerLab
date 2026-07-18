# Guided Learning

## 训练节奏

每个 Session 固定走七步：

```text
预测 -> 运行 -> 暂停 -> 观察 -> 解释 -> 验证 -> 复盘
```

第一轮只看 App 内 Logs 和 Xcode Console，证明“发生顺序”；第二轮再打断点看 Call Stack，证明“调用来源”。

进入实验后只显示一个 Goal、一个真实 `file + symbol` Code cue、一个 Xcode action 和 docs 短路径；入口按钮只显示标题。预期结果不在操作前渲染，真实结果从状态与 Logs 读取。完整 LLDB 命令不复制进 App；IM 业务链留在本文，70 个 type/concept 的独立材料统一位于 `docs/experiment-cards.md`。

## Session 0：建立运行基线

操作：

```bash
make test
make build
make run-fresh
```

胜利条件：

- Core 测试通过。
- Simulator 首屏出现三个虚构会话。
- 点任意会话能进入消息页。

## Session 1：会话列表到消息页

### 先预测

1. 点击一行后，是 cell 自己创建消息页，还是 ViewController 响应 selection？
2. `indexPath` 和 conversation id，哪个能稳定代表一个会话？
3. pop 回列表后，为什么预览文字会更新？

### 两轮观察

第一轮：看 Logs 中 `Inbox didSelect -> Chat viewDidLoad`。

第二轮断点：

- `ConversationListViewController.collectionView(_:didSelectItemAt:)`
- `ChatViewController.viewDidLoad()`

胜利条件：能解释位置、身份和导航之间的区别。

Messenger 的紧凑入口在 `Guide`：

- Source cue：`SwiftMessengerLab/Features/Chat/ChatViewController.swift · submit(text:)`
- 唯一 Xcode action：在 `ChatViewController.submit(text:)` 设置断点，发送 `/fail` 后查看 Call Stack。

## Session 2：发送成功主链路

### 先预测

普通文本点击 Send 后，给下面 6 个动作排序：

- transport 返回 receipt
- UI 出现 sending
- repository 创建本地 message
- UI 变成 sent
- composer 清空
- cache 写入 snapshot

### 第一轮：只看顺序

发送 `hello`，在 Logs 中找：

```text
Composer send
Repository enqueue
Cache save (queued)
UI apply snapshot (queued)
Repository update (sending)
Transport start
Cache save (sending)
UI apply snapshot (sending)
Transport success
Repository update (sent)
Cache save (sent)
UI apply snapshot (sent)
```

这条实现会在 `queued / sending / sent` 三个持久化边界各写一次 cache；不要把“最终保存”误解成只有一次磁盘写入。

### 第二轮：看调用来源

设置 5 个断点：

1. `MessageComposerView.sendTapped()`
2. `MessageRepository.enqueueOutgoing(...)`
3. `MockMessageTransport.send(...)`
4. `MessageRepository.markSent(...)`
5. `ChatViewController.applySnapshot(...)`

胜利条件：不看代码画出 `UI -> Repository -> Transport -> Repository -> UI`，并指出异步边界。

## Session 3：失败与同 id 重试

### 先预测

1. 发送失败后应该删除消息、一直转圈，还是保留 failed？
2. 点击重试时应该新建 message id 吗？
3. 如果旧请求晚到，会有什么风险？

### 操作

1. 发送 `/fail`。
2. 等待状态变为 failed。
3. 点击失败消息。
4. 观察它变为 sending，再变为 sent。

`/fail` 只在首次发送失败；重试会成功，便于稳定复现。

胜利条件：能解释“稳定 identity + 可变 delivery state”，并证明列表里没有重复消息。

## Session 4：缓存与冷启动

### 先预测

1. 哪些字段必须编码进 JSON？
2. server id 为什么是 Optional？
3. 缓存损坏时应该让 App 崩溃，还是回到 seed data？

### 操作

1. 发送一条普通消息。
2. 停止并重新运行 App。
3. 进入同一会话确认消息仍在。
4. 在 `JSONInboxCache.save/load` 打断点观察 `Codable`。

再做一次中断恢复：

1. 在 `MockMessageTransport.send(_:,isRetry:)` 的 `Task.sleep` 行打断点。
2. 发送任意消息；断点停住时，`sending` 已经写入 cache。
3. 直接点 Xcode Stop，再重新 Run。
4. 进入同一会话，确认这条消息恢复成 `failed`，可以用同一个 id 重试。

恢复策略故意不自动重发：本地 lab 没有真实服务端幂等协议，无法证明中断前请求是否已经被服务端接收。把瞬态状态降为 `failed`，会把下一步交回给学习者。

再验证损坏 cache：

1. 停止 App。
2. 把 Application Support 中的 `inbox.json` 改成无法解码的文本。
3. 重新运行。
4. Logs 应显示 `Cache invalid -> replace with public sample data`。
5. 再次重启应走正常 `Cache load success`，证明坏文件已经被原子替换，而不是每次 fallback。

胜利条件：能区分内存 repository 和磁盘 cache 的职责，并解释为什么冷启动不能让 `queued / sending` 永久卡住、为什么损坏 cache 必须被持久修复。

## Reset 边界

| 操作 | Messenger JSON Cache | 学习进度 | 当前实验控件 |
|---|---:|---:|---:|
| `make run` | 保留 | 保留 | 新建页面时用源码默认值 |
| `make run APP_ARGUMENTS='--reset-cache'` | 重置 | 保留 | 不负责 |
| `make run-fresh` | 重置 | 重置 | 不负责 |
| App Guide 内 `Reset Messenger Data` | 重置为 sample | 保留 | 不负责 |
| App 内 `Reset Learning Progress` | 保留 | 重置 | 不负责 |
| App 内 `Reset Experiment` | 保留 | 保留 | 只重置当前实验 |

做 reset 实验时先写下你预计会变化的存储，再执行；不要仅凭“界面看起来回去了”判断数据边界。

共享 Run scheme 默认启用 Main Thread Checker、Thread Performance Checker、queue debugging 与 view debugging。`--reset-cache` 和 `--reset-learning-progress` 已作为默认关闭的 Scheme 参数列出；需要确定性基线时手动勾选，做冷启动恢复实验时保持关闭。

## Session 5：公开生产源码对照

先完成 Session 1-4，再读 Tinode。每次只回答一个问题：

1. 会话列表的输入来自哪里？
2. 点击事件如何被 interactor / presenter / router 分工？
3. 输入区如何把文本交到发送链路？
4. 发送、送达、已读状态存在哪里、怎样回到 UI？

不要用 Tinode 的代码替换实验仓。目标是比较“为什么生产项目多了这些层”，不是把小项目改造成大项目。

## E3 验收题

1. 为什么本地消息要在网络成功前进入 repository？
2. 为什么 message id 不能用数组下标或可变文本？
3. transport 回调后，为什么 UI 刷新必须回到主 actor？
4. cache、repository、transport 分别保存或处理什么？
5. 如果要加入已读回执，你会在哪些对象之间增加什么状态变化？
