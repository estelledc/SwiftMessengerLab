import Foundation
import SwiftMessengerCore

#if canImport(Darwin)
  import Darwin
#elseif canImport(Glibc)
  import Glibc
#endif

private let defaultOutput = "docs/experiment-cards.md"

private struct RendererGuide {
  let appSteps: [String]
  let lldbCommands: [String]
  let evidence: String
  let resetBaseline: String
  let boundary: String
}

private func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("experiment card export failed: \(message)\n".utf8))
  exit(EXIT_FAILURE)
}

private func removeGeneratedIndent(_ value: String) -> String {
  value.split(separator: "\n", omittingEmptySubsequences: false)
    .map { line in
      line.hasPrefix("  ") ? String(line.dropFirst(2)) : String(line)
    }
    .joined(separator: "\n")
}

private func rendererGuide(for control: ExperimentControl) -> RendererGuide {
  switch control {
  case .valueStepper:
    return RendererGuide(
      appSteps: [
        "先记下 `value = 1` 与 `doubled = 2`，再把 Stepper 加 1。",
        "对照状态标签和 Live operation log，确认一次写入触发重新读取 get-only 值。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.step",
        "expr experimentState.step += 1",
        "po experimentState.step",
      ],
      evidence: "状态从 `value = 1 / doubled = 2` 变为新值，日志出现 `set value -> didSet -> read doubled`。",
      resetBaseline: "`value = 1`、`doubled = 2`，本卡临时状态被丢弃。",
      boundary: "这个 Stepper 是 let/var 与类型推断的最小调试面；它不自动证明属性观察或引用身份。"
    )
  case .propertyObserver:
    return RendererGuide(
      appSteps: [
        "先记录 `PropertyBox` 的 stored、doubled、didSet 与 lazy 状态，再点击 `Increment stored`。",
        "点击 `Read lazyText` 后再次改 stored，比较 lazy 首次求值结果与最新 doubled。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po propertyBoxProbe?.stored",
        "po propertyBoxProbe?.doubled",
        "po propertyBoxProbe?.didSetCount",
        "po propertyLazyWasRead",
        "bt",
      ],
      evidence:
        "`stored` 改变后 `doubled` 同步重算、`didSetCount` 增加；`lazyText` 只在首次读取时按当时 stored 初始化。",
      resetBaseline: "`stored = 1`、`doubled = 2`、`didSet = 0`、`lazy = not read`。",
      boundary:
        "本 renderer 真实实例化 `PropertyBox`；它能证明本类型的 didSet/computed/lazy 行为，但不能外推所有属性观察器的初始化顺序。"
    )
  case .valueReference:
    return RendererGuide(
      appSteps: [
        "先记录 struct original/copy 与 class original/alias 都为 1。",
        "点击 `Mutate Copy + Alias`，比较值副本和共享引用的结果，并确认 class identity 为 true。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po originalValueCounterProbe?.value",
        "po copiedValueCounterProbe?.value",
        "po referenceCounterProbe?.value",
        "po referenceAliasProbe?.value",
        "po referenceCounterProbe === referenceAliasProbe",
        "bt",
      ],
      evidence:
        "ValueCounter 显示 original=1、copy=2；ReferenceCounter 显示 original=2、alias=2 且 same class instance=true。",
      resetBaseline: "四个计数值都回到 1；struct copy 重新创建，两个 class 变量重新指向同一新实例。",
      boundary:
        "这个 renderer 真实运行 `ValueCounter` 与 `ReferenceCounter`；它证明本样本的复制/共享差异，不代表带引用成员的任意 struct 都是深拷贝。"
    )
  case .text:
    return RendererGuide(
      appSteps: [
        "把输入改成一段能体现本卡目标的文本，再点击 `Apply Text`。",
        "对照 `count / isEmpty` 与 Live operation log，区分存储值和重新计算的结果。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.text",
        "po messageDraftProbe?.trimmedText",
        "po messageDraftProbe?.isSendable",
        "bt",
      ],
      evidence:
        "状态显示 String 的 count/isEmpty 与 MessageDraft 的 trimmedText/isSendable，日志记录两组计算属性已重算。",
      resetBaseline: "文本恢复为 `Hello, Swift`；再次 Apply 才会产生新操作证据。",
      boundary: "本 renderer 真实创建 `MessageDraft` 并使用 String API；它不会覆盖所有文本编码、grapheme cluster 或输入法边界。"
    )
  case .ownership:
    return RendererGuide(
      appSteps: [
        "点击 `Create Owner + Weak Callback`，确认 strong owner 与 weak probe 同时存活。",
        "点击 `Release Strong Owner`，观察 weak probe 是否变为 nil，并核对两条日志顺序。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po ownershipProbe",
        "po weakOwnershipProbe",
        "expr ownershipProbe = nil",
        "po weakOwnershipProbe",
      ],
      evidence: "创建后 `weak alive = true`；解除最后一个强引用后 `weak nil = true`，日志记录 ARC 边变化。",
      resetBaseline: "临时 owner、weak probe 与 callback 都被清空，状态回到 `owner = nil · weak = nil`。",
      boundary: "weak 归零只能证明这个 probe 没有剩余强引用；不能据此断言任意业务闭包都不存在 retain cycle。"
    )
  case .foundation:
    return RendererGuide(
      appSteps: [
        "点击 `Save + Load JSON Snapshot`，让 App 真实创建临时目录、编码、原子写入并解码。",
        "记录文件名、bytes 与 messages 数，再在源码中分别定位 URL、Data、FileManager 和 cache 调用。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po foundationProbe?.fileURL.path",
        "po foundationProbe?.fixtureExists",
        "bt",
      ],
      evidence:
        "状态出现 `inbox.json`、非零 bytes 和恢复后的 messages 数，日志显示 Foundation save + load succeeded。",
      resetBaseline: "实验状态恢复；当前 probe 持有的临时目录与 inbox.json 已从磁盘删除。",
      boundary: "一次 round trip 证明本样本可编码与恢复，不代表所有 schema 演进、磁盘错误或并发写入都已覆盖。"
    )
  case .concurrency:
    return RendererGuide(
      appSteps: [
        "点击 `Run Async Transport`，先观察 `idle -> sending`，期间继续滚动页面确认主线程可响应。",
        "等待确定性 transport 完成，记录 sent 状态、server id 和恢复到 MainActor 的日志。",
      ],
      lldbCommands: [
        "po message.id",
        "po message.deliveryState",
        "po isRetry",
        "thread list",
        "bt",
      ],
      evidence: "状态从 `idle` 经过 `sending` 到 `sent`，日志依次出现 Task started 与 resumed on MainActor。",
      resetBaseline: "正在运行的 Task 会先 cancel，状态回到 `idle`；旧任务不得在 Reset 后覆盖新页面。",
      boundary: "调试器中的当前线程只是某个暂停瞬间；`await` 是暂停任务，不等于一直占用或阻塞同一线程。"
    )
  case .navigation:
    return RendererGuide(
      appSteps: [
        "点击 `Push Probe Page`，记下 probe 的 ObjectIdentifier 与 push 前栈深。",
        "返回原实验页，核对 `viewDidLoad / viewWillAppear / viewDidDisappear / deinit` 与同一实例 id。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po navigationController?.viewControllers",
        "bt",
        "po lastProbeIdentifier",
      ],
      evidence: "probe 页面只首次触发 `viewDidLoad`；push/pop 的栈深、对象 id 与生命周期日志可以互相对应。",
      resetBaseline: "last probe id 被清空，当前实验保留在导航栈；已 pop 的 probe 应已执行 deinit。",
      boundary: "生命周期回调顺序受展示方式和容器影响；本卡只证明当前 UINavigationController push/pop 链。"
    )
  case .viewAppearance:
    return RendererGuide(
      appSteps: [
        "依次改变 `alpha`、颜色与 `isHidden`，每次只改一个输入并记录状态。",
        "暂停 App 后打开 Debug View Hierarchy，搜索 `experiment-preview` 并检查层级与几何。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.alpha",
        "expr experimentState.alpha = 0.35",
        "expr experimentState.isHidden = true",
        "po experimentState",
      ],
      evidence: "预览、状态文本与日志同步变化；View Debugger 中能定位 canvas 下的 preview 节点。",
      resetBaseline: "`alpha = 1`、蓝色、`isHidden = false`，preview 回到初始外观。",
      boundary: "Debug View Hierarchy 展示暂停时刻的视图树；它不能单独解释约束为何产生该 frame，仍要回到约束源码。"
    )
  case .button:
    return RendererGuide(
      appSteps: [
        "点击 `Send Action`，确认 action count 增加；再关闭 `isEnabled`。",
        "在禁用状态尝试点击，比较 action count 与日志是否保持不变。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.isEnabled",
        "po experimentState.taps",
        "expr experimentState.isEnabled = false",
        "bt",
      ],
      evidence: "启用时日志出现 `touchUpInside action fired` 且 count 增加；禁用后不发送 action。",
      resetBaseline: "`isEnabled = true`、`action count = 0`。",
      boundary: "直接在 LLDB 改 model 字段不会自动刷新 UIButton；真实 UI 还需经过 renderer 把状态写回控件。"
    )
  case .textInput:
    return RendererGuide(
      appSteps: [
        "点击 `Become First Responder`，输入一个字符，再按 Return。",
        "按日志编号核对 delegate shouldChange、editingChanged、shouldReturn 与 resign 的顺序。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po inputField?.isFirstResponder",
        "po experimentState.text",
        "bt",
      ],
      evidence:
        "日志按 `1 -> 2 -> 3 -> 4` 展示 delegate、control event 与 resign；键盘焦点随 first responder 改变。",
      resetBaseline: "文本恢复为 `Hello, Swift`，输入框重新创建且不再是第一响应者。",
      boundary: "当前顺序来自这个 UITextField 配置；输入法组合文本、粘贴和 UITextView 可能走不同细节。"
    )
  case .collection:
    return RendererGuide(
      appSteps: [
        "先记录 3 个 item 的 UUID，再点 `Refresh Same IDs` 反转顺序。",
        "点 `Add Unique Item`，确认 item count 与 unique id count 同时只增加 1。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.itemIDs",
        "expr experimentState.itemIDs.reverse()",
        "po Set(experimentState.itemIDs).count",
        "bt",
      ],
      evidence: "刷新只改变顺序而不改变 UUID 集合；新增后 `items == unique ids`，日志区分 refresh 与 append。",
      resetBaseline: "恢复固定的 3 个 UUID 与初始顺序，diffable snapshot 重新应用。",
      boundary: "cell 是可复用视图，不是业务 identity；本卡的 UUID 才是 snapshot 计算差异的稳定标识。"
    )
  case .dictionary:
    return RendererGuide(
      appSteps: [
        "点击 `Run Key/Value Workload`，执行 updateValue、default subscript、merge 与 removeValue。",
        "核对 queued 的旧值/删除值、sent/failed 计数和最终排序 keys。",
      ],
      lldbCommands: [
        "po experiment.id",
        "next",
        "po result.previousQueuedCount",
        "po result.removedQueuedCount",
        "po result.sortedKeys",
        "bt",
      ],
      evidence:
        "状态显示 queued 从 1 更新为 2 后被删除，sent=2、failed=1、最终 keys 为 failed/sent。",
      resetBaseline: "状态回到 `Dictionary workload has not run.`；下一次操作从新的字典开始。",
      boundary: "这是独立 `[String: Int]` workload，不借用 `[UUID]` collection renderer 冒充 Dictionary。"
    )
  case .repository:
    return RendererGuide(
      appSteps: [
        "点击 `Enqueue Outgoing Message`，让真实 MessageRepository 调用 enqueueOutgoing。",
        "核对 messages 只增加 1、新消息为 queued，且 Design 会话 preview 等于新文本。",
      ],
      lldbCommands: [
        "po text",
        "po conversationID",
        "po self.snapshotValue.messages.count",
        "bt",
      ],
      evidence:
        "状态显示 messages N -> N+1、queued message id 与更新后的 preview；断点命中 enqueueOutgoing。",
      resetBaseline: "重新创建只含 SampleInbox.snapshot 的 MessageRepository，临时 outgoing message 消失。",
      boundary: "该 workload 只证明 Repository 内存 append 与 preview 更新；网络发送由 MessageTransport 卡验证。"
    )
  case .stateMachine:
    return RendererGuide(
      appSteps: [
        "从 `sending` 开始连续点击 `Advance State`，写下每一步状态。",
        "核对 switch 日志是否覆盖 `sent / failed / sending` 的循环。",
      ],
      lldbCommands: [
        "po experiment.id",
        "po experimentState.stateIndex",
        "po currentDeliveryState",
        "po deliveryStateCycle",
        "bt",
      ],
      evidence:
        "真实 `DeliveryState` 按 `sending -> sent -> failed -> sending` 变化，每步都有对应的 switch handled 日志。",
      resetBaseline: "`stateIndex = 0`，页面重新显示 `sending`。",
      boundary:
        "这个 probe 使用真实 `DeliveryState`，但只覆盖三态循环；queued/received、非法迁移和网络竞态仍需在 Repository/Coordinator 链验证。"
    )
  }
}

