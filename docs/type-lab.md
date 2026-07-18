# 类型实验室使用方法

这篇只解释通用方法。按 experiment ID 组织的 52 个类型卡与 18 个概念卡统一见 [`docs/experiment-cards.md`](experiment-cards.md)；例如搜索 `type.UIView`。

70 个入口经过逐项证据审计后分为两类：

- `direct workload`：真实执行目标类型/概念的可识别代码，日志输出唯一 `target-evidence:<ID>`，才允许记录“已操作”。
- `related observation`：只复用相邻的 shared interaction model；标题、Goal 和文档都会明说“关联观察”，永远不写入目标已操作证据。

当前分类是 `51 direct + 19 related`。这比把 70 个入口都叫“实验”更保守，也让学习者知道哪条结论还需要 CompilerLab、业务链或新的专属 workload 补证。

## 一张类型卡怎么看

先只回答四件事：

1. 它是 `class / struct / enum / protocol` 中哪一种？
2. 一个属性的类型、读写权限和默认值是什么？
3. 一个方法的输入、输出、副作用和触发方是谁？
4. 谁创建、谁持有、什么时候释放？

完整类型卡位于离线 `docs/index.html` 与公开 Type Explorer。App 不复制这些长材料，而是把索引直接连接到一个可操作 renderer。

## App 的统一控制台契约

进入实验后，控制台只显示四项：

- `Goal`：这次只验证什么。
- `Code`：仓库中真实存在、可以搜索的 `file + symbol`。
- `Xcode`：本次唯一动作；例如设置一个断点或打开 Debug View Hierarchy。
- `Docs`：完整解释与命令所在短路径。

预期结果仍保留在目录元数据和本文，但 App 不会在操作前把答案渲染出来；真实结果只从控件状态和操作日志读取。课程页只显示一次主实验控制台，其他入口按钮仅显示标题。搜索类型后会直接进入实验，不再经过只复述材料的 Type Detail 页面。

## 真实 renderer 与 source cue

| 操作族 | 运行内容 | Source symbol | App 给出的唯一 Xcode action |
|---|---|---|---|
| value / property | Stepper 改值并重算 get-only 结果 | `recordOperation(_:)` | 操作 Stepper 后看 event 与 Call Stack |
| text | 修改 String，再观察 MessageDraft 计算结果 | `applyTextProbe()` | Apply Text 后看状态与调用来源 |
| ownership | 创建 owner、安装 weak callback、释放强引用 | `recordOperation(_:)` | 释放 owner 后观察 weak 与 Call Stack |
| Foundation | 用持有 URL 的 probe 写入/读回 JSON；Reset/deinit 删除 fixture | `runFoundationRoundTrip()` | Save + Load 后核对 URL、Data 与磁盘文件 |
| concurrency | 用 `Task` 调用确定性 `MockMessageTransport` | `MockMessageTransport.send(_:isRetry:)` | Run 后看线程与 Call Stack |
| navigation | push/pop 同一个 probe controller | `recordOperation(_:)` | Push 后看 probe id 与 Call Stack |
| view | 修改 `alpha / color / isHidden` | `applyViewState()` | 打开 Debug View Hierarchy |
| button | 开关 `isEnabled` 并验证 target-action | `actionButtonTapped()` | 在 action 打断点 |
| text input | 观察 delegate、control event、first responder | `textFieldShouldReturn(_:)` | 在 delegate 回调打断点 |
| collection | 用稳定 UUID 更新 diffable snapshot | `applyCollectionSnapshot()` | 刷新时检查 item id |
| dictionary | 对 `[String: Int]` 执行 update/default/merge/remove | `runDictionaryWorkload()` | 检查 key/value 前后状态 |
| repository | 调用 enqueueOutgoing，检查 append/queued/preview | `enqueueOutgoing(...)` | 在 Repository 方法打断点 |
| state machine | 在 `sending / sent / failed` 间切换 | `advanceDeliveryState()` | Advance 后检查 `stateIndex / event` |

`Dictionary` 不再借 `[UUID]` collection renderer 充当 key/value 证据；`MessageRepository` 直接命中 Core 的 `enqueueOutgoing`；`MessageTransport` 通过 `any MessageTransport` existential 调用真实 `send`。其他入口仍按卡片中的 `direct / related` 分类解释，不能只凭 renderer 名称推断目标已经运行。

## LLDB：完整命令只放在 docs

在 `InteractiveExperimentViewController.recordOperation(_:)` 设置断点，然后按实验选择一组命令：

```lldb
# 通用状态
po experimentState

# value
expr experimentState.step += 1
po experimentState.step

# text
expr experimentState.text = "LLDB changed"
po experimentState.text

# view
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState

# state machine
expr experimentState.stateIndex = 2
po experimentState.stateIndex

# collection
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
```

LLDB 改值只影响本次进程内的当前实例。执行后继续运行，再操作一次 App 控件，判断 renderer 是否会用自己的状态覆盖手工改值。

## 源码改值

1. 从 App 的 `Source` cue 跳到 renderer。
2. 在 `ExperimentSnapshot` 或对应 `configure...` 方法中改一个默认值。
3. 重新构建并创建新实验页面。
4. 对比源码改值与 LLDB 改当前实例的生命周期差异。

## Reset 与证据

- `Reset Experiment`：取消当前异步任务、释放临时 owner、删除 Foundation probe 的磁盘 fixture，并恢复当前入口的不可变默认快照。
- `Reset Learning Progress`：二次确认后只清除 direct workload 的已操作记录与已回答记录。
- Messenger 消息缓存不被两种 Reset 改动。
- 真正掌握需要你亲自说出类型、属性、方法和一段调试证据；App 不自动宣称掌握。
