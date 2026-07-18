# 70 个学习入口：直接实验与关联观察

这份文件由 `ExperimentCatalog` 确定性生成，覆盖 52 个 type 与 18 个 concept：其中 51 个 `direct workload`、19 个 `related observation`。App 只显示 Goal、Code、Xcode、Docs、控件与日志；完整解释、LLDB、Reset、边界和思考题集中在这里。

使用方法：在 App 按标题打开入口后，用编辑器搜索标题里的目标名；也可以从下方 20 Session 索引复制完整 ID，例如 `type.UIView` 或 `concept.stable-identity`。只有执行可识别目标 workload 并输出专属 `target-evidence:<ID>` 的入口才记录“已操作”；关联观察明确不记录。

生成与校验：

```bash
make experiment-cards
make verify-experiment-cards
```

> 自动门禁只能证明卡片与 catalog、源码锚点一致；LLDB、Call Stack、View Debugger 和实际解释仍需学习者亲自在 Xcode 中留下证据。

## 20 Session 索引

App 中按 Session 进入；文档中搜索完整 experiment ID 直达卡片。一个实验可能被后续 Session 再次引用，但正文只定义一次。

| Session | 主题 | 对应操作卡 |
|---:|---|---|
| 1 | let / var 与类型推断 | `concept.let-var`、`concept.type-inference` |
| 2 | 存储、计算、lazy 与 didSet | `type.PropertyBox`、`concept.stored-computed`、`concept.lazy-didset` |
| 3 | 方法、init、self 与访问控制 | `type.MessageDraft`、`concept.init-self-access` |
| 4 | struct 与 class：复制和共享 | `type.ValueCounter`、`type.ReferenceCounter`、`concept.value-reference` |
| 5 | Optional、enum、switch 与错误状态 | `type.Optional`、`type.DeliveryState`、`concept.switch-exhaustiveness` |
| 6 | protocol、delegate、closure、weak 与 ARC | `type.MessageTransport`、`type.CaptureOwner`、`concept.delegate-closure-arc` |
| 7 | String 与集合 | `type.String`、`type.Array`、`type.Set`、`type.Dictionary` |
| 8 | Foundation 常用值与持久化 | `type.UUID`、`type.Date`、`type.URL`、`type.Data`、`type.FileManager`、`concept.codable` |
| 9 | Task、async/await、throws 与 Result | `type.Task`、`type.Result`、`concept.async-await-throws` |
| 10 | UIResponder → UIApplication → UIScene → UIWindow | `type.UIResponder`、`type.UIApplication`、`type.UIScene`、`type.UIWindow`、`concept.responder-scene-chain` |
| 11 | UIView 几何、外观与层级 | `type.UIView` |
| 12 | Auto Layout、anchor 与 UIStackView | `type.NSLayoutAnchor`、`type.NSLayoutConstraint`、`type.UIStackView`、`concept.auto-layout` |
| 13 | UIViewController 与生命周期 | `type.UIViewController`、`type.UINavigationItem`、`concept.view-controller-lifecycle` |
| 14 | UINavigationController 与页面身份 | `type.UINavigationController`、`concept.view-controller-lifecycle` |
| 15 | UILabel 与 UIImageView | `type.UILabel`、`type.UIImageView` |
| 16 | UIButton、UIControl 与 target-action | `type.UIControl`、`type.UIButton`、`type.UIButton.Configuration`、`concept.target-action` |
| 17 | UITextField、UITextView 与键盘 | `type.UITextField`、`type.UITextView`、`type.UITextFieldDelegate`、`type.UITextViewDelegate`、`concept.first-responder` |
| 18 | UIScrollView、UICollectionView 与复用 | `type.UIScrollView`、`type.UICollectionView`、`type.UICollectionViewCell`、`concept.reuse` |
| 19 | data source、delegate 与 diffable snapshot | `type.UICollectionViewDataSource`、`type.UICollectionViewDelegate`、`type.UICollectionViewDiffableDataSource`、`type.NSDiffableDataSourceSnapshot`、`concept.stable-identity` |
| 20 | 映射回 IM：环境、仓库、传输与缓存 | `type.AppEnvironment`、`type.MessageRepository`、`type.MessageTransport`、`type.JSONInboxCache`、`type.MockMessageTransport`、`type.Message`、`type.InboxSnapshot`、`type.DeliveryState`、`concept.dependency-injection` |

## 证据分类审计

判定标准不是“页面能点”，而是动作是否执行目标的可识别 workload、源码锚点是否落在该调用链、日志是否输出唯一 token。满足三项才是 `direct workload`；否则保留为 `related observation`，不写入“已操作”证据。

- Direct：51 个；每卡列出 `target-evidence:<ID>` 与目标 API/对象证据。
- Related type（15）：`type.Optional`、`type.Result`、`type.UIResponder`、`type.UIApplication`、`type.UIScene`、`type.UIWindow`、`type.UIStackView`、`type.UINavigationItem`、`type.UILabel`、`type.UIImageView`、`type.UITextView`、`type.UITextViewDelegate`、`type.UIScrollView`、`type.UICollectionViewDelegate`、`type.AppEnvironment`
- Related concept（4）：`concept.let-var`、`concept.type-inference`、`concept.responder-scene-chain`、`concept.dependency-injection`
- 三个防误映射样本：Dictionary 使用独立 key/value workload；MessageRepository 命中 `enqueueOutgoing`；MessageTransport 通过 `any MessageTransport` 调用 `send`。

## 13 个 renderer family

70 张卡共享 13 类操作面。`direct workload` 才能写入目标已操作证据；`related observation` 只复用控件与断点入口。

| Family | 实际操作 | Source symbol |
|---|---|---|
| value / property / reference | 通用 Stepper、真实 PropertyBox、ValueCounter / ReferenceCounter 对照 | `recordOperation(_:)` / `incrementPropertyProbe()` / `mutateValueReferenceProbes()` |
| text | Apply Text，观察 String 与 MessageDraft 计算结果 | `applyTextProbe()` |
| ownership | 创建 owner、weak callback，再释放强引用 | `recordOperation(_:)` |
| Foundation | 真实 JSON save + load，Reset/deinit 删除 fixture | `runFoundationRoundTrip()` |
| concurrency | Task 调用 MockMessageTransport | `send(_:isRetry:)` |
| navigation | push / pop probe 并追踪对象 id | `recordOperation(_:)` |
| view | alpha / color / isHidden + View Debugger | `applyViewState()` |
| button | isEnabled + target-action | `actionButtonTapped()` |
| text input | delegate / editingChanged / first responder | `textFieldShouldReturn(_:)` |
| collection | 固定 UUID + diffable snapshot | `applyCollectionSnapshot()` |
| dictionary | 独立 key/value update/default/merge/remove | `runDictionaryWorkload()` |
| repository | enqueue queued message 并更新 preview | `enqueueOutgoing(...)` |
| state machine | 真实 DeliveryState 的 sending / sent / failed 循环 | `advanceDeliveryState()` |

<!-- experiment-card: type.PropertyBox -->
## type.PropertyBox · PropertyBox

### 学习目标

执行可识别的目标 workload，并解释 `PropertyBox` 为什么是 `SwiftMessengerCore.class`：把存储、计算、lazy 与 didSet 放进一个可观察对象。

### 机制

- 直觉类比：带仪表盘的储物柜。
- 类型焦点：`stored: Int` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init()`；触发方是App 白名单实验或业务调用方，建议断点名是 `init()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `incrementPropertyProbe()`
- 本卡目标：`PropertyBox`；共享 renderer：`propertyObserver`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.PropertyBox`

### App 操作

进入 Learn，打开 `PropertyBox Experiment`。操作前先口头预测 `PropertyBox` 的 `stored` 会如何影响状态或调用。

1. 先记录 `PropertyBox` 的 stored、doubled、didSet 与 lazy 状态，再点击 `Increment stored`。
2. 点击 `Read lazyText` 后再次改 stored，比较 lazy 首次求值结果与最新 doubled。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `incrementPropertyProbe()`，按 App 中的唯一动作执行：在 incrementPropertyProbe() 设置断点，点击 Increment stored 后检查 didSetCount 与 doubled。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.PropertyBox · PropertyBox
po experiment.id
po propertyBoxProbe?.stored
po propertyBoxProbe?.doubled
po propertyBoxProbe?.didSetCount
po propertyLazyWasRead
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 PropertyBox，修改 stored，并读取 didSetCount、doubled 与 lazyText；成功后写入专属 token `target-evidence:type.PropertyBox`。
- Renderer 证据：`stored` 改变后 `doubled` 同步重算、`didSetCount` 增加；`lazyText` 只在首次读取时按当时 stored 初始化。
- Catalog 证据：状态与日志出现 target-evidence:type.PropertyBox，且能定位 PropertyBox 的真实调用。
- 你的解释必须同时说出 `PropertyBox` 的种类、`stored` 的权限，以及 `init()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stored = 1`、`doubled = 2`、`didSet = 0`、`lazy = not read`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 本 renderer 真实实例化 `PropertyBox`；它能证明本类型的 didSet/computed/lazy 行为，但不能外推所有属性观察器的初始化顺序。
- 本卡真实实例化 `PropertyBox`，可以直接验证 stored、doubled、didSetCount 与 lazyText；仍不能把结果外推到任意属性观察器。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 stored 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `PropertyBox`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.MessageDraft -->
## type.MessageDraft · MessageDraft

### 学习目标

执行可识别的目标 workload，并解释 `MessageDraft` 为什么是 `SwiftMessengerCore.struct`：保存输入中的消息草稿并计算可发送状态。

### 机制

- 直觉类比：发送前的表单。
- 类型焦点：`text: String` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(text:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(text:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyTextProbe()`
- 本卡目标：`MessageDraft`；共享 renderer：`text`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.MessageDraft`

### App 操作

进入 Learn，打开 `MessageDraft Experiment`。操作前先口头预测 `MessageDraft` 的 `text` 会如何影响状态或调用。

1. 把输入改成一段能体现本卡目标的文本，再点击 `Apply Text`。
2. 对照 `count / isEmpty` 与 Live operation log，区分存储值和重新计算的结果。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyTextProbe()`，按 App 中的唯一动作执行：在 applyTextProbe() 设置断点，点击 Apply Text 后检查 MessageDraft 与 String 状态。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.MessageDraft · MessageDraft
po experiment.id
po experimentState.text
po messageDraftProbe?.trimmedText
po messageDraftProbe?.isSendable
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：由文本输入创建 MessageDraft，并读取 trimmedText 与 isSendable；成功后写入专属 token `target-evidence:type.MessageDraft`。
- Renderer 证据：状态显示 String 的 count/isEmpty 与 MessageDraft 的 trimmedText/isSendable，日志记录两组计算属性已重算。
- Catalog 证据：状态与日志出现 target-evidence:type.MessageDraft，且能定位 MessageDraft 的真实调用。
- 你的解释必须同时说出 `MessageDraft` 的种类、`text` 的权限，以及 `init(text:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`；再次 Apply 才会产生新操作证据。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 本 renderer 真实创建 `MessageDraft` 并使用 String API；它不会覆盖所有文本编码、grapheme cluster 或输入法边界。
- 本卡真实创建 `MessageDraft`，可以直接验证 trimmedText 与 isSendable；不覆盖完整 composer 或发送业务。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 text 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `MessageDraft`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.ValueCounter -->
## type.ValueCounter · ValueCounter

### 学习目标

执行可识别的目标 workload，并解释 `ValueCounter` 为什么是 `SwiftMessengerCore.struct`：用最小结构体观察复制后的独立修改。

### 机制