private func typeCard(
  metadata: TypeMetadata,
  experiment: LearningExperiment
) -> String {
  let guide = rendererGuide(for: experiment.control)
  let property = metadata.properties.first
  let method = metadata.methods.first!
  let propertyFocus: String
  let propertyQuestion: String

  if let property {
    propertyFocus =
      "`\(property.name): \(property.type)` 是 `\(property.access.rawValue)`；\(property.mutableRange)。"
    propertyQuestion = property.observationQuestion
  } else {
    propertyFocus = "本卡没有精选属性，观察重点转向方法 `\(method.signature)` 的输入、输出与副作用。"
    propertyQuestion = "`\(method.signature)` 的输入、输出与可观察副作用分别是什么？"
  }

  let source = experiment.console.sourceCue
  let appSteps = guide.appSteps.enumerated()
    .map { "\($0.offset + 1). \($0.element)" }
    .joined(separator: "\n")
  let commands = guide.lldbCommands.joined(separator: "\n")
  let ownership = "创建：\(metadata.createdBy)；持有：\(metadata.ownedBy)；释放：\(metadata.releasedWhen)。"
  let isDirect = experiment.evidenceKind == .directWorkload
  let evidenceClassification = isDirect ? "direct workload" : "related observation"
  let evidenceToken = experiment.evidenceToken.map { "`\($0)`" }
    ?? "无（关联观察不写入“已操作”证据）"
  let learningGoal = isDirect
    ? "执行可识别的目标 workload，并解释 `\(metadata.name)` 为什么是 `\(metadata.module).\(metadata.kind.rawValue)`：\(metadata.purpose)"
    : "借 shared interaction model 观察与 `\(metadata.name)` 相邻的机制，并明确它不构成目标运行证据：\(metadata.purpose)"
  let runtimeEvidence = isDirect
    ? "- Target 证据：\(experiment.targetEvidence)\n- Renderer 证据：\(guide.evidence)"
    : "- Shared interaction model：\(guide.evidence)\n- Target 边界：\(experiment.targetEvidence)"
  let progressBoundary = isDirect
    ? "只有日志出现本卡专属 token 才能写入“已操作”证据。"
    : "本入口是关联观察，始终不写入“已操作”证据。"
  let kindBoundary: String
  let typeSpecificBoundary: String

  switch metadata.kind {
  case .class:
    kindBoundary = "`class` 变量保存引用；看到两个变量值相同，不等于它们是同一实例，必要时用对象身份与 Memory Graph 证明。"
  case .struct:
    kindBoundary = "`struct` 默认是值语义；仍要区分本卡实际复制了目标值，还是只借共享 renderer 观察了相邻机制。"
  case .enum:
    kindBoundary = "`enum` 的价值是有限状态与关联值；UI 的 stateIndex 只是选择索引，证据还必须落到实际 enum case。"
  case .protocol:
    kindBoundary = "`protocol` 描述能力契约，不是可直接实例化的实现；还要找到具体 conformer 与调用方。"
  }

  switch metadata.id {
  case "PropertyBox":
    typeSpecificBoundary =
      "本卡真实实例化 `PropertyBox`，可以直接验证 stored、doubled、didSetCount 与 lazyText；仍不能把结果外推到任意属性观察器。"
  case "ValueCounter":
    typeSpecificBoundary =
      "本卡真实复制 `ValueCounter` 并只修改 copy，因此 original=1/copy=2 是这个 struct 的直接运行证据。"
  case "ReferenceCounter":
    typeSpecificBoundary =
      "本卡让 original 与 alias 指向同一 `ReferenceCounter`，`=== true` 与同步变值是引用共享的直接运行证据。"
  case "MessageDraft":
    typeSpecificBoundary =
      "本卡真实创建 `MessageDraft`，可以直接验证 trimmedText 与 isSendable；不覆盖完整 composer 或发送业务。"
  case "String":
    typeSpecificBoundary =
      "MessageDraft 的 text 确实是 String，本卡直接调用 count/isEmpty/trim；不覆盖 Unicode 的全部 grapheme cluster 边界。"
  case "DeliveryState":
    typeSpecificBoundary =
      "本卡的循环元素就是 `DeliveryState`，可直接验证 sending/sent/failed；queued/received 与业务迁移仍在 Repository 链验证。"
  case "Dictionary":
    typeSpecificBoundary =
      "本卡运行独立 `[String: Int]` workload，直接覆盖 update/default/merge/remove；collection 的 `[UUID]` 不再充当 Dictionary 证据。"
  case "MessageRepository":
    typeSpecificBoundary =
      "本卡真实创建 MessageRepository 并命中 enqueueOutgoing；只验证内存 append、queued 与 preview，不冒充 transport 发送证据。"
  case "MessageTransport":
    typeSpecificBoundary =
      "本卡把 MockMessageTransport 装入 `any MessageTransport` existential，再通过协议调用 send；具体网络实现仍不在项目范围内。"
  case "Array":
    typeSpecificBoundary =
      "`experimentState.itemIDs` 确实是 `[UUID]`，可证明顺序与 append；它仍不覆盖 Array 的全部泛型、索引和 copy-on-write 行为。"
  case "Set":
    typeSpecificBoundary =
      "`Set(experimentState.itemIDs)` 只用于计算唯一数；可证明去重结果，不等于验证所有 Set 成员操作与哈希边界。"
  default:
    typeSpecificBoundary = isDirect
      ? experiment.targetEvidence
      : "renderer 没有执行 `\(metadata.name)` 专属 workload；本次状态变化只能作为关联观察。"
  }

  return """
    <!-- experiment-card: \(experiment.id) -->
    ## \(experiment.id) · \(metadata.name)

    ### 学习目标

    \(learningGoal)

    ### 机制

    - 直觉类比：\(metadata.analogy)。
    - 类型焦点：\(propertyFocus)
    - 方法焦点：`\(method.signature)`；触发方是\(method.triggeredBy)，建议断点名是 `\(method.recommendedBreakpoint)`。
    - 所有权：\(ownership)

    ### 真实源码锚点

    - File: [\(source.file)](../\(source.file))
    - Symbol: `\(source.symbol)`
    - 本卡目标：`\(metadata.name)`；共享 renderer：`\(experiment.control.rawValue)`。
    - 证据分类：`\(evidenceClassification)`
    - Evidence token：\(evidenceToken)

    ### App 操作

    进入 Learn，打开 `\(experiment.title)`。操作前先口头预测 `\(metadata.name)` 的 `\(property?.name ?? method.signature)` 会如何影响状态或调用。

    \(appSteps)

    ### Xcode / LLDB 操作

    1. 用 `⌘⇧O` 打开 `\(source.symbol)`，按 App 中的唯一动作执行：\(experiment.console.xcodeAction)
    2. 断点暂停后先看 Debug Navigator 的当前线程和 Call Stack，再在控制台逐行执行：

    ```lldb
    # \(experiment.id) · \(metadata.name)
    \(commands)
    ```

    3. Continue 后再操作一次 App，判断 renderer 是否用 UI 输入覆盖了 LLDB 的进程内改值。

    ### 预期真实证据

    \(runtimeEvidence)
    - Catalog 证据：\(experiment.console.expectedResult)
    - 你的解释必须同时说出 `\(metadata.name)` 的种类、`\(property?.name ?? "无精选属性")` 的权限，以及 `\(method.signature)` 的一次可观察副作用。

    ### Reset / 复验

    点击 `Reset Experiment`。基线应为：\(guide.resetBaseline) 然后重复同一动作，确认日志只描述新一轮操作；\(progressBoundary)`Reset Learning Progress` 与 Messenger JSON cache 都不应因此改变。

    ### 误区 / 边界

    - \(kindBoundary)
    - \(guide.boundary)
    - \(typeSpecificBoundary)
    - 分类结论以 `\(evidenceClassification)` 与 Target 边界为准；共享 renderer 的其他状态不能自动成为目标 API 的专属证据。

    ### 思考题

    1. \(propertyQuestion)
    2. 按“谁创建、谁持有、何时释放”解释 `\(metadata.name)`，哪一条证据来自本次调试，哪一条仍只是 catalog 信息？

    """
}

private func conceptCard(
  concept: LanguageConcept,
  experiment: LearningExperiment
) -> String {
  let guide = rendererGuide(for: experiment.control)
  let source = experiment.console.sourceCue
  let appSteps = guide.appSteps.enumerated()
    .map { "\($0.offset + 1). \($0.element)" }
    .joined(separator: "\n")
  let commands = guide.lldbCommands.joined(separator: "\n")
  let isDirect = experiment.evidenceKind == .directWorkload
  let evidenceClassification = isDirect ? "direct workload" : "related observation"
  let evidenceToken = experiment.evidenceToken.map { "`\($0)`" }
    ?? "无（关联观察不写入“已操作”证据）"
  let learningGoal = isDirect
    ? "把 `\(concept.name)` 变成一次可识别的目标 workload：\(concept.definition)"
    : "用 shared interaction model 建立 `\(concept.name)` 的关联观察；本入口不冒充编译器级或目标运行证据：\(concept.definition)"
  let runtimeEvidence = isDirect
    ? "- Target 证据：\(experiment.targetEvidence)\n- Renderer 证据：\(guide.evidence)"
    : "- Shared interaction model：\(guide.evidence)\n- Target 边界：\(experiment.targetEvidence)"
  let progressBoundary = isDirect
    ? "只有日志出现本卡专属 token 才能写入“已操作”证据。"
    : "本入口是关联观察，始终不写入“已操作”证据。"

  return removeGeneratedIndent(
    """
      <!-- experiment-card: \(experiment.id) -->
      ## \(experiment.id) · \(concept.name)

      ### 学习目标

      \(learningGoal)

      ### 机制

      - 直觉类比：\(concept.analogy)。
      - 技术定义：\(concept.definition)
      - 最小代码：

      ```swift
      \(concept.minimalExample)
      ```

      先不要运行答案；先回答：\(concept.retrievalQuestion)

      ### 真实源码锚点

      - File: [\(source.file)](../\(source.file))
      - Symbol: `\(source.symbol)`
      - 本卡概念：`\(concept.id)`；共享 renderer：`\(experiment.control.rawValue)`。
      - 证据分类：`\(evidenceClassification)`
      - Evidence token：\(evidenceToken)

      ### App 操作

      进入 Learn，打开 `\(experiment.title)`。先把上面的最小代码与即将操作的 renderer 对应起来：哪些是输入、状态、事件或异步边界？

      \(appSteps)

      ### Xcode / LLDB 操作

      1. 用 `⌘⇧O` 打开 `\(source.symbol)`，执行 App 给出的唯一动作：\(experiment.console.xcodeAction)
      2. 在断点暂停处先读 Call Stack，再逐行执行：

      ```lldb
      # \(experiment.id) · \(concept.name)
      \(commands)
      ```

      3. Continue 后复述“哪一行代码产生了哪一条状态或日志证据”，不要只背概念定义。

      ### 预期真实证据

      \(runtimeEvidence)
      - Catalog 证据：\(experiment.console.expectedResult)
      - 最终回答必须回到本卡问题：\(concept.retrievalQuestion)

      ### Reset / 复验

      点击 `Reset Experiment`。基线应为：\(guide.resetBaseline) 先改变一次预测，再重复操作；若两轮证据相同，解释哪些机制是确定性的。\(progressBoundary)学习进度 Reset 与 Messenger cache 仍是独立边界。

      ### 误区 / 边界

      - 类比“\(concept.analogy)”只帮助建立直觉，不覆盖编译器规则、UIKit 生命周期或并发调度的全部边界。
      - \(guide.boundary)
      - 分类结论是 `\(evidenceClassification)`：共享 renderer 只是调试载体；它不自动等同于对 `\(concept.name)` 的编译器级证明。需要时继续用对应 CompilerLab sample 或业务链断点补证。

      ### 思考题

      1. \(concept.retrievalQuestion)
      2. 本次哪条证据能直接支持 `\(concept.name)`，哪条只是共享 renderer 的现象，为什么？

    """
  )
}