- 直觉类比：复印出来的计数卡。
- 类型焦点：`value: Int` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(value:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(value:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `mutateValueReferenceProbes()`
- 本卡目标：`ValueCounter`；共享 renderer：`valueReference`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.ValueCounter`

### App 操作

进入 Learn，打开 `ValueCounter Experiment`。操作前先口头预测 `ValueCounter` 的 `value` 会如何影响状态或调用。

1. 先记录 struct original/copy 与 class original/alias 都为 1。
2. 点击 `Mutate Copy + Alias`，比较值副本和共享引用的结果，并确认 class identity 为 true。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `mutateValueReferenceProbes()`，按 App 中的唯一动作执行：在 mutateValueReferenceProbes() 设置断点，点击 Mutate 后比较 struct copy 与 class alias。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.ValueCounter · ValueCounter
po experiment.id
po originalValueCounterProbe?.value
po copiedValueCounterProbe?.value
po referenceCounterProbe?.value
po referenceAliasProbe?.value
po referenceCounterProbe === referenceAliasProbe
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：复制 ValueCounter 后只修改副本；成功后写入专属 token `target-evidence:type.ValueCounter`。
- Renderer 证据：ValueCounter 显示 original=1、copy=2；ReferenceCounter 显示 original=2、alias=2 且 same class instance=true。
- Catalog 证据：状态与日志出现 target-evidence:type.ValueCounter，且能定位 ValueCounter 的真实调用。
- 你的解释必须同时说出 `ValueCounter` 的种类、`value` 的权限，以及 `init(value:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：四个计数值都回到 1；struct copy 重新创建，两个 class 变量重新指向同一新实例。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 这个 renderer 真实运行 `ValueCounter` 与 `ReferenceCounter`；它证明本样本的复制/共享差异，不代表带引用成员的任意 struct 都是深拷贝。
- 本卡真实复制 `ValueCounter` 并只修改 copy，因此 original=1/copy=2 是这个 struct 的直接运行证据。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 value 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `ValueCounter`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.ReferenceCounter -->
## type.ReferenceCounter · ReferenceCounter

### 学习目标

执行可识别的目标 workload，并解释 `ReferenceCounter` 为什么是 `SwiftMessengerCore.class`：用最小类观察共享实例与对象身份。

### 机制

- 直觉类比：多人共用的计数器。
- 类型焦点：`value: Int` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(value:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(value:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `mutateValueReferenceProbes()`
- 本卡目标：`ReferenceCounter`；共享 renderer：`valueReference`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.ReferenceCounter`

### App 操作

进入 Learn，打开 `ReferenceCounter Experiment`。操作前先口头预测 `ReferenceCounter` 的 `value` 会如何影响状态或调用。

1. 先记录 struct original/copy 与 class original/alias 都为 1。
2. 点击 `Mutate Copy + Alias`，比较值副本和共享引用的结果，并确认 class identity 为 true。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `mutateValueReferenceProbes()`，按 App 中的唯一动作执行：在 mutateValueReferenceProbes() 设置断点，点击 Mutate 后比较 struct copy 与 class alias。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.ReferenceCounter · ReferenceCounter
po experiment.id
po originalValueCounterProbe?.value
po copiedValueCounterProbe?.value
po referenceCounterProbe?.value
po referenceAliasProbe?.value
po referenceCounterProbe === referenceAliasProbe
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：让两个变量引用同一 ReferenceCounter，并用 === 与同步变值确认身份；成功后写入专属 token `target-evidence:type.ReferenceCounter`。
- Renderer 证据：ValueCounter 显示 original=1、copy=2；ReferenceCounter 显示 original=2、alias=2 且 same class instance=true。
- Catalog 证据：状态与日志出现 target-evidence:type.ReferenceCounter，且能定位 ReferenceCounter 的真实调用。
- 你的解释必须同时说出 `ReferenceCounter` 的种类、`value` 的权限，以及 `init(value:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：四个计数值都回到 1；struct copy 重新创建，两个 class 变量重新指向同一新实例。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 这个 renderer 真实运行 `ValueCounter` 与 `ReferenceCounter`；它证明本样本的复制/共享差异，不代表带引用成员的任意 struct 都是深拷贝。
- 本卡让 original 与 alias 指向同一 `ReferenceCounter`，`=== true` 与同步变值是引用共享的直接运行证据。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 value 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `ReferenceCounter`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Optional -->
## type.Optional · Optional

### 学习目标

借 shared interaction model 观察与 `Optional` 相邻的机制，并明确它不构成目标运行证据：明确表达一个值存在或不存在。

### 机制

- 直觉类比：可能空着的快递柜。
- 类型焦点：`unsafelyUnwrapped: Wrapped` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`map(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `map(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `advanceDeliveryState()`
- 本卡目标：`Optional`；共享 renderer：`stateMachine`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `Optional Related Observation`。操作前先口头预测 `Optional` 的 `unsafelyUnwrapped` 会如何影响状态或调用。

1. 从 `sending` 开始连续点击 `Advance State`，写下每一步状态。
2. 核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `advanceDeliveryState()`，按 App 中的唯一动作执行：在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Optional · Optional
po experiment.id
po experimentState.stateIndex
po currentDeliveryState
po deliveryStateCycle
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。
- Target 边界：`stateMachine` 只是 shared interaction model；未执行 Optional 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 Optional 的运行证据。
- 你的解释必须同时说出 `Optional` 的种类、`unsafelyUnwrapped` 的权限，以及 `map(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stateIndex = 0`，页面重新显示 `sending`。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `enum` 的价值是有限状态与关联值；UI 的 stateIndex 只是选择索引，证据还必须落到实际 enum case。
- 这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。
- renderer 没有执行 `Optional` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 unsafelyUnwrapped 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Optional`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.DeliveryState -->
## type.DeliveryState · DeliveryState

### 学习目标

执行可识别的目标 workload，并解释 `DeliveryState` 为什么是 `SwiftMessengerCore.enum`：将消息发送限制在有限且可穷尽处理的状态中。

### 机制

- 直觉类比：快递轨迹。
- 类型焦点：`rawValue: String` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`init?(rawValue:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init?(rawValue:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `advanceDeliveryState()`
- 本卡目标：`DeliveryState`；共享 renderer：`stateMachine`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.DeliveryState`

### App 操作

进入 Learn，打开 `DeliveryState Experiment`。操作前先口头预测 `DeliveryState` 的 `rawValue` 会如何影响状态或调用。

1. 从 `sending` 开始连续点击 `Advance State`，写下每一步状态。
2. 核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `advanceDeliveryState()`，按 App 中的唯一动作执行：在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.DeliveryState · DeliveryState
po experiment.id
po experimentState.stateIndex
po currentDeliveryState
po deliveryStateCycle
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 DeliveryState 数组并用穷尽 switch 推进真实 enum case；成功后写入专属 token `target-evidence:type.DeliveryState`。
- Renderer 证据：真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。
- Catalog 证据：状态与日志出现 target-evidence:type.DeliveryState，且能定位 DeliveryState 的真实调用。
- 你的解释必须同时说出 `DeliveryState` 的种类、`rawValue` 的权限，以及 `init?(rawValue:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stateIndex = 0`，页面重新显示 `sending`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `enum` 的价值是有限状态与关联值；UI 的 stateIndex 只是选择索引，证据还必须落到实际 enum case。
- 这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。
- 本卡的循环元素就是 `DeliveryState`，可直接验证 sending/sent/failed；queued/received 与业务迁移仍在 Repository 链验证。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 rawValue 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `DeliveryState`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.MessageTransport -->
## type.MessageTransport · MessageTransport

### 学习目标

执行可识别的目标 workload，并解释 `MessageTransport` 为什么是 `SwiftMessengerCore.protocol`：隔离消息发送能力，使业务不依赖具体网络实现。

### 机制

- 直觉类比：统一规格的插座。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `send(_:isRetry:)` 的输入、输出与副作用。
- 方法焦点：`send(_:isRetry:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `send(_:isRetry:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡目标：`MessageTransport`；共享 renderer：`concurrency`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.MessageTransport`

### App 操作

进入 Learn，打开 `MessageTransport Experiment`。操作前先口头预测 `MessageTransport` 的 `send(_:isRetry:)` 会如何影响状态或调用。

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，按 App 中的唯一动作执行：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.MessageTransport · MessageTransport
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：通过 `any MessageTransport` existential 调用 send(_:isRetry:)；成功后写入专属 token `target-evidence:type.MessageTransport`。
- Renderer 证据：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Catalog 证据：状态与日志出现 target-evidence:type.MessageTransport，且能定位 MessageTransport 的真实调用。
- 你的解释必须同时说出 `MessageTransport` 的种类、`无精选属性` 的权限，以及 `send(_:isRetry:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 本卡把 MockMessageTransport 装入 `any MessageTransport` existential，再通过协议调用 send；具体网络实现仍不在项目范围内。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `send(_:isRetry:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `MessageTransport`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.CaptureOwner -->
## type.CaptureOwner · CaptureOwner

### 学习目标

执行可识别的目标 workload，并解释 `CaptureOwner` 为什么是 `SwiftMessengerCore.class`：用强捕获与 weak 捕获观察闭包所有权。

### 机制

- 直觉类比：持有回拨电话的联系人。
- 类型焦点：`label: String` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init()`；触发方是App 白名单实验或业务调用方，建议断点名是 `init()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`CaptureOwner`；共享 renderer：`ownership`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.CaptureOwner`

### App 操作

进入 Learn，打开 `CaptureOwner Experiment`。操作前先口头预测 `CaptureOwner` 的 `label` 会如何影响状态或调用。

1. 点击 `Create Owner + Weak Callback`，确认 strong owner 与 weak probe 同时存活。
2. 点击 `Release Strong Owner`，观察 weak probe 是否变为 nil，并核对两条日志顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，释放 owner 后观察 weak 引用与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.CaptureOwner · CaptureOwner
po experiment.id
po ownershipProbe
po weakOwnershipProbe
expr ownershipProbe = nil
po weakOwnershipProbe
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 CaptureOwner、安装 weak closure 并释放最后一个强引用；成功后写入专属 token `target-evidence:type.CaptureOwner`。
- Renderer 证据：创建后 `weak alive = true`；解除最后一个强引用后 `weak nil = true`，日志记录 ARC 边变化。
- Catalog 证据：状态与日志出现 target-evidence:type.CaptureOwner，且能定位 CaptureOwner 的真实调用。
- 你的解释必须同时说出 `CaptureOwner` 的种类、`label` 的权限，以及 `init()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：临时 owner、weak probe 与 callback 都被清空，状态回到 `owner = nil · weak = nil`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- weak 归零只能证明这个 probe 没有剩余强引用；不能据此断言任意业务闭包都不存在 retain cycle。
- 创建 CaptureOwner、安装 weak closure 并释放最后一个强引用；成功后写入专属 token `target-evidence:type.CaptureOwner`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 label 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `CaptureOwner`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.String -->
## type.String · String

### 学习目标

执行可识别的目标 workload，并解释 `String` 为什么是 `Swift.struct`：保存可扩展字形集合并提供文本操作。

### 机制

- 直觉类比：一串可编辑字符。
- 类型焦点：`count: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`append(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `append(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyTextProbe()`
- 本卡目标：`String`；共享 renderer：`text`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.String`

### App 操作

进入 Learn，打开 `String Experiment`。操作前先口头预测 `String` 的 `count` 会如何影响状态或调用。

1. 把输入改成一段能体现本卡目标的文本，再点击 `Apply Text`。
2. 对照 `count / isEmpty` 与 Live operation log，区分存储值和重新计算的结果。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyTextProbe()`，按 App 中的唯一动作执行：在 applyTextProbe() 设置断点，点击 Apply Text 后检查 MessageDraft 与 String 状态。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.String · String
po experiment.id
po experimentState.text
po messageDraftProbe?.trimmedText
po messageDraftProbe?.isSendable
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：修改 String，并执行 count、isEmpty 与 trimmingCharacters；成功后写入专属 token `target-evidence:type.String`。
- Renderer 证据：状态显示 String 的 count/isEmpty 与 MessageDraft 的 trimmedText/isSendable，日志记录两组计算属性已重算。
- Catalog 证据：状态与日志出现 target-evidence:type.String，且能定位 String 的真实调用。
- 你的解释必须同时说出 `String` 的种类、`count` 的权限，以及 `append(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`；再次 Apply 才会产生新操作证据。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 本 renderer 真实创建 `MessageDraft` 并使用 String API；它不会覆盖所有文本编码、grapheme cluster 或输入法边界。
- MessageDraft 的 text 确实是 String，本卡直接调用 count/isEmpty/trim；不覆盖 Unicode 的全部 grapheme cluster 边界。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 count 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `String`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Array -->
## type.Array · Array

### 学习目标

执行可识别的目标 workload，并解释 `Array` 为什么是 `Swift.struct`：按顺序保存可重复元素。

### 机制

- 直觉类比：有顺序的清单。
- 类型焦点：`count: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`append(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `append(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`Array`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Array`

### App 操作

进入 Learn，打开 `Array Experiment`。操作前先口头预测 `Array` 的 `count` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Array · Array
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：对 `[UUID]` 执行 reverse 与 append；成功后写入专属 token `target-evidence:type.Array`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.Array，且能定位 Array 的真实调用。
- 你的解释必须同时说出 `Array` 的种类、`count` 的权限，以及 `append(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- `experimentState.itemIDs` 确实是 `[UUID]`，可证明顺序与 append；它仍不覆盖 Array 的全部泛型、索引和 copy-on-write 行为。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 count 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Array`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Set -->
## type.Set · Set

### 学习目标

执行可识别的目标 workload，并解释 `Set` 为什么是 `Swift.struct`：保存不重复且可快速判断成员关系的元素。

### 机制

- 直觉类比：去重名单。
- 类型焦点：`count: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`insert(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `insert(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`Set`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Set`

### App 操作

进入 Learn，打开 `Set Experiment`。操作前先口头预测 `Set` 的 `count` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Set · Set
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：由 UUID 数组构造 Set 并读取去重后的 count；成功后写入专属 token `target-evidence:type.Set`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.Set，且能定位 Set 的真实调用。
- 你的解释必须同时说出 `Set` 的种类、`count` 的权限，以及 `insert(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- `Set(experimentState.itemIDs)` 只用于计算唯一数；可证明去重结果，不等于验证所有 Set 成员操作与哈希边界。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 count 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Set`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Dictionary -->
## type.Dictionary · Dictionary

### 学习目标

执行可识别的目标 workload，并解释 `Dictionary` 为什么是 `Swift.struct`：通过唯一 key 保存和查找 value。

### 机制

- 直觉类比：键值通讯录。
- 类型焦点：`count: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`updateValue(_:forKey:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `updateValue(_:forKey:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runDictionaryWorkload()`
- 本卡目标：`Dictionary`；共享 renderer：`dictionary`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Dictionary`

### App 操作

进入 Learn，打开 `Dictionary Experiment`。操作前先口头预测 `Dictionary` 的 `count` 会如何影响状态或调用。

1. 点击 `Run Key/Value Workload`，执行 updateValue、default subscript、merge 与 removeValue。
2. 核对 queued 的旧值/删除值、sent/failed 计数和最终排序 keys。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runDictionaryWorkload()`，按 App 中的唯一动作执行：在 runDictionaryWorkload() 设置断点，执行后检查 key 的更新、合并与删除。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Dictionary · Dictionary
po experiment.id
next
po result.previousQueuedCount
po result.removedQueuedCount
po result.sortedKeys
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：对 `[String: Int]` 执行 updateValue、default subscript、merge 与 removeValue；成功后写入专属 token `target-evidence:type.Dictionary`。
- Renderer 证据：状态显示 queued 从 1 更新为 2 后被删除，sent=2、failed=1、最终 keys 为 failed/sent。
- Catalog 证据：状态与日志出现 target-evidence:type.Dictionary，且能定位 Dictionary 的真实调用。
- 你的解释必须同时说出 `Dictionary` 的种类、`count` 的权限，以及 `updateValue(_:forKey:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：状态回到 `Dictionary workload has not run.`；下一次操作从新的字典开始。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 这是独立 `[String: Int]` workload，不借用 `[UUID]` collection renderer 冒充 Dictionary。
- 本卡运行独立 `[String: Int]` workload，直接覆盖 update/default/merge/remove；collection 的 `[UUID]` 不再充当 Dictionary 证据。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 count 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Dictionary`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UUID -->
## type.UUID · UUID

### 学习目标

执行可识别的目标 workload，并解释 `UUID` 为什么是 `Foundation.struct`：生成和解析适合作为稳定身份的 128 位值。

### 机制

- 直觉类比：不会重复的号码牌。
- 类型焦点：`uuidString: String` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`init()`；触发方是App 白名单实验或业务调用方，建议断点名是 `init()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`UUID`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UUID`

### App 操作

进入 Learn，打开 `UUID Experiment`。操作前先口头预测 `UUID` 的 `uuidString` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UUID · UUID
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：用 UUID 创建 probe identity 与唯一 fixture 目录；成功后写入专属 token `target-evidence:type.UUID`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.UUID，且能定位 UUID 的真实调用。
- 你的解释必须同时说出 `UUID` 的种类、`uuidString` 的权限，以及 `init()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 用 UUID 创建 probe identity 与唯一 fixture 目录；成功后写入专属 token `target-evidence:type.UUID`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 uuidString 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `UUID`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Date -->
## type.Date · Date

### 学习目标

执行可识别的目标 workload，并解释 `Date` 为什么是 `Foundation.struct`：表示与时区无关的时间点。

### 机制

- 直觉类比：时间轴上的刻度。
- 类型焦点：`timeIntervalSince1970: TimeInterval` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`addingTimeInterval(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `addingTimeInterval(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`Date`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Date`

### App 操作

进入 Learn，打开 `Date Experiment`。操作前先口头预测 `Date` 的 `timeIntervalSince1970` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Date · Date
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：用 Date 记录 round-trip 完成时间；成功后写入专属 token `target-evidence:type.Date`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.Date，且能定位 Date 的真实调用。
- 你的解释必须同时说出 `Date` 的种类、`timeIntervalSince1970` 的权限，以及 `addingTimeInterval(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 用 Date 记录 round-trip 完成时间；成功后写入专属 token `target-evidence:type.Date`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 timeIntervalSince1970 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Date`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.URL -->
## type.URL · URL

### 学习目标

执行可识别的目标 workload，并解释 `URL` 为什么是 `Foundation.struct`：结构化表示文件或网络资源位置。

### 机制

- 直觉类比：带规则的地址。
- 类型焦点：`absoluteString: String` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`appendingPathComponent(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `appendingPathComponent(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`URL`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.URL`

### App 操作

进入 Learn，打开 `URL Experiment`。操作前先口头预测 `URL` 的 `absoluteString` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.URL · URL
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：持有并读取临时目录 URL 与 inbox.json file URL；成功后写入专属 token `target-evidence:type.URL`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.URL，且能定位 URL 的真实调用。
- 你的解释必须同时说出 `URL` 的种类、`absoluteString` 的权限，以及 `appendingPathComponent(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 持有并读取临时目录 URL 与 inbox.json file URL；成功后写入专属 token `target-evidence:type.URL`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 absoluteString 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `URL`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Data -->
## type.Data · Data

### 学习目标

执行可识别的目标 workload，并解释 `Data` 为什么是 `Foundation.struct`：保存原始字节，是编码与文件 I/O 的边界值。

### 机制

- 直觉类比：装字节的密封袋。
- 类型焦点：`count: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`append(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `append(_:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`Data`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Data`

### App 操作

进入 Learn，打开 `Data Experiment`。操作前先口头预测 `Data` 的 `count` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Data · Data
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：从落盘 JSON URL 读取 Data 并检查 byte count；成功后写入专属 token `target-evidence:type.Data`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.Data，且能定位 Data 的真实调用。
- 你的解释必须同时说出 `Data` 的种类、`count` 的权限，以及 `append(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 从落盘 JSON URL 读取 Data 并检查 byte count；成功后写入专属 token `target-evidence:type.Data`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 count 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Data`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.FileManager -->
## type.FileManager · FileManager

### 学习目标

执行可识别的目标 workload，并解释 `FileManager` 为什么是 `Foundation.class`：查询和修改文件系统中的目录与文件。

### 机制

- 直觉类比：文件仓库管理员。
- 类型焦点：`default: FileManager` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`fileExists(atPath:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `fileExists(atPath:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`FileManager`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.FileManager`

### App 操作

进入 Learn，打开 `FileManager Experiment`。操作前先口头预测 `FileManager` 的 `default` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.FileManager · FileManager
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建、检查并在 Reset/deinit 删除临时 fixture 目录；成功后写入专属 token `target-evidence:type.FileManager`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.FileManager，且能定位 FileManager 的真实调用。
- 你的解释必须同时说出 `FileManager` 的种类、`default` 的权限，以及 `fileExists(atPath:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 创建、检查并在 Reset/deinit 删除临时 fixture 目录；成功后写入专属 token `target-evidence:type.FileManager`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 default 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `FileManager`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Task -->
## type.Task · Task

### 学习目标

执行可识别的目标 workload，并解释 `Task` 为什么是 `Swift.struct`：管理一个结构化或非结构化异步工作单元。

### 机制

- 直觉类比：可以取消的任务单。
- 类型焦点：`value: Success` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`init(priority:operation:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(priority:operation:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡目标：`Task`；共享 renderer：`concurrency`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Task`

### App 操作

进入 Learn，打开 `Task Experiment`。操作前先口头预测 `Task` 的 `value` 会如何影响状态或调用。

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，按 App 中的唯一动作执行：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Task · Task
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建可取消 Task，跨 await 后回到 MainActor 更新状态；成功后写入专属 token `target-evidence:type.Task`。
- Renderer 证据：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Catalog 证据：状态与日志出现 target-evidence:type.Task，且能定位 Task 的真实调用。
- 你的解释必须同时说出 `Task` 的种类、`value` 的权限，以及 `init(priority:operation:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 创建可取消 Task，跨 await 后回到 MainActor 更新状态；成功后写入专属 token `target-evidence:type.Task`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 value 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `Task`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Result -->
## type.Result · Result

### 学习目标

借 shared interaction model 观察与 `Result` 相邻的机制，并明确它不构成目标运行证据：把成功值或失败值保存为可传递状态。

### 机制

- 直觉类比：只装成功或失败之一的信封。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `get()` 的输入、输出与副作用。
- 方法焦点：`get()`；触发方是App 白名单实验或业务调用方，建议断点名是 `get()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `advanceDeliveryState()`
- 本卡目标：`Result`；共享 renderer：`stateMachine`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `Result Related Observation`。操作前先口头预测 `Result` 的 `get()` 会如何影响状态或调用。

1. 从 `sending` 开始连续点击 `Advance State`，写下每一步状态。
2. 核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `advanceDeliveryState()`，按 App 中的唯一动作执行：在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Result · Result
po experiment.id
po experimentState.stateIndex
po currentDeliveryState
po deliveryStateCycle
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。
- Target 边界：`stateMachine` 只是 shared interaction model；未执行 Result 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 Result 的运行证据。
- 你的解释必须同时说出 `Result` 的种类、`无精选属性` 的权限，以及 `get()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stateIndex = 0`，页面重新显示 `sending`。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `enum` 的价值是有限状态与关联值；UI 的 stateIndex 只是选择索引，证据还必须落到实际 enum case。
- 这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。
- renderer 没有执行 `Result` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `get()` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `Result`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIResponder -->
## type.UIResponder · UIResponder

### 学习目标

借 shared interaction model 观察与 `UIResponder` 相邻的机制，并明确它不构成目标运行证据：构成触摸、按键和 action 的响应链节点。

### 机制

- 直觉类比：事件接力队员。
- 类型焦点：`next: UIResponder?` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`becomeFirstResponder()`；触发方是App 白名单实验或业务调用方，建议断点名是 `becomeFirstResponder()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UIResponder`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIResponder Related Observation`。操作前先口头预测 `UIResponder` 的 `next` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIResponder · UIResponder
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 UIResponder 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIResponder 的运行证据。
- 你的解释必须同时说出 `UIResponder` 的种类、`next` 的权限，以及 `becomeFirstResponder()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- renderer 没有执行 `UIResponder` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 next 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `UIResponder`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIApplication -->
## type.UIApplication · UIApplication

### 学习目标

借 shared interaction model 观察与 `UIApplication` 相邻的机制，并明确它不构成目标运行证据：代表应用进程并协调 scene、事件与系统状态。

### 机制

- 直觉类比：应用总调度台。
- 类型焦点：`shared: UIApplication` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`sendAction(_:to:from:for:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `sendAction(_:to:from:for:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UIApplication`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIApplication Related Observation`。操作前先口头预测 `UIApplication` 的 `shared` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIApplication · UIApplication
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 UIApplication 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIApplication 的运行证据。
- 你的解释必须同时说出 `UIApplication` 的种类、`shared` 的权限，以及 `sendAction(_:to:from:for:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- renderer 没有执行 `UIApplication` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 shared 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `UIApplication`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIScene -->
## type.UIScene · UIScene

### 学习目标

借 shared interaction model 观察与 `UIScene` 相邻的机制，并明确它不构成目标运行证据：表示应用界面的一次独立系统会话。

### 机制

- 直觉类比：一场独立舞台演出。
- 类型焦点：`delegate: UISceneDelegate?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(session:connectionOptions:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(session:connectionOptions:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UIScene`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIScene Related Observation`。操作前先口头预测 `UIScene` 的 `delegate` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIScene · UIScene
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 UIScene 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIScene 的运行证据。
- 你的解释必须同时说出 `UIScene` 的种类、`delegate` 的权限，以及 `init(session:connectionOptions:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- renderer 没有执行 `UIScene` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 delegate 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIScene`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIWindow -->
## type.UIWindow · UIWindow

### 学习目标

借 shared interaction model 观察与 `UIWindow` 相邻的机制，并明确它不构成目标运行证据：把控制器树接入某个 UIWindowScene 并显示。

### 机制

- 直觉类比：装舞台的窗框。
- 类型焦点：`windowScene: UIWindowScene?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`makeKeyAndVisible()`；触发方是App 白名单实验或业务调用方，建议断点名是 `makeKeyAndVisible()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UIWindow`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIWindow Related Observation`。操作前先口头预测 `UIWindow` 的 `windowScene` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIWindow · UIWindow
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 UIWindow 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIWindow 的运行证据。
- 你的解释必须同时说出 `UIWindow` 的种类、`windowScene` 的权限，以及 `makeKeyAndVisible()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- renderer 没有执行 `UIWindow` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 windowScene 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIWindow`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIView -->
## type.UIView · UIView

### 学习目标

执行可识别的目标 workload，并解释 `UIView` 为什么是 `UIKit.class`：管理矩形区域、绘制、层级和布局。

### 机制

- 直觉类比：贴在画布上的透明卡片。
- 类型焦点：`frame: CGRect` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`addSubview(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `addSubview(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`UIView`；共享 renderer：`viewAppearance`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UIView`

### App 操作

进入 Learn，打开 `UIView Experiment`。操作前先口头预测 `UIView` 的 `frame` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIView · UIView
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 preview UIView 并修改 alpha、backgroundColor 与 isHidden；成功后写入专属 token `target-evidence:type.UIView`。
- Renderer 证据：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Catalog 证据：状态与日志出现 target-evidence:type.UIView，且能定位 UIView 的真实调用。
- 你的解释必须同时说出 `UIView` 的种类、`frame` 的权限，以及 `addSubview(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- 创建 preview UIView 并修改 alpha、backgroundColor 与 isHidden；成功后写入专属 token `target-evidence:type.UIView`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 frame 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.NSLayoutAnchor -->
## type.NSLayoutAnchor · NSLayoutAnchor

### 学习目标

执行可识别的目标 workload，并解释 `NSLayoutAnchor` 为什么是 `UIKit.class`：以类型安全方式创建某一轴或尺寸的约束。

### 机制

- 直觉类比：只连接同类尺寸的卡扣。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `constraint(equalTo:)` 的输入、输出与副作用。
- 方法焦点：`constraint(equalTo:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `constraint(equalTo:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`NSLayoutAnchor`；共享 renderer：`viewAppearance`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.NSLayoutAnchor`

### App 操作

进入 Learn，打开 `NSLayoutAnchor Experiment`。操作前先口头预测 `NSLayoutAnchor` 的 `constraint(equalTo:)` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.NSLayoutAnchor · NSLayoutAnchor
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：使用 center/width/height anchors 创建约束；成功后写入专属 token `target-evidence:type.NSLayoutAnchor`。
- Renderer 证据：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Catalog 证据：状态与日志出现 target-evidence:type.NSLayoutAnchor，且能定位 NSLayoutAnchor 的真实调用。
- 你的解释必须同时说出 `NSLayoutAnchor` 的种类、`无精选属性` 的权限，以及 `constraint(equalTo:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- 使用 center/width/height anchors 创建约束；成功后写入专属 token `target-evidence:type.NSLayoutAnchor`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `constraint(equalTo:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `NSLayoutAnchor`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.NSLayoutConstraint -->
## type.NSLayoutConstraint · NSLayoutConstraint

### 学习目标

执行可识别的目标 workload，并解释 `NSLayoutConstraint` 为什么是 `UIKit.class`：描述两个布局属性之间的方程和优先级。

### 机制

- 直觉类比：布局方程。
- 类型焦点：`isActive: Bool` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`activate(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `activate(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`NSLayoutConstraint`；共享 renderer：`viewAppearance`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.NSLayoutConstraint`

### App 操作

进入 Learn，打开 `NSLayoutConstraint Experiment`。操作前先口头预测 `NSLayoutConstraint` 的 `isActive` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.NSLayoutConstraint · NSLayoutConstraint
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：激活 preview 的 NSLayoutConstraint 集合；成功后写入专属 token `target-evidence:type.NSLayoutConstraint`。
- Renderer 证据：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Catalog 证据：状态与日志出现 target-evidence:type.NSLayoutConstraint，且能定位 NSLayoutConstraint 的真实调用。
- 你的解释必须同时说出 `NSLayoutConstraint` 的种类、`isActive` 的权限，以及 `activate(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- 激活 preview 的 NSLayoutConstraint 集合；成功后写入专属 token `target-evidence:type.NSLayoutConstraint`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 isActive 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `NSLayoutConstraint`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIStackView -->
## type.UIStackView · UIStackView

### 学习目标

借 shared interaction model 观察与 `UIStackView` 相邻的机制，并明确它不构成目标运行证据：按轴自动排列 arrangedSubviews 并管理间距。

### 机制

- 直觉类比：自动排队的展示架。
- 类型焦点：`axis: NSLayoutConstraint.Axis` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`addArrangedSubview(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `addArrangedSubview(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`UIStackView`；共享 renderer：`viewAppearance`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIStackView Related Observation`。操作前先口头预测 `UIStackView` 的 `axis` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIStackView · UIStackView
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Target 边界：`viewAppearance` 只是 shared interaction model；未执行 UIStackView 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIStackView 的运行证据。
- 你的解释必须同时说出 `UIStackView` 的种类、`axis` 的权限，以及 `addArrangedSubview(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- renderer 没有执行 `UIStackView` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 axis 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIStackView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIViewController -->
## type.UIViewController · UIViewController

### 学习目标

执行可识别的目标 workload，并解释 `UIViewController` 为什么是 `UIKit.class`：管理一棵 view 并协调出现、离开和展示。

### 机制

- 直觉类比：一页内容的导演。
- 类型焦点：`view: UIView!` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`loadView()`；触发方是App 白名单实验或业务调用方，建议断点名是 `loadView()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UIViewController`；共享 renderer：`navigation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UIViewController`

### App 操作

进入 Learn，打开 `UIViewController Experiment`。操作前先口头预测 `UIViewController` 的 `view` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIViewController · UIViewController
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建并 push NavigationProbeViewController，记录生命周期；成功后写入专属 token `target-evidence:type.UIViewController`。
- Renderer 证据：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Catalog 证据：状态与日志出现 target-evidence:type.UIViewController，且能定位 UIViewController 的真实调用。
- 你的解释必须同时说出 `UIViewController` 的种类、`view` 的权限，以及 `loadView()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- 创建并 push NavigationProbeViewController，记录生命周期；成功后写入专属 token `target-evidence:type.UIViewController`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 view 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIViewController`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UINavigationItem -->
## type.UINavigationItem · UINavigationItem

### 学习目标

借 shared interaction model 观察与 `UINavigationItem` 相邻的机制，并明确它不构成目标运行证据：保存某个页面在 navigation bar 上的展示配置。

### 机制

- 直觉类比：页面交给导航栏的名片。
- 类型焦点：`title: String?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`setLeftBarButton(_:animated:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `setLeftBarButton(_:animated:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UINavigationItem`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UINavigationItem Related Observation`。操作前先口头预测 `UINavigationItem` 的 `title` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UINavigationItem · UINavigationItem
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 UINavigationItem 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UINavigationItem 的运行证据。
- 你的解释必须同时说出 `UINavigationItem` 的种类、`title` 的权限，以及 `setLeftBarButton(_:animated:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- renderer 没有执行 `UINavigationItem` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 title 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UINavigationItem`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UINavigationController -->
## type.UINavigationController · UINavigationController

### 学习目标

执行可识别的目标 workload，并解释 `UINavigationController` 为什么是 `UIKit.class`：用栈保存页面实例并提供 push/pop 导航。

### 机制

- 直觉类比：后进先出的页面栈。
- 类型焦点：`viewControllers: [UIViewController]` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`pushViewController(_:animated:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `pushViewController(_:animated:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡目标：`UINavigationController`；共享 renderer：`navigation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UINavigationController`

### App 操作

进入 Learn，打开 `UINavigationController Experiment`。操作前先口头预测 `UINavigationController` 的 `viewControllers` 会如何影响状态或调用。

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，按 App 中的唯一动作执行：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UINavigationController · UINavigationController
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：通过真实 navigationController 执行 push/pop；成功后写入专属 token `target-evidence:type.UINavigationController`。
- Renderer 证据：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Catalog 证据：状态与日志出现 target-evidence:type.UINavigationController，且能定位 UINavigationController 的真实调用。
- 你的解释必须同时说出 `UINavigationController` 的种类、`viewControllers` 的权限，以及 `pushViewController(_:animated:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- 通过真实 navigationController 执行 push/pop；成功后写入专属 token `target-evidence:type.UINavigationController`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 viewControllers 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UINavigationController`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UILabel -->
## type.UILabel · UILabel

### 学习目标

借 shared interaction model 观察与 `UILabel` 相邻的机制，并明确它不构成目标运行证据：展示一段不可直接编辑的文字。

### 机制

- 直觉类比：屏幕上的文字牌。
- 类型焦点：`text: String?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`sizeToFit()`；触发方是App 白名单实验或业务调用方，建议断点名是 `sizeToFit()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`UILabel`；共享 renderer：`viewAppearance`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UILabel Related Observation`。操作前先口头预测 `UILabel` 的 `text` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UILabel · UILabel
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Target 边界：`viewAppearance` 只是 shared interaction model；未执行 UILabel 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UILabel 的运行证据。
- 你的解释必须同时说出 `UILabel` 的种类、`text` 的权限，以及 `sizeToFit()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- renderer 没有执行 `UILabel` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 text 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UILabel`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIImageView -->
## type.UIImageView · UIImageView

### 学习目标

借 shared interaction model 观察与 `UIImageView` 相邻的机制，并明确它不构成目标运行证据：展示 UIImage 并控制其缩放与裁切方式。

### 机制

- 直觉类比：带缩放规则的相框。
- 类型焦点：`image: UIImage?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`startAnimating()`；触发方是App 白名单实验或业务调用方，建议断点名是 `startAnimating()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡目标：`UIImageView`；共享 renderer：`viewAppearance`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIImageView Related Observation`。操作前先口头预测 `UIImageView` 的 `image` 会如何影响状态或调用。

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，按 App 中的唯一动作执行：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIImageView · UIImageView
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Target 边界：`viewAppearance` 只是 shared interaction model；未执行 UIImageView 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIImageView 的运行证据。
- 你的解释必须同时说出 `UIImageView` 的种类、`image` 的权限，以及 `startAnimating()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- renderer 没有执行 `UIImageView` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 image 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIImageView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIControl -->
## type.UIControl · UIControl

### 学习目标

执行可识别的目标 workload，并解释 `UIControl` 为什么是 `UIKit.class`：把触摸等事件转换为可注册的 action。

### 机制

- 直觉类比：带事件线路的开关。
- 类型焦点：`isEnabled: Bool` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`addTarget(_:action:for:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `addTarget(_:action:for:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `actionButtonTapped()`
- 本卡目标：`UIControl`；共享 renderer：`button`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UIControl`

### App 操作

进入 Learn，打开 `UIControl Experiment`。操作前先口头预测 `UIControl` 的 `isEnabled` 会如何影响状态或调用。

1. 点击 `Send Action`，确认 action count 增加；再关闭 `isEnabled`。
2. 在禁用状态尝试点击，比较 action count 与日志是否保持不变。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `actionButtonTapped()`，按 App 中的唯一动作执行：在 actionButtonTapped() 设置断点，点击 Send Action 后查看调用来源。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIControl · UIControl
po experiment.id
po experimentState.isEnabled
po experimentState.taps
expr experimentState.isEnabled = false
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：修改 isEnabled 并发送 touchUpInside control event；成功后写入专属 token `target-evidence:type.UIControl`。
- Renderer 证据：启用时日志出现 `touchUpInside action fired` 且 count 增加；禁用后不发送 action。
- Catalog 证据：状态与日志出现 target-evidence:type.UIControl，且能定位 UIControl 的真实调用。
- 你的解释必须同时说出 `UIControl` 的种类、`isEnabled` 的权限，以及 `addTarget(_:action:for:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`isEnabled = true`、`action count = 0`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 直接在 LLDB 改 model 字段不会自动刷新 UIButton；真实 UI 还需经过 renderer 把状态写回控件。
- 修改 isEnabled 并发送 touchUpInside control event；成功后写入专属 token `target-evidence:type.UIControl`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 isEnabled 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIControl`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIButton -->
## type.UIButton · UIButton

### 学习目标

执行可识别的目标 workload，并解释 `UIButton` 为什么是 `UIKit.class`：提供可配置、可禁用并能发送 action 的按钮。

### 机制

- 直觉类比：会汇报点击的按钮。
- 类型焦点：`configuration: Configuration?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`setTitle(_:for:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `setTitle(_:for:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `actionButtonTapped()`
- 本卡目标：`UIButton`；共享 renderer：`button`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UIButton`

### App 操作

进入 Learn，打开 `UIButton Experiment`。操作前先口头预测 `UIButton` 的 `configuration` 会如何影响状态或调用。

1. 点击 `Send Action`，确认 action count 增加；再关闭 `isEnabled`。
2. 在禁用状态尝试点击，比较 action count 与日志是否保持不变。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `actionButtonTapped()`，按 App 中的唯一动作执行：在 actionButtonTapped() 设置断点，点击 Send Action 后查看调用来源。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIButton · UIButton
po experiment.id
po experimentState.isEnabled
po experimentState.taps
expr experimentState.isEnabled = false
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 UIButton 并触发 target-action；成功后写入专属 token `target-evidence:type.UIButton`。
- Renderer 证据：启用时日志出现 `touchUpInside action fired` 且 count 增加；禁用后不发送 action。
- Catalog 证据：状态与日志出现 target-evidence:type.UIButton，且能定位 UIButton 的真实调用。
- 你的解释必须同时说出 `UIButton` 的种类、`configuration` 的权限，以及 `setTitle(_:for:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`isEnabled = true`、`action count = 0`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 直接在 LLDB 改 model 字段不会自动刷新 UIButton；真实 UI 还需经过 renderer 把状态写回控件。
- 创建 UIButton 并触发 target-action；成功后写入专属 token `target-evidence:type.UIButton`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 configuration 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIButton`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIButton.Configuration -->
## type.UIButton.Configuration · UIButton.Configuration

### 学习目标

执行可识别的目标 workload，并解释 `UIButton.Configuration` 为什么是 `UIKit.struct`：以值类型集中描述按钮标题、图标、颜色和尺寸。

### 机制

- 直觉类比：按钮的样式清单。
- 类型焦点：`title: String?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`plain()`；触发方是App 白名单实验或业务调用方，建议断点名是 `plain()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `actionButtonTapped()`
- 本卡目标：`UIButton.Configuration`；共享 renderer：`button`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UIButton.Configuration`

### App 操作

进入 Learn，打开 `UIButton.Configuration Experiment`。操作前先口头预测 `UIButton.Configuration` 的 `title` 会如何影响状态或调用。

1. 点击 `Send Action`，确认 action count 增加；再关闭 `isEnabled`。
2. 在禁用状态尝试点击，比较 action count 与日志是否保持不变。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `actionButtonTapped()`，按 App 中的唯一动作执行：在 actionButtonTapped() 设置断点，点击 Send Action 后查看调用来源。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIButton.Configuration · UIButton.Configuration
po experiment.id
po experimentState.isEnabled
po experimentState.taps
expr experimentState.isEnabled = false
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 filled/bordered UIButton.Configuration 并应用到按钮；成功后写入专属 token `target-evidence:type.UIButton.Configuration`。
- Renderer 证据：启用时日志出现 `touchUpInside action fired` 且 count 增加；禁用后不发送 action。
- Catalog 证据：状态与日志出现 target-evidence:type.UIButton.Configuration，且能定位 UIButton.Configuration 的真实调用。
- 你的解释必须同时说出 `UIButton.Configuration` 的种类、`title` 的权限，以及 `plain()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`isEnabled = true`、`action count = 0`。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 直接在 LLDB 改 model 字段不会自动刷新 UIButton；真实 UI 还需经过 renderer 把状态写回控件。
- 创建 filled/bordered UIButton.Configuration 并应用到按钮；成功后写入专属 token `target-evidence:type.UIButton.Configuration`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 title 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIButton.Configuration`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UITextField -->
## type.UITextField · UITextField

### 学习目标

执行可识别的目标 workload，并解释 `UITextField` 为什么是 `UIKit.class`：接收单行文本并参与第一响应者和 delegate 流程。

### 机制

- 直觉类比：单行填写框。
- 类型焦点：`text: String?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`becomeFirstResponder()`；触发方是App 白名单实验或业务调用方，建议断点名是 `becomeFirstResponder()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `textFieldShouldReturn(_:)`
- 本卡目标：`UITextField`；共享 renderer：`textInput`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UITextField`

### App 操作

进入 Learn，打开 `UITextField Experiment`。操作前先口头预测 `UITextField` 的 `text` 会如何影响状态或调用。

1. 点击 `Become First Responder`，输入一个字符，再按 Return。
2. 按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `textFieldShouldReturn(_:)`，按 App 中的唯一动作执行：在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UITextField · UITextField
po experiment.id
po inputField?.isFirstResponder
po experimentState.text
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 UITextField，输入文本并改变 first responder；成功后写入专属 token `target-evidence:type.UITextField`。
- Renderer 证据：日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。
- Catalog 证据：状态与日志出现 target-evidence:type.UITextField，且能定位 UITextField 的真实调用。
- 你的解释必须同时说出 `UITextField` 的种类、`text` 的权限，以及 `becomeFirstResponder()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。
- 创建 UITextField，输入文本并改变 first responder；成功后写入专属 token `target-evidence:type.UITextField`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 text 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UITextField`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UITextView -->
## type.UITextView · UITextView

### 学习目标

借 shared interaction model 观察与 `UITextView` 相邻的机制，并明确它不构成目标运行证据：编辑和滚动多行富文本。

### 机制

- 直觉类比：可滚动的多行稿纸。
- 类型焦点：`text: String!` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`scrollRangeToVisible(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `scrollRangeToVisible(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `textFieldShouldReturn(_:)`
- 本卡目标：`UITextView`；共享 renderer：`textInput`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UITextView Related Observation`。操作前先口头预测 `UITextView` 的 `text` 会如何影响状态或调用。

1. 点击 `Become First Responder`，输入一个字符，再按 Return。
2. 按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `textFieldShouldReturn(_:)`，按 App 中的唯一动作执行：在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UITextView · UITextView
po experiment.id
po inputField?.isFirstResponder
po experimentState.text
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。
- Target 边界：`textInput` 只是 shared interaction model；未执行 UITextView 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UITextView 的运行证据。
- 你的解释必须同时说出 `UITextView` 的种类、`text` 的权限，以及 `scrollRangeToVisible(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。
- renderer 没有执行 `UITextView` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 text 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UITextView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UITextFieldDelegate -->
## type.UITextFieldDelegate · UITextFieldDelegate

### 学习目标

执行可识别的目标 workload，并解释 `UITextFieldDelegate` 为什么是 `UIKit.protocol`：在文本变化、Return 和结束编辑前后提供决策与通知。

### 机制

- 直觉类比：单行输入框的观察员。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `textField(_:shouldChangeCharactersIn:replacementString:)` 的输入、输出与副作用。
- 方法焦点：`textField(_:shouldChangeCharactersIn:replacementString:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `textField(_:shouldChangeCharactersIn:replacementString:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `textFieldShouldReturn(_:)`
- 本卡目标：`UITextFieldDelegate`；共享 renderer：`textInput`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UITextFieldDelegate`

### App 操作

进入 Learn，打开 `UITextFieldDelegate Experiment`。操作前先口头预测 `UITextFieldDelegate` 的 `textField(_:shouldChangeCharactersIn:replacementString:)` 会如何影响状态或调用。

1. 点击 `Become First Responder`，输入一个字符，再按 Return。
2. 按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `textFieldShouldReturn(_:)`，按 App 中的唯一动作执行：在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UITextFieldDelegate · UITextFieldDelegate
po experiment.id
po inputField?.isFirstResponder
po experimentState.text
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：安装 UITextFieldDelegate 并触发 shouldChange/shouldReturn 回调；成功后写入专属 token `target-evidence:type.UITextFieldDelegate`。
- Renderer 证据：日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。
- Catalog 证据：状态与日志出现 target-evidence:type.UITextFieldDelegate，且能定位 UITextFieldDelegate 的真实调用。
- 你的解释必须同时说出 `UITextFieldDelegate` 的种类、`无精选属性` 的权限，以及 `textField(_:shouldChangeCharactersIn:replacementString:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。
- 当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。
- 安装 UITextFieldDelegate 并触发 shouldChange/shouldReturn 回调；成功后写入专属 token `target-evidence:type.UITextFieldDelegate`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `textField(_:shouldChangeCharactersIn:replacementString:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `UITextFieldDelegate`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UITextViewDelegate -->
## type.UITextViewDelegate · UITextViewDelegate

### 学习目标

借 shared interaction model 观察与 `UITextViewDelegate` 相邻的机制，并明确它不构成目标运行证据：接收 UITextView 编辑、选择和链接交互回调。

### 机制

- 直觉类比：多行输入框的观察员。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `textViewDidChange(_:)` 的输入、输出与副作用。
- 方法焦点：`textViewDidChange(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `textViewDidChange(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `textFieldShouldReturn(_:)`
- 本卡目标：`UITextViewDelegate`；共享 renderer：`textInput`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UITextViewDelegate Related Observation`。操作前先口头预测 `UITextViewDelegate` 的 `textViewDidChange(_:)` 会如何影响状态或调用。

1. 点击 `Become First Responder`，输入一个字符，再按 Return。
2. 按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `textFieldShouldReturn(_:)`，按 App 中的唯一动作执行：在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UITextViewDelegate · UITextViewDelegate
po experiment.id
po inputField?.isFirstResponder
po experimentState.text
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。
- Target 边界：`textInput` 只是 shared interaction model；未执行 UITextViewDelegate 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UITextViewDelegate 的运行证据。
- 你的解释必须同时说出 `UITextViewDelegate` 的种类、`无精选属性` 的权限，以及 `textViewDidChange(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。
- 当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。
- renderer 没有执行 `UITextViewDelegate` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `textViewDidChange(_:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `UITextViewDelegate`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UIScrollView -->
## type.UIScrollView · UIScrollView

### 学习目标

借 shared interaction model 观察与 `UIScrollView` 相邻的机制，并明确它不构成目标运行证据：通过 contentSize 与 contentOffset 展示大于可视区域的内容。

### 机制

- 直觉类比：能移动视窗的长画卷。
- 类型焦点：`contentOffset: CGPoint` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`setContentOffset(_:animated:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `setContentOffset(_:animated:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UIScrollView`；共享 renderer：`collection`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UIScrollView Related Observation`。操作前先口头预测 `UIScrollView` 的 `contentOffset` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UIScrollView · UIScrollView
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Target 边界：`collection` 只是 shared interaction model；未执行 UIScrollView 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UIScrollView 的运行证据。
- 你的解释必须同时说出 `UIScrollView` 的种类、`contentOffset` 的权限，以及 `setContentOffset(_:animated:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- renderer 没有执行 `UIScrollView` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 contentOffset 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UIScrollView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UICollectionView -->
## type.UICollectionView · UICollectionView

### 学习目标

执行可识别的目标 workload，并解释 `UICollectionView` 为什么是 `UIKit.class`：通过 layout、data source 和复用 cell 展示大量项目。

### 机制

- 直觉类比：只摆出可见卡片的货架。
- 类型焦点：`dataSource: UICollectionViewDataSource?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`reloadData()`；触发方是App 白名单实验或业务调用方，建议断点名是 `reloadData()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UICollectionView`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UICollectionView`

### App 操作

进入 Learn，打开 `UICollectionView Experiment`。操作前先口头预测 `UICollectionView` 的 `dataSource` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UICollectionView · UICollectionView
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 UICollectionView 并应用 diffable snapshot；成功后写入专属 token `target-evidence:type.UICollectionView`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.UICollectionView，且能定位 UICollectionView 的真实调用。
- 你的解释必须同时说出 `UICollectionView` 的种类、`dataSource` 的权限，以及 `reloadData()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 创建 UICollectionView 并应用 diffable snapshot；成功后写入专属 token `target-evidence:type.UICollectionView`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 dataSource 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UICollectionView`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UICollectionViewCell -->
## type.UICollectionViewCell · UICollectionViewCell

### 学习目标

执行可识别的目标 workload，并解释 `UICollectionViewCell` 为什么是 `UIKit.class`：作为可复用容器展示一个 item。

### 机制

- 直觉类比：反复换内容的展示卡。
- 类型焦点：`isSelected: Bool` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`prepareForReuse()`；触发方是App 白名单实验或业务调用方，建议断点名是 `prepareForReuse()`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UICollectionViewCell`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UICollectionViewCell`

### App 操作

进入 Learn，打开 `UICollectionViewCell Experiment`。操作前先口头预测 `UICollectionViewCell` 的 `isSelected` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UICollectionViewCell · UICollectionViewCell
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：注册并 dequeue UICollectionViewListCell；成功后写入专属 token `target-evidence:type.UICollectionViewCell`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.UICollectionViewCell，且能定位 UICollectionViewCell 的真实调用。
- 你的解释必须同时说出 `UICollectionViewCell` 的种类、`isSelected` 的权限，以及 `prepareForReuse()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 注册并 dequeue UICollectionViewListCell；成功后写入专属 token `target-evidence:type.UICollectionViewCell`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 isSelected 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UICollectionViewCell`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UICollectionViewDataSource -->
## type.UICollectionViewDataSource · UICollectionViewDataSource

### 学习目标

执行可识别的目标 workload，并解释 `UICollectionViewDataSource` 为什么是 `UIKit.protocol`：回答 collection view 有多少项以及每项使用哪个 cell。

### 机制

- 直觉类比：货架的供货清单。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `collectionView(_:numberOfItemsInSection:)` 的输入、输出与副作用。
- 方法焦点：`collectionView(_:numberOfItemsInSection:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `collectionView(_:numberOfItemsInSection:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UICollectionViewDataSource`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UICollectionViewDataSource`

### App 操作

进入 Learn，打开 `UICollectionViewDataSource Experiment`。操作前先口头预测 `UICollectionViewDataSource` 的 `collectionView(_:numberOfItemsInSection:)` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UICollectionViewDataSource · UICollectionViewDataSource
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：让 diffable data source 为 collection view 提供 cell；成功后写入专属 token `target-evidence:type.UICollectionViewDataSource`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.UICollectionViewDataSource，且能定位 UICollectionViewDataSource 的真实调用。
- 你的解释必须同时说出 `UICollectionViewDataSource` 的种类、`无精选属性` 的权限，以及 `collectionView(_:numberOfItemsInSection:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 让 diffable data source 为 collection view 提供 cell；成功后写入专属 token `target-evidence:type.UICollectionViewDataSource`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `collectionView(_:numberOfItemsInSection:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `UICollectionViewDataSource`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UICollectionViewDelegate -->
## type.UICollectionViewDelegate · UICollectionViewDelegate

### 学习目标

借 shared interaction model 观察与 `UICollectionViewDelegate` 相邻的机制，并明确它不构成目标运行证据：接收选中、显示和交互等 collection view 事件。

### 机制

- 直觉类比：货架交互观察员。
- 类型焦点：本卡没有精选属性，观察重点转向方法 `collectionView(_:didSelectItemAt:)` 的输入、输出与副作用。
- 方法焦点：`collectionView(_:didSelectItemAt:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `collectionView(_:didSelectItemAt:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UICollectionViewDelegate`；共享 renderer：`collection`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `UICollectionViewDelegate Related Observation`。操作前先口头预测 `UICollectionViewDelegate` 的 `collectionView(_:didSelectItemAt:)` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UICollectionViewDelegate · UICollectionViewDelegate
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Target 边界：`collection` 只是 shared interaction model；未执行 UICollectionViewDelegate 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 UICollectionViewDelegate 的运行证据。
- 你的解释必须同时说出 `UICollectionViewDelegate` 的种类、`无精选属性` 的权限，以及 `collectionView(_:didSelectItemAt:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- renderer 没有执行 `UICollectionViewDelegate` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. `collectionView(_:didSelectItemAt:)` 的输入、输出与可观察副作用分别是什么？
2. 按“谁创建、谁持有、何时释放”解释 `UICollectionViewDelegate`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.UICollectionViewDiffableDataSource -->
## type.UICollectionViewDiffableDataSource · UICollectionViewDiffableDataSource

### 学习目标

执行可识别的目标 workload，并解释 `UICollectionViewDiffableDataSource` 为什么是 `UIKit.class`：用稳定 item identity 从 snapshot 计算安全差异更新。

### 机制

- 直觉类比：按身份证更新货架的管理员。
- 类型焦点：`supplementaryViewProvider: SupplementaryViewProvider?` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(collectionView:cellProvider:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(collectionView:cellProvider:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`UICollectionViewDiffableDataSource`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.UICollectionViewDiffableDataSource`

### App 操作

进入 Learn，打开 `UICollectionViewDiffableDataSource Experiment`。操作前先口头预测 `UICollectionViewDiffableDataSource` 的 `supplementaryViewProvider` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.UICollectionViewDiffableDataSource · UICollectionViewDiffableDataSource
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 UICollectionViewDiffableDataSource 并 apply snapshot；成功后写入专属 token `target-evidence:type.UICollectionViewDiffableDataSource`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.UICollectionViewDiffableDataSource，且能定位 UICollectionViewDiffableDataSource 的真实调用。
- 你的解释必须同时说出 `UICollectionViewDiffableDataSource` 的种类、`supplementaryViewProvider` 的权限，以及 `init(collectionView:cellProvider:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 创建 UICollectionViewDiffableDataSource 并 apply snapshot；成功后写入专属 token `target-evidence:type.UICollectionViewDiffableDataSource`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 supplementaryViewProvider 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `UICollectionViewDiffableDataSource`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.NSDiffableDataSourceSnapshot -->
## type.NSDiffableDataSourceSnapshot · NSDiffableDataSourceSnapshot

### 学习目标

执行可识别的目标 workload，并解释 `NSDiffableDataSourceSnapshot` 为什么是 `UIKit.struct`：以有序 section/item identifier 描述某一时刻的数据状态。

### 机制

- 直觉类比：货架当前摆放快照。
- 类型焦点：`numberOfItems: Int` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`appendSections(_:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `appendSections(_:)`。
- 所有权：创建：UIKit、SceneDelegate 或页面配置代码；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡目标：`NSDiffableDataSourceSnapshot`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.NSDiffableDataSourceSnapshot`

### App 操作

进入 Learn，打开 `NSDiffableDataSourceSnapshot Experiment`。操作前先口头预测 `NSDiffableDataSourceSnapshot` 的 `numberOfItems` 会如何影响状态或调用。

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，按 App 中的唯一动作执行：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.NSDiffableDataSourceSnapshot · NSDiffableDataSourceSnapshot
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 snapshot，append section/items 后应用；成功后写入专属 token `target-evidence:type.NSDiffableDataSourceSnapshot`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：状态与日志出现 target-evidence:type.NSDiffableDataSourceSnapshot，且能定位 NSDiffableDataSourceSnapshot 的真实调用。
- 你的解释必须同时说出 `NSDiffableDataSourceSnapshot` 的种类、`numberOfItems` 的权限，以及 `appendSections(_:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 创建 snapshot，append section/items 后应用；成功后写入专属 token `target-evidence:type.NSDiffableDataSourceSnapshot`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 numberOfItems 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `NSDiffableDataSourceSnapshot`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.AppEnvironment -->
## type.AppEnvironment · AppEnvironment

### 学习目标

借 shared interaction model 观察与 `AppEnvironment` 相邻的机制，并明确它不构成目标运行证据：在组合根创建并持有日志、缓存、Repository 与发送协调器。

### 机制

- 直觉类比：应用的配电箱。
- 类型焦点：`log: LabLogStore` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`makeDefault()`；触发方是App 白名单实验或业务调用方，建议断点名是 `makeDefault()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `advanceDeliveryState()`
- 本卡目标：`AppEnvironment`；共享 renderer：`stateMachine`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `AppEnvironment Related Observation`。操作前先口头预测 `AppEnvironment` 的 `log` 会如何影响状态或调用。

1. 从 `sending` 开始连续点击 `Advance State`，写下每一步状态。
2. 核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `advanceDeliveryState()`，按 App 中的唯一动作执行：在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.AppEnvironment · AppEnvironment
po experiment.id
po experimentState.stateIndex
po currentDeliveryState
po deliveryStateCycle
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Shared interaction model：真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。
- Target 边界：`stateMachine` 只是 shared interaction model；未执行 AppEnvironment 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；不能把结果当作 AppEnvironment 的运行证据。
- 你的解释必须同时说出 `AppEnvironment` 的种类、`log` 的权限，以及 `makeDefault()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stateIndex = 0`，页面重新显示 `sending`。 然后重复同一动作，确认日志只描述新一轮操作；本入口是关联观察，始终不写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。
- renderer 没有执行 `AppEnvironment` 专属 workload；本次状态变化只能作为关联观察。
- 分类结论以 `related observation` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 log 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `AppEnvironment`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.MessageRepository -->
## type.MessageRepository · MessageRepository

### 学习目标

执行可识别的目标 workload，并解释 `MessageRepository` 为什么是 `SwiftMessengerCore.class`：作为消息与会话状态的单一内存 owner。

### 机制

- 直觉类比：消息账本管理员。
- 类型焦点：`conversations: [Conversation]` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`enqueueOutgoing(text:conversationID:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `enqueueOutgoing(text:conversationID:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：创建它的强引用、UIKit 层级或业务组合根；释放：最后一个强引用解除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageRepository.swift](../SwiftMessengerLab/Core/MessageRepository.swift)
- Symbol: `enqueueOutgoing(text:conversationID:id:date:)`
- 本卡目标：`MessageRepository`；共享 renderer：`repository`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.MessageRepository`

### App 操作

进入 Learn，打开 `MessageRepository Experiment`。操作前先口头预测 `MessageRepository` 的 `conversations` 会如何影响状态或调用。

1. 点击 `Enqueue Outgoing Message`，让真实 MessageRepository 调用 enqueueOutgoing。
2. 核对 messages 只增加 1、新消息为 queued，且 Design 会话 preview 等于新文本。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `enqueueOutgoing(text:conversationID:id:date:)`，按 App 中的唯一动作执行：在 enqueueOutgoing(...) 设置断点，执行后检查消息数、queued 状态与会话预览。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.MessageRepository · MessageRepository
po text
po conversationID
po self.snapshotValue.messages.count
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：调用 enqueueOutgoing，验证消息 append、queued 状态与会话 preview 更新；成功后写入专属 token `target-evidence:type.MessageRepository`。
- Renderer 证据：状态显示 messages N -> N+1、queued message id 与更新后的 preview；断点命中 enqueueOutgoing。
- Catalog 证据：状态与日志出现 target-evidence:type.MessageRepository，且能定位 MessageRepository 的真实调用。
- 你的解释必须同时说出 `MessageRepository` 的种类、`conversations` 的权限，以及 `enqueueOutgoing(text:conversationID:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：重新创建只含 SampleInbox.snapshot 的 MessageRepository，临时 outgoing message 消失。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。
- 该 workload 只证明 Repository 内存 append 与 preview 更新；网络发送由 MessageTransport 卡验证。
- 本卡真实创建 MessageRepository 并命中 enqueueOutgoing；只验证内存 append、queued 与 preview，不冒充 transport 发送证据。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 conversations 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `MessageRepository`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.JSONInboxCache -->
## type.JSONInboxCache · JSONInboxCache

### 学习目标

执行可识别的目标 workload，并解释 `JSONInboxCache` 为什么是 `SwiftMessengerCore.struct`：把 InboxSnapshot 原子编码到本地 JSON 文件。

### 机制

- 直觉类比：本地文件保险柜。
- 类型焦点：`fileURL: URL` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`load()`；触发方是App 白名单实验或业务调用方，建议断点名是 `load()`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`JSONInboxCache`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.JSONInboxCache`

### App 操作

进入 Learn，打开 `JSONInboxCache Experiment`。操作前先口头预测 `JSONInboxCache` 的 `fileURL` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.JSONInboxCache · JSONInboxCache
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：用 JSONInboxCache save/load 同一 InboxSnapshot；成功后写入专属 token `target-evidence:type.JSONInboxCache`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.JSONInboxCache，且能定位 JSONInboxCache 的真实调用。
- 你的解释必须同时说出 `JSONInboxCache` 的种类、`fileURL` 的权限，以及 `load()` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 用 JSONInboxCache save/load 同一 InboxSnapshot；成功后写入专属 token `target-evidence:type.JSONInboxCache`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 fileURL 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `JSONInboxCache`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.MockMessageTransport -->
## type.MockMessageTransport · MockMessageTransport

### 学习目标

执行可识别的目标 workload，并解释 `MockMessageTransport` 为什么是 `SwiftMessengerCore.struct`：用确定性延迟与失败规则替代真实网络。

### 机制

- 直觉类比：可重复排练的假快递员。
- 类型焦点：`delayNanoseconds: UInt64 (private)` 是 `get-only`；通过改变输入或调用方法观察。
- 方法焦点：`init(delayNanoseconds:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(delayNanoseconds:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡目标：`MockMessageTransport`；共享 renderer：`concurrency`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.MockMessageTransport`

### App 操作

进入 Learn，打开 `MockMessageTransport Experiment`。操作前先口头预测 `MockMessageTransport` 的 `delayNanoseconds` 会如何影响状态或调用。

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，按 App 中的唯一动作执行：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.MockMessageTransport · MockMessageTransport
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 MockMessageTransport 并执行确定性 send；成功后写入专属 token `target-evidence:type.MockMessageTransport`。
- Renderer 证据：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Catalog 证据：状态与日志出现 target-evidence:type.MockMessageTransport，且能定位 MockMessageTransport 的真实调用。
- 你的解释必须同时说出 `MockMessageTransport` 的种类、`delayNanoseconds` 的权限，以及 `init(delayNanoseconds:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 创建 MockMessageTransport 并执行确定性 send；成功后写入专属 token `target-evidence:type.MockMessageTransport`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 为什么 delayNanoseconds 不能直接赋值，应该改变哪个输入？
2. 按“谁创建、谁持有、何时释放”解释 `MockMessageTransport`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.Message -->
## type.Message · Message

### 学习目标

执行可识别的目标 workload，并解释 `Message` 为什么是 `SwiftMessengerCore.struct`：保存稳定身份、正文、时间与发送状态。

### 机制

- 直觉类比：带身份和轨迹的消息包裹。
- 类型焦点：`deliveryState: DeliveryState` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(id:conversationID:author:text:createdAt:deliveryState:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(id:conversationID:author:text:createdAt:deliveryState:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡目标：`Message`；共享 renderer：`concurrency`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.Message`

### App 操作

进入 Learn，打开 `Message Experiment`。操作前先口头预测 `Message` 的 `deliveryState` 会如何影响状态或调用。

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，按 App 中的唯一动作执行：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.Message · Message
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：创建 Message 并把它传入 transport.send；成功后写入专属 token `target-evidence:type.Message`。
- Renderer 证据：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Catalog 证据：状态与日志出现 target-evidence:type.Message，且能定位 Message 的真实调用。
- 你的解释必须同时说出 `Message` 的种类、`deliveryState` 的权限，以及 `init(id:conversationID:author:text:createdAt:deliveryState:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 创建 Message 并把它传入 transport.send；成功后写入专属 token `target-evidence:type.Message`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 deliveryState 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `Message`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: type.InboxSnapshot -->
## type.InboxSnapshot · InboxSnapshot

### 学习目标

执行可识别的目标 workload，并解释 `InboxSnapshot` 为什么是 `SwiftMessengerCore.struct`：把会话和消息组合为可编码、可恢复的业务快照。

### 机制

- 直觉类比：收件箱的存档照片。
- 类型焦点：`conversations: [Conversation]` 是 `get / set`；仅 App 白名单控件范围。
- 方法焦点：`init(conversations:messages:)`；触发方是App 白名单实验或业务调用方，建议断点名是 `init(conversations:messages:)`。
- 所有权：创建：源码中的初始化器、字面量或工厂方法；持有：当前变量或包含它的值；释放：值离开作用域或从容器移除时。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡目标：`InboxSnapshot`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:type.InboxSnapshot`

### App 操作

进入 Learn，打开 `InboxSnapshot Experiment`。操作前先口头预测 `InboxSnapshot` 的 `conversations` 会如何影响状态或调用。

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，按 App 中的唯一动作执行：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

```lldb
# type.InboxSnapshot · InboxSnapshot
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

### 预期真实证据

- Target 证据：把 InboxSnapshot 编码落盘后解码并逐值比对；成功后写入专属 token `target-evidence:type.InboxSnapshot`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：状态与日志出现 target-evidence:type.InboxSnapshot，且能定位 InboxSnapshot 的真实调用。
- 你的解释必须同时说出 `InboxSnapshot` 的种类、`conversations` 的权限，以及 `init(conversations:messages:)` 的一次可观察副作用。

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 然后重复同一动作，确认日志只描述新一轮操作；只有日志出现本卡专属 token 才能写入“已操作”证据。`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

### 误区 / 边界

- `struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 把 InboxSnapshot 编码落盘后解码并逐值比对；成功后写入专属 token `target-evidence:type.InboxSnapshot`。
- 分类结论以 `direct workload` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

### 思考题

1. 修改 conversations 后，预览和日志分别发生什么变化？
2. 按“谁创建、谁持有、何时释放”解释 `InboxSnapshot`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

<!-- experiment-card: concept.let-var -->
## concept.let-var · let / var

### 学习目标

用 shared interaction model 建立 `let / var` 的关联观察；本入口不冒充编译器级或目标运行证据：let 绑定不能重新赋值，var 绑定可以；两者都会在编译期接受类型检查。

### 机制

- 直觉类比：封条与白板。
- 技术定义：let 绑定不能重新赋值，var 绑定可以；两者都会在编译期接受类型检查。
- 最小代码：

```swift
let answer = 42
var count = 0
count += 1
```

先不要运行答案；先回答：改写 var，再把它改成 let，预测编译器反馈。

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡概念：`let-var`；共享 renderer：`valueStepper`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `let / var Related Observation`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记下 `value = 1` 与 `doubled = 2`，再把 Stepper 加 1。
2. 对照状态标签和 Live operation log，确认一次写入触发重新读取 get-only 值。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，执行 App 给出的唯一动作：在 recordOperation(_:) 设置断点，操作 Stepper 后查看 event 与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.let-var · let / var
po experiment.id
po experimentState.step
expr experimentState.step += 1
po experimentState.step
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Shared interaction model：状态从 `value = 1 / doubled = 2` 变为新值，日志出现 `set value -> didSet -> read doubled`。
- Target 边界：`valueStepper` 只是 shared interaction model；未执行 let / var 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；仍需用编译器样本或目标代码补证。
- 最终回答必须回到本卡问题：改写 var，再把它改成 let，预测编译器反馈。

### Reset / 复验

点击 `Reset Experiment`。基线应为：`value = 1`、`doubled = 2`，本卡临时状态被丢弃。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。本入口是关联观察，始终不写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“封条与白板”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 这个 Stepper 是 let/var 与类型推断的最小调试面；它不自动证明属性观察或引用身份。
- 分类结论是 `related observation`：共享 renderer 只是调试载体；它不自动等同于对 `let / var` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 改写 var，再把它改成 let，预测编译器反馈。
2. 本次哪条证据能直接支持 `let / var`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.type-inference -->
## concept.type-inference · 类型推断

### 学习目标

用 shared interaction model 建立 `类型推断` 的关联观察；本入口不冒充编译器级或目标运行证据：编译器从初始化表达式推断静态类型，之后不能随意换成另一种类型。

### 机制

- 直觉类比：根据内容自动选择标签。
- 技术定义：编译器从初始化表达式推断静态类型，之后不能随意换成另一种类型。
- 最小代码：

```swift
let whole = 1
let fraction = 1.0
```

先不要运行答案；先回答：whole 和 fraction 的静态类型分别是什么？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡概念：`type-inference`；共享 renderer：`valueStepper`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `类型推断 Related Observation`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记下 `value = 1` 与 `doubled = 2`，再把 Stepper 加 1。
2. 对照状态标签和 Live operation log，确认一次写入触发重新读取 get-only 值。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，执行 App 给出的唯一动作：在 recordOperation(_:) 设置断点，操作 Stepper 后查看 event 与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.type-inference · 类型推断
po experiment.id
po experimentState.step
expr experimentState.step += 1
po experimentState.step
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Shared interaction model：状态从 `value = 1 / doubled = 2` 变为新值，日志出现 `set value -> didSet -> read doubled`。
- Target 边界：`valueStepper` 只是 shared interaction model；未执行 类型推断 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；仍需用编译器样本或目标代码补证。
- 最终回答必须回到本卡问题：whole 和 fraction 的静态类型分别是什么？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`value = 1`、`doubled = 2`，本卡临时状态被丢弃。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。本入口是关联观察，始终不写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“根据内容自动选择标签”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 这个 Stepper 是 let/var 与类型推断的最小调试面；它不自动证明属性观察或引用身份。
- 分类结论是 `related observation`：共享 renderer 只是调试载体；它不自动等同于对 `类型推断` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. whole 和 fraction 的静态类型分别是什么？
2. 本次哪条证据能直接支持 `类型推断`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.stored-computed -->
## concept.stored-computed · 存储属性 / 计算属性

### 学习目标

把 `存储属性 / 计算属性` 变成一次可识别的目标 workload：存储属性占有状态；计算属性每次访问执行 getter，可能还有 setter。

### 机制

- 直觉类比：仓库与即时计算器。
- 技术定义：存储属性占有状态；计算属性每次访问执行 getter，可能还有 setter。
- 最小代码：

```swift
var doubled: Int { stored * 2 }
```

先不要运行答案；先回答：doubled 的值存在哪里？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `incrementPropertyProbe()`
- 本卡概念：`stored-computed`；共享 renderer：`propertyObserver`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.stored-computed`

### App 操作

进入 Learn，打开 `存储属性 / 计算属性 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记录 `PropertyBox` 的 stored、doubled、didSet 与 lazy 状态，再点击 `Increment stored`。
2. 点击 `Read lazyText` 后再次改 stored，比较 lazy 首次求值结果与最新 doubled。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `incrementPropertyProbe()`，执行 App 给出的唯一动作：在 incrementPropertyProbe() 设置断点，点击 Increment stored 后检查 didSetCount 与 doubled。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.stored-computed · 存储属性 / 计算属性
po experiment.id
po propertyBoxProbe?.stored
po propertyBoxProbe?.doubled
po propertyBoxProbe?.didSetCount
po propertyLazyWasRead
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：修改 PropertyBox.stored，并读取 computed doubled；成功后写入专属 token `target-evidence:concept.stored-computed`。
- Renderer 证据：`stored` 改变后 `doubled` 同步重算、`didSetCount` 增加；`lazyText` 只在首次读取时按当时 stored 初始化。
- Catalog 证据：日志出现 target-evidence:concept.stored-computed，并能回答：doubled 的值存在哪里？
- 最终回答必须回到本卡问题：doubled 的值存在哪里？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stored = 1`、`doubled = 2`、`didSet = 0`、`lazy = not read`。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“仓库与即时计算器”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 本 renderer 真实实例化 `PropertyBox`；它能证明本类型的 didSet/computed/lazy 行为，但不能外推所有属性观察器的初始化顺序。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `存储属性 / 计算属性` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. doubled 的值存在哪里？
2. 本次哪条证据能直接支持 `存储属性 / 计算属性`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.lazy-didset -->
## concept.lazy-didset · lazy / didSet

### 学习目标

把 `lazy / didSet` 变成一次可识别的目标 workload：lazy 延迟到首次访问初始化；didSet 在已初始化属性被写入后运行。

### 机制

- 直觉类比：首次开箱与写入监控。
- 技术定义：lazy 延迟到首次访问初始化；didSet 在已初始化属性被写入后运行。
- 最小代码：

```swift
lazy var text = makeText()
var value = 0 { didSet {} }
```

先不要运行答案；先回答：初始化过程是否触发 didSet？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `incrementPropertyProbe()`
- 本卡概念：`lazy-didset`；共享 renderer：`propertyObserver`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.lazy-didset`

### App 操作

进入 Learn，打开 `lazy / didSet Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记录 `PropertyBox` 的 stored、doubled、didSet 与 lazy 状态，再点击 `Increment stored`。
2. 点击 `Read lazyText` 后再次改 stored，比较 lazy 首次求值结果与最新 doubled。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `incrementPropertyProbe()`，执行 App 给出的唯一动作：在 incrementPropertyProbe() 设置断点，点击 Increment stored 后检查 didSetCount 与 doubled。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.lazy-didset · lazy / didSet
po experiment.id
po propertyBoxProbe?.stored
po propertyBoxProbe?.doubled
po propertyBoxProbe?.didSetCount
po propertyLazyWasRead
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：先触发 didSet，再首次读取并复验 lazyText；成功后写入专属 token `target-evidence:concept.lazy-didset`。
- Renderer 证据：`stored` 改变后 `doubled` 同步重算、`didSetCount` 增加；`lazyText` 只在首次读取时按当时 stored 初始化。
- Catalog 证据：日志出现 target-evidence:concept.lazy-didset，并能回答：初始化过程是否触发 didSet？
- 最终回答必须回到本卡问题：初始化过程是否触发 didSet？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stored = 1`、`doubled = 2`、`didSet = 0`、`lazy = not read`。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“首次开箱与写入监控”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 本 renderer 真实实例化 `PropertyBox`；它能证明本类型的 didSet/computed/lazy 行为，但不能外推所有属性观察器的初始化顺序。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `lazy / didSet` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 初始化过程是否触发 didSet？
2. 本次哪条证据能直接支持 `lazy / didSet`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.init-self-access -->
## concept.init-self-access · init / self / 访问控制

### 学习目标

把 `init / self / 访问控制` 变成一次可识别的目标 workload：init 建立合法初始值，self 指当前实例，访问级别限制名字的可见范围。

### 机制

- 直觉类比：验收表、当前对象与门禁。
- 技术定义：init 建立合法初始值，self 指当前实例，访问级别限制名字的可见范围。
- 最小代码：

```swift
public init(text: String) { self.text = text }
```

先不要运行答案；先回答：为什么所有存储属性都要在 init 结束前初始化？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyTextProbe()`
- 本卡概念：`init-self-access`；共享 renderer：`text`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.init-self-access`

### App 操作

进入 Learn，打开 `init / self / 访问控制 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 把输入改成一段能体现本卡目标的文本，再点击 `Apply Text`。
2. 对照 `count / isEmpty` 与 Live operation log，区分存储值和重新计算的结果。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyTextProbe()`，执行 App 给出的唯一动作：在 applyTextProbe() 设置断点，点击 Apply Text 后检查 MessageDraft 与 String 状态。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.init-self-access · init / self / 访问控制
po experiment.id
po experimentState.text
po messageDraftProbe?.trimmedText
po messageDraftProbe?.isSendable
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：执行 MessageDraft.init(text:) 的 self.text 初始化；成功后写入专属 token `target-evidence:concept.init-self-access`。
- Renderer 证据：状态显示 String 的 count/isEmpty 与 MessageDraft 的 trimmedText/isSendable，日志记录两组计算属性已重算。
- Catalog 证据：日志出现 target-evidence:concept.init-self-access，并能回答：为什么所有存储属性都要在 init 结束前初始化？
- 最终回答必须回到本卡问题：为什么所有存储属性都要在 init 结束前初始化？

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`；再次 Apply 才会产生新操作证据。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“验收表、当前对象与门禁”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 本 renderer 真实创建 `MessageDraft` 并使用 String API；它不会覆盖所有文本编码、grapheme cluster 或输入法边界。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `init / self / 访问控制` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 为什么所有存储属性都要在 init 结束前初始化？
2. 本次哪条证据能直接支持 `init / self / 访问控制`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.value-reference -->
## concept.value-reference · 值语义 / 引用语义

### 学习目标

把 `值语义 / 引用语义` 变成一次可识别的目标 workload：struct 赋值复制值；class 变量保存实例引用，=== 比较对象身份。

### 机制

- 直觉类比：复印件与共享白板。
- 技术定义：struct 赋值复制值；class 变量保存实例引用，=== 比较对象身份。
- 最小代码：

```swift
var b = a
let same = objectA === objectB
```

先不要运行答案；先回答：修改 b 时 a 一定变化吗？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `mutateValueReferenceProbes()`
- 本卡概念：`value-reference`；共享 renderer：`valueReference`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.value-reference`

### App 操作

进入 Learn，打开 `值语义 / 引用语义 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记录 struct original/copy 与 class original/alias 都为 1。
2. 点击 `Mutate Copy + Alias`，比较值副本和共享引用的结果，并确认 class identity 为 true。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `mutateValueReferenceProbes()`，执行 App 给出的唯一动作：在 mutateValueReferenceProbes() 设置断点，点击 Mutate 后比较 struct copy 与 class alias。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.value-reference · 值语义 / 引用语义
po experiment.id
po originalValueCounterProbe?.value
po copiedValueCounterProbe?.value
po referenceCounterProbe?.value
po referenceAliasProbe?.value
po referenceCounterProbe === referenceAliasProbe
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：对 struct copy 与 class alias 执行同一次 increment；成功后写入专属 token `target-evidence:concept.value-reference`。
- Renderer 证据：ValueCounter 显示 original=1、copy=2；ReferenceCounter 显示 original=2、alias=2 且 same class instance=true。
- Catalog 证据：日志出现 target-evidence:concept.value-reference，并能回答：修改 b 时 a 一定变化吗？
- 最终回答必须回到本卡问题：修改 b 时 a 一定变化吗？

### Reset / 复验

点击 `Reset Experiment`。基线应为：四个计数值都回到 1；struct copy 重新创建，两个 class 变量重新指向同一新实例。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“复印件与共享白板”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 这个 renderer 真实运行 `ValueCounter` 与 `ReferenceCounter`；它证明本样本的复制/共享差异，不代表带引用成员的任意 struct 都是深拷贝。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `值语义 / 引用语义` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 修改 b 时 a 一定变化吗？
2. 本次哪条证据能直接支持 `值语义 / 引用语义`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.switch-exhaustiveness -->
## concept.switch-exhaustiveness · switch 穷尽

### 学习目标

把 `switch 穷尽` 变成一次可识别的目标 workload：对 enum 的 switch 必须覆盖所有合法状态或明确使用 default。

### 机制

- 直觉类比：每个出口都有人值守。
- 技术定义：对 enum 的 switch 必须覆盖所有合法状态或明确使用 default。
- 最小代码：

```swift
switch state { case .sent: break; case .failed: break }
```

先不要运行答案；先回答：新增 enum case 后编译器如何帮助你？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `advanceDeliveryState()`
- 本卡概念：`switch-exhaustiveness`；共享 renderer：`stateMachine`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.switch-exhaustiveness`

### App 操作

进入 Learn，打开 `switch 穷尽 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 从 `sending` 开始连续点击 `Advance State`，写下每一步状态。
2. 核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `advanceDeliveryState()`，执行 App 给出的唯一动作：在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.switch-exhaustiveness · switch 穷尽
po experiment.id
po experimentState.stateIndex
po currentDeliveryState
po deliveryStateCycle
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：用穷尽 switch 处理 DeliveryState；成功后写入专属 token `target-evidence:concept.switch-exhaustiveness`。
- Renderer 证据：真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。
- Catalog 证据：日志出现 target-evidence:concept.switch-exhaustiveness，并能回答：新增 enum case 后编译器如何帮助你？
- 最终回答必须回到本卡问题：新增 enum case 后编译器如何帮助你？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`stateIndex = 0`，页面重新显示 `sending`。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“每个出口都有人值守”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `switch 穷尽` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 新增 enum case 后编译器如何帮助你？
2. 本次哪条证据能直接支持 `switch 穷尽`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.delegate-closure-arc -->
## concept.delegate-closure-arc · delegate / closure / weak / ARC

### 学习目标

把 `delegate / closure / weak / ARC` 变成一次可识别的目标 workload：回调反向通知事件；ARC 依据强引用计数释放 class，weak 用于打断不必要的强环。

### 机制

- 直觉类比：回拨号码与所有权线路。
- 技术定义：回调反向通知事件；ARC 依据强引用计数释放 class，weak 用于打断不必要的强环。
- 最小代码：

```swift
callback = { [weak self] in self?.run() }
```

先不要运行答案；先回答：闭包强捕获 self 时引用图多出哪条边？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡概念：`delegate-closure-arc`；共享 renderer：`ownership`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.delegate-closure-arc`

### App 操作

进入 Learn，打开 `delegate / closure / weak / ARC Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Create Owner + Weak Callback`，确认 strong owner 与 weak probe 同时存活。
2. 点击 `Release Strong Owner`，观察 weak probe 是否变为 nil，并核对两条日志顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，执行 App 给出的唯一动作：在 recordOperation(_:) 设置断点，释放 owner 后观察 weak 引用与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.delegate-closure-arc · delegate / closure / weak / ARC
po experiment.id
po ownershipProbe
po weakOwnershipProbe
expr ownershipProbe = nil
po weakOwnershipProbe
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：触发 weak closure，再释放 owner 观察 weak 归零；成功后写入专属 token `target-evidence:concept.delegate-closure-arc`。
- Renderer 证据：创建后 `weak alive = true`；解除最后一个强引用后 `weak nil = true`，日志记录 ARC 边变化。
- Catalog 证据：日志出现 target-evidence:concept.delegate-closure-arc，并能回答：闭包强捕获 self 时引用图多出哪条边？
- 最终回答必须回到本卡问题：闭包强捕获 self 时引用图多出哪条边？

### Reset / 复验

点击 `Reset Experiment`。基线应为：临时 owner、weak probe 与 callback 都被清空，状态回到 `owner = nil · weak = nil`。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“回拨号码与所有权线路”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- weak 归零只能证明这个 probe 没有剩余强引用；不能据此断言任意业务闭包都不存在 retain cycle。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `delegate / closure / weak / ARC` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 闭包强捕获 self 时引用图多出哪条边？
2. 本次哪条证据能直接支持 `delegate / closure / weak / ARC`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.codable -->
## concept.codable · Codable

### 学习目标

把 `Codable` 变成一次可识别的目标 workload：Codable 是 Encodable 与 Decodable 的组合，用于值与外部表示之间的双向转换。

### 机制

- 直觉类比：统一格式的运单。
- 技术定义：Codable 是 Encodable 与 Decodable 的组合，用于值与外部表示之间的双向转换。
- 最小代码：

```swift
let data = try JSONEncoder().encode(value)
```

先不要运行答案；先回答：Data 和业务 struct 分别位于边界哪一侧？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `runFoundationRoundTrip()`
- 本卡概念：`codable`；共享 renderer：`foundation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.codable`

### App 操作

进入 Learn，打开 `Codable Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。
2. 记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `runFoundationRoundTrip()`，执行 App 给出的唯一动作：在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.codable · Codable
po experiment.id
po foundationProbe?.fileURL.path
po foundationProbe?.fixtureExists
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：用 JSONEncoder/JSONDecoder round-trip Codable InboxSnapshot；成功后写入专属 token `target-evidence:concept.codable`。
- Renderer 证据：状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。
- Catalog 证据：日志出现 target-evidence:concept.codable，并能回答：Data 和业务 struct 分别位于边界哪一侧？
- 最终回答必须回到本卡问题：Data 和业务 struct 分别位于边界哪一侧？

### Reset / 复验

点击 `Reset Experiment`。基线应为：实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“统一格式的运单”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `Codable` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. Data 和业务 struct 分别位于边界哪一侧？
2. 本次哪条证据能直接支持 `Codable`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.async-await-throws -->
## concept.async-await-throws · async / await / throws

### 学习目标

把 `async / await / throws` 变成一次可识别的目标 workload：await 标出异步暂停点，throws 沿调用链传播失败，Task 承载异步工作。

### 机制

- 直觉类比：可暂停且可能失败的取件单。
- 技术定义：await 标出异步暂停点，throws 沿调用链传播失败，Task 承载异步工作。
- 最小代码：

```swift
let receipt = try await transport.send(message)
```

先不要运行答案；先回答：暂停是否等于阻塞当前线程？

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡概念：`async-await-throws`；共享 renderer：`concurrency`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.async-await-throws`

### App 操作

进入 Learn，打开 `async / await / throws Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，执行 App 给出的唯一动作：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.async-await-throws · async / await / throws
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：在可取消 Task 中 try await MessageTransport.send；成功后写入专属 token `target-evidence:concept.async-await-throws`。
- Renderer 证据：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Catalog 证据：日志出现 target-evidence:concept.async-await-throws，并能回答：暂停是否等于阻塞当前线程？
- 最终回答必须回到本卡问题：暂停是否等于阻塞当前线程？

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“可暂停且可能失败的取件单”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `async / await / throws` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 暂停是否等于阻塞当前线程？
2. 本次哪条证据能直接支持 `async / await / throws`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.responder-scene-chain -->
## concept.responder-scene-chain · Responder 与 Scene 链

### 学习目标

用 shared interaction model 建立 `Responder 与 Scene 链` 的关联观察；本入口不冒充编译器级或目标运行证据：应用进程可拥有多个 scene，每个 window 把自己的控制器树接到系统。

### 机制

- 直觉类比：事件接力与独立舞台。
- 技术定义：应用进程可拥有多个 scene，每个 window 把自己的控制器树接到系统。
- 最小代码：

```swift
UIApplication → UIScene → UIWindow → UIViewController
```

先不要运行答案；先回答：多窗口时为何不能只保存一个全局 window？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡概念：`responder-scene-chain`；共享 renderer：`navigation`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `Responder 与 Scene 链 Related Observation`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，执行 App 给出的唯一动作：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.responder-scene-chain · Responder 与 Scene 链
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Shared interaction model：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Target 边界：`navigation` 只是 shared interaction model；未执行 Responder 与 Scene 链 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；仍需用编译器样本或目标代码补证。
- 最终回答必须回到本卡问题：多窗口时为何不能只保存一个全局 window？

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。本入口是关联观察，始终不写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“事件接力与独立舞台”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- 分类结论是 `related observation`：共享 renderer 只是调试载体；它不自动等同于对 `Responder 与 Scene 链` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 多窗口时为何不能只保存一个全局 window？
2. 本次哪条证据能直接支持 `Responder 与 Scene 链`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.auto-layout -->
## concept.auto-layout · Auto Layout

### 学习目标

把 `Auto Layout` 变成一次可识别的目标 workload：约束描述视图属性之间的关系，布局引擎按优先级求出 frame。

### 机制

- 直觉类比：联立布局方程。
- 技术定义：约束描述视图属性之间的关系，布局引擎按优先级求出 frame。
- 最小代码：

```swift
view.widthAnchor.constraint(equalToConstant: 120)
```

先不要运行答案；先回答：创建 constraint 与激活 constraint 有什么区别？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyViewState()`
- 本卡概念：`auto-layout`；共享 renderer：`viewAppearance`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.auto-layout`

### App 操作

进入 Learn，打开 `Auto Layout Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。
2. 暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyViewState()`，执行 App 给出的唯一动作：运行实验后使用 Debug View Hierarchy 定位 experiment-preview。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.auto-layout · Auto Layout
po experiment.id
po experimentState.alpha
expr experimentState.alpha = 0.35
expr experimentState.isHidden = true
po experimentState
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：用 anchors 创建并激活 preview 约束；成功后写入专属 token `target-evidence:concept.auto-layout`。
- Renderer 证据：预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。
- Catalog 证据：日志出现 target-evidence:concept.auto-layout，并能回答：创建 constraint 与激活 constraint 有什么区别？
- 最终回答必须回到本卡问题：创建 constraint 与激活 constraint 有什么区别？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“联立布局方程”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `Auto Layout` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 创建 constraint 与激活 constraint 有什么区别？
2. 本次哪条证据能直接支持 `Auto Layout`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.view-controller-lifecycle -->
## concept.view-controller-lifecycle · 控制器生命周期

### 学习目标

把 `控制器生命周期` 变成一次可识别的目标 workload：控制器创建、加载 view、出现与消失是不同阶段，push/pop 决定实例何时离开栈。

### 机制

- 直觉类比：导演进场和退场。
- 技术定义：控制器创建、加载 view、出现与消失是不同阶段，push/pop 决定实例何时离开栈。
- 最小代码：

```swift
viewDidLoad → viewWillAppear → viewDidAppear
```

先不要运行答案；先回答：返回旧页面通常会再次调用 viewDidLoad 吗？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `recordOperation(_:)`
- 本卡概念：`view-controller-lifecycle`；共享 renderer：`navigation`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.view-controller-lifecycle`

### App 操作

进入 Learn，打开 `控制器生命周期 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。
2. 返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `recordOperation(_:)`，执行 App 给出的唯一动作：在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.view-controller-lifecycle · 控制器生命周期
po experiment.id
po navigationController?.viewControllers
bt
po lastProbeIdentifier
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：push/pop probe 并记录 viewDidLoad、appear、disappear 与 deinit；成功后写入专属 token `target-evidence:concept.view-controller-lifecycle`。
- Renderer 证据：probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。
- Catalog 证据：日志出现 target-evidence:concept.view-controller-lifecycle，并能回答：返回旧页面通常会再次调用 viewDidLoad 吗？
- 最终回答必须回到本卡问题：返回旧页面通常会再次调用 viewDidLoad 吗？

### Reset / 复验

点击 `Reset Experiment`。基线应为：last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“导演进场和退场”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `控制器生命周期` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 返回旧页面通常会再次调用 viewDidLoad 吗？
2. 本次哪条证据能直接支持 `控制器生命周期`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.target-action -->
## concept.target-action · target-action

### 学习目标

把 `target-action` 变成一次可识别的目标 workload：UIControl 在指定事件发生时把 action 发送给目标。

### 机制

- 直觉类比：控件发出的事件通知。
- 技术定义：UIControl 在指定事件发生时把 action 发送给目标。
- 最小代码：

```swift
button.addTarget(self, action: #selector(tap), for: .touchUpInside)
```

先不要运行答案；先回答：isEnabled=false 时 action 是否触发？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `actionButtonTapped()`
- 本卡概念：`target-action`；共享 renderer：`button`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.target-action`

### App 操作

进入 Learn，打开 `target-action Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Send Action`，确认 action count 增加；再关闭 `isEnabled`。
2. 在禁用状态尝试点击，比较 action count 与日志是否保持不变。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `actionButtonTapped()`，执行 App 给出的唯一动作：在 actionButtonTapped() 设置断点，点击 Send Action 后查看调用来源。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.target-action · target-action
po experiment.id
po experimentState.isEnabled
po experimentState.taps
expr experimentState.isEnabled = false
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：发送 touchUpInside 并验证禁用 UIControl 不触发 action；成功后写入专属 token `target-evidence:concept.target-action`。
- Renderer 证据：启用时日志出现 `touchUpInside action fired` 且 count 增加；禁用后不发送 action。
- Catalog 证据：日志出现 target-evidence:concept.target-action，并能回答：isEnabled=false 时 action 是否触发？
- 最终回答必须回到本卡问题：isEnabled=false 时 action 是否触发？

### Reset / 复验

点击 `Reset Experiment`。基线应为：`isEnabled = true`、`action count = 0`。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“控件发出的事件通知”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 直接在 LLDB 改 model 字段不会自动刷新 UIButton；真实 UI 还需经过 renderer 把状态写回控件。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `target-action` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. isEnabled=false 时 action 是否触发？
2. 本次哪条证据能直接支持 `target-action`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.first-responder -->
## concept.first-responder · 第一响应者

### 学习目标

把 `第一响应者` 变成一次可识别的目标 workload：同一窗口中由 first responder 接收键盘输入，可主动申请或辞去。

### 机制

- 直觉类比：当前接收键盘的人。
- 技术定义：同一窗口中由 first responder 接收键盘输入，可主动申请或辞去。
- 最小代码：

```swift
field.becomeFirstResponder()
```

先不要运行答案；先回答：delegate 和 editingChanged 谁先收到一次字符变化？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `textFieldShouldReturn(_:)`
- 本卡概念：`first-responder`；共享 renderer：`textInput`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.first-responder`

### App 操作

进入 Learn，打开 `第一响应者 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Become First Responder`，输入一个字符，再按 Return。
2. 按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `textFieldShouldReturn(_:)`，执行 App 给出的唯一动作：在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.first-responder · 第一响应者
po experiment.id
po inputField?.isFirstResponder
po experimentState.text
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：执行 become/resignFirstResponder 并记录 delegate 顺序；成功后写入专属 token `target-evidence:concept.first-responder`。
- Renderer 证据：日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。
- Catalog 证据：日志出现 target-evidence:concept.first-responder，并能回答：delegate 和 editingChanged 谁先收到一次字符变化？
- 最终回答必须回到本卡问题：delegate 和 editingChanged 谁先收到一次字符变化？

### Reset / 复验

点击 `Reset Experiment`。基线应为：文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“当前接收键盘的人”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `第一响应者` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. delegate 和 editingChanged 谁先收到一次字符变化？
2. 本次哪条证据能直接支持 `第一响应者`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.reuse -->
## concept.reuse · 复用与可见区域

### 学习目标

把 `复用与可见区域` 变成一次可识别的目标 workload：列表只为可见区域维护 cell；cell 身份不等于业务 item 身份。

### 机制

- 直觉类比：循环使用少量展示卡。
- 技术定义：列表只为可见区域维护 cell；cell 身份不等于业务 item 身份。
- 最小代码：

```swift
dequeueConfiguredReusableCell(...)
```

先不要运行答案；先回答：为什么不能把状态只存在 cell 中？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡概念：`reuse`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.reuse`

### App 操作

进入 Learn，打开 `复用与可见区域 Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，执行 App 给出的唯一动作：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.reuse · 复用与可见区域
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：注册并 dequeue 可复用 collection cell；成功后写入专属 token `target-evidence:concept.reuse`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：日志出现 target-evidence:concept.reuse，并能回答：为什么不能把状态只存在 cell 中？
- 最终回答必须回到本卡问题：为什么不能把状态只存在 cell 中？

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“循环使用少量展示卡”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `复用与可见区域` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 为什么不能把状态只存在 cell 中？
2. 本次哪条证据能直接支持 `复用与可见区域`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.stable-identity -->
## concept.stable-identity · 稳定 identity

### 学习目标

把 `稳定 identity` 变成一次可识别的目标 workload：diffable data source 使用稳定且唯一的 Hashable id 计算插入、删除与移动。

### 机制

- 直觉类比：货物身份证而非货架位置。
- 技术定义：diffable data source 使用稳定且唯一的 Hashable id 计算插入、删除与移动。
- 最小代码：

```swift
snapshot.appendItems(messageIDs)
```

先不要运行答案；先回答：刷新时重新生成 UUID 会发生什么？

### 真实源码锚点

- File: [SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift](../SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift)
- Symbol: `applyCollectionSnapshot()`
- 本卡概念：`stable-identity`；共享 renderer：`collection`。
- 证据分类：`direct workload`
- Evidence token：`target-evidence:concept.stable-identity`

### App 操作

进入 Learn，打开 `稳定 identity Experiment`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。
2. 点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `applyCollectionSnapshot()`，执行 App 给出的唯一动作：在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.stable-identity · 稳定 identity
po experiment.id
po experimentState.itemIDs
expr experimentState.itemIDs.reverse()
po Set(experimentState.itemIDs).count
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Target 证据：用固定 UUID 更新 diffable snapshot 并检查唯一性；成功后写入专属 token `target-evidence:concept.stable-identity`。
- Renderer 证据：刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。
- Catalog 证据：日志出现 target-evidence:concept.stable-identity，并能回答：刷新时重新生成 UUID 会发生什么？
- 最终回答必须回到本卡问题：刷新时重新生成 UUID 会发生什么？

### Reset / 复验

点击 `Reset Experiment`。基线应为：恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。只有日志出现本卡专属 token 才能写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“货物身份证而非货架位置”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。
- 分类结论是 `direct workload`：共享 renderer 只是调试载体；它不自动等同于对 `稳定 identity` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 刷新时重新生成 UUID 会发生什么？
2. 本次哪条证据能直接支持 `稳定 identity`，哪条只是共享 renderer 的现象，为什么？

<!-- experiment-card: concept.dependency-injection -->
## concept.dependency-injection · 依赖注入

### 学习目标

用 shared interaction model 建立 `依赖注入` 的关联观察；本入口不冒充编译器级或目标运行证据：调用者依赖协议，由组合根提供具体 Repository、Transport 和 Cache。

### 机制

- 直觉类比：从配电箱接入实现。
- 技术定义：调用者依赖协议，由组合根提供具体 Repository、Transport 和 Cache。
- 最小代码：

```swift
DeliveryCoordinator(repository: repo, transport: mock)
```

先不要运行答案；先回答：为什么测试不应创建真实网络 transport？

### 真实源码锚点

- File: [SwiftMessengerLab/Core/MessageTransport.swift](../SwiftMessengerLab/Core/MessageTransport.swift)
- Symbol: `send(_:isRetry:)`
- 本卡概念：`dependency-injection`；共享 renderer：`concurrency`。
- 证据分类：`related observation`
- Evidence token：无（关联观察不写入“已操作”证据）

### App 操作

进入 Learn，打开 `依赖注入 Related Observation`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

1. 点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。
2. 等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。

### Xcode / LLDB 操作

1. 用 `⌘⇧O` 打开 `send(_:isRetry:)`，执行 App 给出的唯一动作：在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。
2. 在断点暂停处先读 Call Stack，再逐行执行：

```lldb
# concept.dependency-injection · 依赖注入
po message.id
po message.deliveryState
po isRetry
thread list
bt
```

3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

### 预期真实证据

- Shared interaction model：状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。
- Target 边界：`concurrency` 只是 shared interaction model；未执行 依赖注入 的专属 workload，不写入“已操作”证据。
- Catalog 证据：只记录 shared interaction model；仍需用编译器样本或目标代码补证。
- 最终回答必须回到本卡问题：为什么测试不应创建真实网络 transport？

### Reset / 复验

点击 `Reset Experiment`。基线应为：正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。本入口是关联观察，始终不写入“已操作”证据。学习进度 Reset 与 Messenger cache 仍是独立边界。

### 误区 / 边界

- 类比“从配电箱接入实现”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
- 调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。
- 分类结论是 `related observation`：共享 renderer 只是调试载体；它不自动等同于对 `依赖注入` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

### 思考题

1. 为什么测试不应创建真实网络 transport？
2. 本次哪条证据能直接支持 `依赖注入`，哪条只是共享 renderer 的现象，为什么？