private func sessionIndex() -> String {
  let rows = LearningCatalog.lessons.map { lesson in
    let experimentIDs =
      lesson.typeIDs.map { "`type.\($0)`" }
      + lesson.conceptIDs.map { "`concept.\($0)`" }
    return "| \(lesson.id) | \(lesson.title) | \(experimentIDs.joined(separator: "、")) |"
  }

  return """
    ## 20 Session 索引

    App 中按 Session 进入；文档中搜索完整 experiment ID 直达卡片。一个实验可能被后续 Session 再次引用，但正文只定义一次。

    | Session | 主题 | 对应操作卡 |
    |---:|---|---|
    \(rows.joined(separator: "\n"))

    """
}

private func evidenceAuditIndex() -> String {
  let relatedTypes = ExperimentCatalog.all
    .filter { $0.evidenceKind == .relatedObservation && $0.targetTypeID != nil }
    .map { "`\($0.id)`" }
    .joined(separator: "、")
  let relatedConcepts = ExperimentCatalog.all
    .filter { $0.evidenceKind == .relatedObservation && $0.targetConceptID != nil }
    .map { "`\($0.id)`" }
    .joined(separator: "、")

  return """
    ## 证据分类审计

    判定标准不是“页面能点”，而是动作是否执行目标的可识别 workload、源码锚点是否落在该调用链、日志是否输出唯一 token。满足三项才是 `direct workload`；否则保留为 `related observation`，不写入“已操作”证据。

    - Direct：51 个；每卡列出 `target-evidence:<ID>` 与目标 API/对象证据。
    - Related type（15）：\(relatedTypes)
    - Related concept（4）：\(relatedConcepts)
    - 三个防误映射样本：Dictionary 使用独立 key/value workload；MessageRepository 命中 `enqueueOutgoing`；MessageTransport 通过 `any MessageTransport` 调用 `send`。

    """
}

private let rendererIndex = """
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

  """

private func renderedDocument() -> Data {
  let directCount = ExperimentCatalog.all.filter { $0.evidenceKind == .directWorkload }.count
  let relatedCount = ExperimentCatalog.all.filter { $0.evidenceKind == .relatedObservation }.count
  var sections = [
    """
    # 70 个学习入口：直接实验与关联观察

    这份文件由 `ExperimentCatalog` 确定性生成，覆盖 52 个 type 与 18 个 concept：其中 \(directCount) 个 `direct workload`、\(relatedCount) 个 `related observation`。App 只显示 Goal、Code、Xcode、Docs、控件与日志；完整解释、LLDB、Reset、边界和思考题集中在这里。

    使用方法：在 App 按标题打开入口后，用编辑器搜索标题里的目标名；也可以从下方 20 Session 索引复制完整 ID，例如 `type.UIView` 或 `concept.stable-identity`。只有执行可识别目标 workload 并输出专属 `target-evidence:<ID>` 的入口才记录“已操作”；关联观察明确不记录。

    生成与校验：

    ```bash
    make experiment-cards
    make verify-experiment-cards
    ```

    > 自动门禁只能证明卡片与 catalog、源码锚点一致；LLDB、Call Stack、View Debugger 和实际解释仍需学习者亲自在 Xcode 中留下证据。

    """,
    sessionIndex(),
    evidenceAuditIndex(),
    rendererIndex,
  ]

  for metadata in TypeCatalog.all {
    guard let experiment = ExperimentCatalog.experiment(id: metadata.experimentID) else {
      fail("missing experiment \(metadata.experimentID)")
    }
    sections.append(typeCard(metadata: metadata, experiment: experiment))
  }

  for concept in LanguageConceptCatalog.all {
    guard let experiment = ExperimentCatalog.experiment(id: concept.experimentID) else {
      fail("missing experiment \(concept.experimentID)")
    }
    sections.append(conceptCard(concept: concept, experiment: experiment))
  }

  return Data((sections.joined(separator: "\n") + "\n").utf8)
}

let arguments = Array(CommandLine.arguments.dropFirst())
let checkOnly = arguments.first == "--check"
let outputPath: String

if checkOnly {
  outputPath = arguments.dropFirst().first ?? defaultOutput
} else {
  outputPath = arguments.first ?? defaultOutput
}

let outputURL = URL(fileURLWithPath: outputPath)
let expected = renderedDocument()

if checkOnly {
  guard let current = try? Data(contentsOf: outputURL) else {
    fail("missing \(outputPath); run `make experiment-cards`")
  }
  guard current == expected else {
    fail("\(outputPath) is stale; run `make experiment-cards`")
  }
  print("Experiment card export: 70 classified Markdown cards match Swift catalogs")
} else {
  do {
    try FileManager.default.createDirectory(
      at: outputURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try expected.write(to: outputURL, options: .atomic)
    print("Experiment card export: wrote \(ExperimentCatalog.all.count) cards to \(outputPath)")
  } catch {
    fail("could not write \(outputPath): \(error)")
  }
}
