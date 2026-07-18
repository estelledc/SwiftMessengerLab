import Foundation

public enum TypeCatalog {
  public static let all: [TypeMetadata] = [
    card(
      "PropertyBox", .class, "SwiftMessengerCore", "把存储、计算、lazy 与 didSet 放进一个可观察对象。", "带仪表盘的储物柜",
      rw: ["stored: Int", "lazyText: String"], ro: ["doubled: Int", "didSetCount: Int"],
      methods: ["init()", "stored.setter", "doubled.getter"]),
    card(
      "MessageDraft", .struct, "SwiftMessengerCore", "保存输入中的消息草稿并计算可发送状态。", "发送前的表单",
      rw: ["text: String"], ro: ["trimmedText: String", "isSendable: Bool"],
      methods: ["init(text:)", "clear()"]),
    card(
      "ValueCounter", .struct, "SwiftMessengerCore", "用最小结构体观察复制后的独立修改。", "复印出来的计数卡",
      rw: ["value: Int"], methods: ["init(value:)", "increment()"]),
    card(
      "ReferenceCounter", .class, "SwiftMessengerCore", "用最小类观察共享实例与对象身份。", "多人共用的计数器",
      rw: ["value: Int"], methods: ["init(value:)", "increment()"]),
    card(
      "Optional", .enum, "Swift", "明确表达一个值存在或不存在。", "可能空着的快递柜",
      ro: ["unsafelyUnwrapped: Wrapped", "debugDescription: String"],
      methods: ["map(_:)", "flatMap(_:)"], conformances: ["ExpressibleByNilLiteral"]),
    card(
      "DeliveryState", .enum, "SwiftMessengerCore", "将消息发送限制在有限且可穷尽处理的状态中。", "快递轨迹",
      ro: ["rawValue: String", "displayText: String"],
      methods: ["init?(rawValue:)", "encode(to:)"],
      conformances: ["Codable", "Hashable", "Sendable"]),
    card(
      "MessageTransport", .protocol, "SwiftMessengerCore", "隔离消息发送能力，使业务不依赖具体网络实现。", "统一规格的插座",
      methods: ["send(_:isRetry:)"], conformances: ["Sendable"],
      related: ["MockMessageTransport", "Message"]),
    card(
      "CaptureOwner", .class, "SwiftMessengerCore", "用强捕获与 weak 捕获观察闭包所有权。", "持有回拨电话的联系人",
      rw: ["label: String", "callback: (() -> Void)?"],
      methods: ["init()", "installWeakCallback()"]),

    card(
      "String", .struct, "Swift", "保存可扩展字形集合并提供文本操作。", "一串可编辑字符",
      ro: ["count: Int", "isEmpty: Bool", "first: Character?", "utf8: UTF8View"],
      methods: ["append(_:)", "contains(_:)", "split(separator:)"],
      conformances: ["Collection", "Hashable", "Codable"]),
    card(
      "Array", .struct, "Swift", "按顺序保存可重复元素。", "有顺序的清单",
      ro: ["count: Int", "isEmpty: Bool", "first: Element?", "last: Element?"],
      methods: ["append(_:)", "insert(_:at:)", "remove(at:)"],
      conformances: ["RandomAccessCollection"]),
    card(
      "Set", .struct, "Swift", "保存不重复且可快速判断成员关系的元素。", "去重名单",
      ro: ["count: Int", "isEmpty: Bool", "first: Element?"],
      methods: ["insert(_:)", "contains(_:)", "remove(_:)"], conformances: ["Collection"]),
    card(
      "Dictionary", .struct, "Swift", "通过唯一 key 保存和查找 value。", "键值通讯录",
      ro: ["count: Int", "isEmpty: Bool", "keys: Keys", "values: Values"],
      methods: ["updateValue(_:forKey:)", "removeValue(forKey:)", "merge(_:uniquingKeysWith:)"],
      conformances: ["Collection"]),

    card(
      "UUID", .struct, "Foundation", "生成和解析适合作为稳定身份的 128 位值。", "不会重复的号码牌",
      ro: ["uuidString: String", "uuid: uuid_t"], methods: ["init()", "init?(uuidString:)"],
      conformances: ["Hashable", "Codable", "Sendable"]),
    card(
      "Date", .struct, "Foundation", "表示与时区无关的时间点。", "时间轴上的刻度",
      ro: ["timeIntervalSince1970: TimeInterval", "description: String"],
      methods: ["addingTimeInterval(_:)", "distance(to:)", "compare(_:)"],
      conformances: ["Comparable", "Codable", "Sendable"]),
    card(
      "URL", .struct, "Foundation", "结构化表示文件或网络资源位置。", "带规则的地址",
      ro: [
        "absoluteString: String", "path: String", "lastPathComponent: String", "isFileURL: Bool",
      ], methods: ["appendingPathComponent(_:)", "deletingLastPathComponent()"],
      conformances: ["Hashable", "Codable", "Sendable"]),
    card(
      "Data", .struct, "Foundation", "保存原始字节，是编码与文件 I/O 的边界值。", "装字节的密封袋",
      ro: ["count: Int", "isEmpty: Bool", "startIndex: Int", "endIndex: Int"],
      methods: ["append(_:)", "write(to:options:)", "base64EncodedString()"],
      conformances: ["RandomAccessCollection", "Codable", "Sendable"]),
    card(
      "FileManager", .class, "Foundation", "查询和修改文件系统中的目录与文件。", "文件仓库管理员",
      ro: ["default: FileManager", "currentDirectoryPath: String", "temporaryDirectory: URL"],
      methods: [
        "fileExists(atPath:)", "createDirectory(at:withIntermediateDirectories:)",
        "removeItem(at:)",
      ], inheritance: ["NSObject"]),

    card(
      "Task", .struct, "Swift", "管理一个结构化或非结构化异步工作单元。", "可以取消的任务单",
      ro: ["value: Success", "result: Result", "isCancelled: Bool"],
      methods: ["init(priority:operation:)", "cancel()", "sleep(nanoseconds:)"],
      conformances: ["Sendable"]),
    card(
      "Result", .enum, "Swift", "把成功值或失败值保存为可传递状态。", "只装成功或失败之一的信封",
      methods: ["get()", "map(_:)", "flatMap(_:)", "mapError(_:)"],
      conformances: ["Sendable when payloads are Sendable"]),

    card(
      "UIResponder", .class, "UIKit", "构成触摸、按键和 action 的响应链节点。", "事件接力队员",
      ro: ["next: UIResponder?", "canBecomeFirstResponder: Bool", "isFirstResponder: Bool"],
      methods: ["becomeFirstResponder()", "resignFirstResponder()", "touchesBegan(_:with:)"],
      inheritance: ["NSObject"]),
    card(
      "UIApplication", .class, "UIKit", "代表应用进程并协调 scene、事件与系统状态。", "应用总调度台",
      ro: ["shared: UIApplication", "connectedScenes: Set<UIScene>", "applicationState: State"],
      methods: ["sendAction(_:to:from:for:)", "open(_:options:completionHandler:)"],
      inheritance: ["UIResponder"]),
    card(
      "UIScene", .class, "UIKit", "表示应用界面的一次独立系统会话。", "一场独立舞台演出",
      rw: ["delegate: UISceneDelegate?", "title: String?"],
      ro: ["session: UISceneSession", "activationState: ActivationState"],
      methods: ["init(session:connectionOptions:)", "open(_:options:completionHandler:)"],
      inheritance: ["UIResponder"]),
    card(
      "UIWindow", .class, "UIKit", "把控制器树接入某个 UIWindowScene 并显示。", "装舞台的窗框",
      rw: [
        "windowScene: UIWindowScene?", "rootViewController: UIViewController?",
        "windowLevel: Level",
      ], ro: ["isKeyWindow: Bool"], methods: ["makeKeyAndVisible()", "makeKey()", "resignKey()"],
      inheritance: ["UIView"], related: ["UIScene", "UIViewController"]),
    card(
      "UIView", .class, "UIKit", "管理矩形区域、绘制、层级和布局。", "贴在画布上的透明卡片",
      rw: [
        "frame: CGRect", "bounds: CGRect", "center: CGPoint", "alpha: CGFloat", "isHidden: Bool",
      ], methods: ["addSubview(_:)", "removeFromSuperview()", "layoutIfNeeded()"],
      inheritance: ["UIResponder"], related: ["NSLayoutConstraint"]),
    card(
      "NSLayoutAnchor", .class, "UIKit", "以类型安全方式创建某一轴或尺寸的约束。", "只连接同类尺寸的卡扣",
      methods: [
        "constraint(equalTo:)", "constraint(equalTo:constant:)",
        "constraint(greaterThanOrEqualTo:)",
      ], inheritance: ["NSObject"]),
    card(
      "NSLayoutConstraint", .class, "UIKit", "描述两个布局属性之间的方程和优先级。", "布局方程",
      rw: ["isActive: Bool", "constant: CGFloat", "priority: UILayoutPriority"],
      ro: ["firstItem: AnyObject?", "secondItem: AnyObject?"],
      methods: ["activate(_:)", "deactivate(_:)"], inheritance: ["NSObject"]),
    card(
      "UIStackView", .class, "UIKit", "按轴自动排列 arrangedSubviews 并管理间距。", "自动排队的展示架",
      rw: [
        "axis: NSLayoutConstraint.Axis", "spacing: CGFloat", "alignment: Alignment",
        "distribution: Distribution",
      ], ro: ["arrangedSubviews: [UIView]"],
      methods: [
        "addArrangedSubview(_:)", "removeArrangedSubview(_:)", "insertArrangedSubview(_:at:)",
      ], inheritance: ["UIView"]),

    card(
      "UIViewController", .class, "UIKit", "管理一棵 view 并协调出现、离开和展示。", "一页内容的导演",
      rw: ["view: UIView!", "title: String?", "preferredContentSize: CGSize"],
      ro: ["navigationItem: UINavigationItem", "isViewLoaded: Bool"],
      methods: ["loadView()", "viewDidLoad()", "present(_:animated:)", "dismiss(animated:)"],
      inheritance: ["UIResponder"], related: ["UINavigationItem"]),
    card(
      "UINavigationItem", .class, "UIKit", "保存某个页面在 navigation bar 上的展示配置。", "页面交给导航栏的名片",
      rw: [
        "title: String?", "leftBarButtonItem: UIBarButtonItem?",
        "rightBarButtonItem: UIBarButtonItem?", "searchController: UISearchController?",
        "backBarButtonItem: UIBarButtonItem?",
      ], methods: ["setLeftBarButton(_:animated:)", "setRightBarButton(_:animated:)"],
      inheritance: ["NSObject"]),
    card(
      "UINavigationController", .class, "UIKit", "用栈保存页面实例并提供 push/pop 导航。", "后进先出的页面栈",
      rw: [
        "viewControllers: [UIViewController]", "isNavigationBarHidden: Bool",
        "delegate: UINavigationControllerDelegate?",
      ], ro: ["topViewController: UIViewController?", "visibleViewController: UIViewController?"],
      methods: [
        "pushViewController(_:animated:)", "popViewController(animated:)",
        "setViewControllers(_:animated:)",
      ], inheritance: ["UIViewController"]),

    card(
      "UILabel", .class, "UIKit", "展示一段不可直接编辑的文字。", "屏幕上的文字牌",
      rw: [
        "text: String?", "font: UIFont!", "textColor: UIColor!", "numberOfLines: Int",
        "textAlignment: NSTextAlignment",
      ], methods: ["sizeToFit()", "drawText(in:)"], inheritance: ["UIView"]),
    card(
      "UIImageView", .class, "UIKit", "展示 UIImage 并控制其缩放与裁切方式。", "带缩放规则的相框",
      rw: [
        "image: UIImage?", "highlightedImage: UIImage?", "isHighlighted: Bool",
        "contentMode: UIView.ContentMode", "animationImages: [UIImage]?",
      ], methods: ["startAnimating()", "stopAnimating()"], inheritance: ["UIView"]),
    card(
      "UIControl", .class, "UIKit", "把触摸等事件转换为可注册的 action。", "带事件线路的开关",
      rw: ["isEnabled: Bool", "isSelected: Bool", "isHighlighted: Bool"],
      ro: ["allControlEvents: Event", "allTargets: Set<AnyHashable>"],
      methods: ["addTarget(_:action:for:)", "sendActions(for:)", "removeTarget(_:action:for:)"],
      inheritance: ["UIView"]),
    card(
      "UIButton", .class, "UIKit", "提供可配置、可禁用并能发送 action 的按钮。", "会汇报点击的按钮",
      rw: ["configuration: Configuration?", "isEnabled: Bool", "isSelected: Bool", "role: Role"],
      ro: ["buttonType: ButtonType"],
      methods: ["setTitle(_:for:)", "setImage(_:for:)", "addAction(_:for:)"],
      inheritance: ["UIControl"], related: ["UIButton.Configuration"]),
    card(
      "UIButton.Configuration", .struct, "UIKit", "以值类型集中描述按钮标题、图标、颜色和尺寸。", "按钮的样式清单",
      rw: [
        "title: String?", "image: UIImage?", "baseForegroundColor: UIColor?",
        "baseBackgroundColor: UIColor?", "cornerStyle: CornerStyle",
      ], methods: ["plain()", "bordered()", "filled()", "tinted()"]),

    card(
      "UITextField", .class, "UIKit", "接收单行文本并参与第一响应者和 delegate 流程。", "单行填写框",
      rw: [
        "text: String?", "placeholder: String?", "delegate: UITextFieldDelegate?",
        "isSecureTextEntry: Bool", "returnKeyType: UIReturnKeyType",
      ], methods: ["becomeFirstResponder()", "resignFirstResponder()", "addTarget(_:action:for:)"],
      inheritance: ["UIControl"], related: ["UITextFieldDelegate"]),
    card(
      "UITextView", .class, "UIKit", "编辑和滚动多行富文本。", "可滚动的多行稿纸",
      rw: [
        "text: String!", "font: UIFont?", "textColor: UIColor?", "delegate: UITextViewDelegate?",
        "isEditable: Bool", "selectedRange: NSRange",
      ], methods: ["scrollRangeToVisible(_:)", "replace(_:withText:)", "becomeFirstResponder()"],
      inheritance: ["UIScrollView"], related: ["UITextViewDelegate"]),
    card(
      "UITextFieldDelegate", .protocol, "UIKit", "在文本变化、Return 和结束编辑前后提供决策与通知。", "单行输入框的观察员",
      methods: [
        "textField(_:shouldChangeCharactersIn:replacementString:)", "textFieldShouldReturn(_:)",
        "textFieldDidEndEditing(_:)",
      ], inheritance: ["NSObjectProtocol"]),
    card(
      "UITextViewDelegate", .protocol, "UIKit", "接收 UITextView 编辑、选择和链接交互回调。", "多行输入框的观察员",
      methods: [
        "textViewDidChange(_:)", "textViewDidBeginEditing(_:)",
        "textView(_:shouldChangeTextIn:replacementText:)",
      ], inheritance: ["NSObjectProtocol"]),

    card(
      "UIScrollView", .class, "UIKit", "通过 contentSize 与 contentOffset 展示大于可视区域的内容。", "能移动视窗的长画卷",
      rw: [
        "contentOffset: CGPoint", "contentSize: CGSize", "contentInset: UIEdgeInsets",
        "delegate: UIScrollViewDelegate?", "isScrollEnabled: Bool",
      ],
      methods: [
        "setContentOffset(_:animated:)", "scrollRectToVisible(_:animated:)",
        "flashScrollIndicators()",
      ], inheritance: ["UIView"]),
    card(
      "UICollectionView", .class, "UIKit", "通过 layout、data source 和复用 cell 展示大量项目。", "只摆出可见卡片的货架",
      rw: [
        "dataSource: UICollectionViewDataSource?", "delegate: UICollectionViewDelegate?",
        "collectionViewLayout: UICollectionViewLayout",
      ], ro: ["visibleCells: [UICollectionViewCell]", "indexPathsForVisibleItems: [IndexPath]"],
      methods: [
        "reloadData()", "dequeueReusableCell(withReuseIdentifier:for:)",
        "scrollToItem(at:at:animated:)",
      ], inheritance: ["UIScrollView"]),
    card(
      "UICollectionViewCell", .class, "UIKit", "作为可复用容器展示一个 item。", "反复换内容的展示卡",
      rw: [
        "isSelected: Bool", "isHighlighted: Bool",
        "backgroundConfiguration: UIBackgroundConfiguration?",
      ], ro: ["contentView: UIView", "reuseIdentifier: String?"],
      methods: ["prepareForReuse()", "preferredLayoutAttributesFitting(_:)"],
      inheritance: ["UICollectionReusableView"]),
    card(
      "UICollectionViewDataSource", .protocol, "UIKit", "回答 collection view 有多少项以及每项使用哪个 cell。",
      "货架的供货清单",
      methods: [
        "collectionView(_:numberOfItemsInSection:)", "collectionView(_:cellForItemAt:)",
        "numberOfSections(in:)",
      ], inheritance: ["NSObjectProtocol"]),
    card(
      "UICollectionViewDelegate", .protocol, "UIKit", "接收选中、显示和交互等 collection view 事件。", "货架交互观察员",
      methods: [
        "collectionView(_:didSelectItemAt:)", "collectionView(_:willDisplay:forItemAt:)",
        "collectionView(_:didEndDisplaying:forItemAt:)",
      ], inheritance: ["UIScrollViewDelegate"]),
    card(
      "UICollectionViewDiffableDataSource", .class, "UIKit",
      "用稳定 item identity 从 snapshot 计算安全差异更新。", "按身份证更新货架的管理员",
      rw: ["supplementaryViewProvider: SupplementaryViewProvider?"],
      methods: [
        "init(collectionView:cellProvider:)", "apply(_:animatingDifferences:)", "snapshot()",
        "itemIdentifier(for:)",
      ], inheritance: ["NSObject"], related: ["NSDiffableDataSourceSnapshot"]),
    card(
      "NSDiffableDataSourceSnapshot", .struct, "UIKit", "以有序 section/item identifier 描述某一时刻的数据状态。",
      "货架当前摆放快照",
      ro: [
        "numberOfItems: Int", "numberOfSections: Int", "itemIdentifiers: [ItemIdentifierType]",
        "sectionIdentifiers: [SectionIdentifierType]",
      ],
      methods: [
        "appendSections(_:)", "appendItems(_:toSection:)", "deleteItems(_:)", "reloadItems(_:)",
      ], related: ["UICollectionViewDiffableDataSource"]),

    card(
      "AppEnvironment", .class, "SwiftMessengerLab", "在组合根创建并持有日志、缓存、Repository 与发送协调器。", "应用的配电箱",
      ro: [
        "log: LabLogStore", "cache: JSONInboxCache", "repository: MessageRepository",
        "delivery: DeliveryCoordinator",
      ], methods: ["makeDefault()", "persist()"],
      related: ["MessageRepository", "JSONInboxCache", "MessageTransport"]),
    card(
      "MessageRepository", .class, "SwiftMessengerCore", "作为消息与会话状态的单一内存 owner。", "消息账本管理员",
      ro: ["conversations: [Conversation]", "snapshot: InboxSnapshot"],
      methods: [
        "enqueueOutgoing(text:conversationID:)", "messages(conversationID:)", "markSending(id:)",
        "markSent(id:serverID:)", "reset(to:)", "recoverInterruptedOutgoingMessages()",
      ], related: ["Message", "InboxSnapshot"]),
    card(
      "JSONInboxCache", .struct, "SwiftMessengerCore", "把 InboxSnapshot 原子编码到本地 JSON 文件。",
      "本地文件保险柜", ro: ["fileURL: URL"], methods: ["load()", "save(_:)"], conformances: ["Sendable"],
      related: ["InboxSnapshot"]),
    card(
      "MockMessageTransport", .struct, "SwiftMessengerCore", "用确定性延迟与失败规则替代真实网络。", "可重复排练的假快递员",
      ro: ["delayNanoseconds: UInt64 (private)"],
      methods: ["init(delayNanoseconds:)", "send(_:isRetry:)"],
      conformances: ["MessageTransport", "Sendable"]),
    card(
      "Message", .struct, "SwiftMessengerCore", "保存稳定身份、正文、时间与发送状态。", "带身份和轨迹的消息包裹",
      rw: ["deliveryState: DeliveryState", "serverID: String?"],
      ro: ["id: UUID", "conversationID: UUID", "text: String", "createdAt: Date"],
      methods: ["init(id:conversationID:author:text:createdAt:deliveryState:)", "encode(to:)"],
      conformances: ["Identifiable", "Codable", "Hashable", "Sendable"], related: ["DeliveryState"]),
    card(
      "InboxSnapshot", .struct, "SwiftMessengerCore", "把会话和消息组合为可编码、可恢复的业务快照。", "收件箱的存档照片",
      rw: ["conversations: [Conversation]", "messages: [Message]"],
      methods: ["init(conversations:messages:)", "encode(to:)"],
      conformances: ["Codable", "Equatable", "Sendable"], related: ["Message"]),
  ]

  public static let byID: [String: TypeMetadata] = Dictionary(
    uniqueKeysWithValues: all.map { ($0.id, $0) })

  public static func type(id: String) -> TypeMetadata? { byID[id] }

  private static func card(
    _ name: String,
    _ kind: SwiftTypeKind,
    _ module: String,
    _ purpose: String,
    _ analogy: String,
    rw: [String] = [],
    ro: [String] = [],
    methods: [String],
    inheritance: [String] = [],
    conformances: [String] = [],
    related: [String] = []
  ) -> TypeMetadata {
    let isReference = kind == .class
    return TypeMetadata(
      id: name,
      name: name,
      kind: kind,
      module: module,
      inheritance: inheritance,
      conformances: conformances,
      relatedTypeIDs: related,
      purpose: purpose,
      analogy: analogy,
      createdBy: module == "UIKit" ? "UIKit、SceneDelegate 或页面配置代码" : "源码中的初始化器、字面量或工厂方法",
      ownedBy: isReference ? "创建它的强引用、UIKit 层级或业务组合根" : "当前变量或包含它的值",
      releasedWhen: isReference ? "最后一个强引用解除时" : "值离开作用域或从容器移除时",
      properties: rw.map { property($0, access: .readWrite) }
        + ro.map { property($0, access: .getOnly) },
      methods: methods.map(method),
      experimentID: "type.\(name)"
    )
  }

  private static func property(_ specification: String, access: PropertyAccess) -> PropertyLesson {
    let pieces = specification.split(separator: ":", maxSplits: 1).map(String.init)
    let name = pieces[0]
    let type = pieces.count == 2 ? pieces[1].trimmingCharacters(in: .whitespaces) : "见声明"
    return PropertyLesson(
      name: name,
      type: type,
      access: access,
      defaultValue: "见实验默认状态",
      mutableRange: access == .readWrite ? "仅 App 白名单控件范围" : "通过改变输入或调用方法观察",
      observationQuestion: access == .readWrite
        ? "修改 \(name) 后，预览和日志分别发生什么变化？"
        : "为什么 \(name) 不能直接赋值，应该改变哪个输入？"
    )
  }

  private static func method(_ signature: String) -> MethodLesson {
    MethodLesson(
      signature: signature,
      input: "按签名传入参数；无参数时写无",
      output: "在返回值、预览或日志中观察",
      sideEffect: "以类型卡说明和实验日志为准",
      triggeredBy: "App 白名单实验或业务调用方",
      recommendedBreakpoint: signature
    )
  }
}

public enum LanguageConceptCatalog {
  public static let all: [LanguageConcept] = [
    concept(
      "let-var", "let / var", "封条与白板", "let 绑定不能重新赋值，var 绑定可以；两者都会在编译期接受类型检查。",
      "let answer = 42\nvar count = 0\ncount += 1", "改写 var，再把它改成 let，预测编译器反馈。"),
    concept(
      "type-inference", "类型推断", "根据内容自动选择标签", "编译器从初始化表达式推断静态类型，之后不能随意换成另一种类型。",
      "let whole = 1\nlet fraction = 1.0", "whole 和 fraction 的静态类型分别是什么？"),
    concept(
      "stored-computed", "存储属性 / 计算属性", "仓库与即时计算器", "存储属性占有状态；计算属性每次访问执行 getter，可能还有 setter。",
      "var doubled: Int { stored * 2 }", "doubled 的值存在哪里？"),
    concept(
      "lazy-didset", "lazy / didSet", "首次开箱与写入监控", "lazy 延迟到首次访问初始化；didSet 在已初始化属性被写入后运行。",
      "lazy var text = makeText()\nvar value = 0 { didSet {} }", "初始化过程是否触发 didSet？"),
    concept(
      "init-self-access", "init / self / 访问控制", "验收表、当前对象与门禁",
      "init 建立合法初始值，self 指当前实例，访问级别限制名字的可见范围。", "public init(text: String) { self.text = text }",
      "为什么所有存储属性都要在 init 结束前初始化？"),
    concept(
      "value-reference", "值语义 / 引用语义", "复印件与共享白板", "struct 赋值复制值；class 变量保存实例引用，=== 比较对象身份。",
      "var b = a\nlet same = objectA === objectB", "修改 b 时 a 一定变化吗？"),
    concept(
      "switch-exhaustiveness", "switch 穷尽", "每个出口都有人值守", "对 enum 的 switch 必须覆盖所有合法状态或明确使用 default。",
      "switch state { case .sent: break; case .failed: break }", "新增 enum case 后编译器如何帮助你？"),
    concept(
      "delegate-closure-arc", "delegate / closure / weak / ARC", "回拨号码与所有权线路",
      "回调反向通知事件；ARC 依据强引用计数释放 class，weak 用于打断不必要的强环。", "callback = { [weak self] in self?.run() }",
      "闭包强捕获 self 时引用图多出哪条边？"),
    concept(
      "codable", "Codable", "统一格式的运单", "Codable 是 Encodable 与 Decodable 的组合，用于值与外部表示之间的双向转换。",
      "let data = try JSONEncoder().encode(value)", "Data 和业务 struct 分别位于边界哪一侧？"),
    concept(
      "async-await-throws", "async / await / throws", "可暂停且可能失败的取件单",
      "await 标出异步暂停点，throws 沿调用链传播失败，Task 承载异步工作。",
      "let receipt = try await transport.send(message)", "暂停是否等于阻塞当前线程？"),
    concept(
      "responder-scene-chain", "Responder 与 Scene 链", "事件接力与独立舞台",
      "应用进程可拥有多个 scene，每个 window 把自己的控制器树接到系统。",
      "UIApplication → UIScene → UIWindow → UIViewController", "多窗口时为何不能只保存一个全局 window？"),
    concept(
      "auto-layout", "Auto Layout", "联立布局方程", "约束描述视图属性之间的关系，布局引擎按优先级求出 frame。",
      "view.widthAnchor.constraint(equalToConstant: 120)", "创建 constraint 与激活 constraint 有什么区别？"),
    concept(
      "view-controller-lifecycle", "控制器生命周期", "导演进场和退场",
      "控制器创建、加载 view、出现与消失是不同阶段，push/pop 决定实例何时离开栈。",
      "viewDidLoad → viewWillAppear → viewDidAppear", "返回旧页面通常会再次调用 viewDidLoad 吗？"),
    concept(
      "target-action", "target-action", "控件发出的事件通知", "UIControl 在指定事件发生时把 action 发送给目标。",
      "button.addTarget(self, action: #selector(tap), for: .touchUpInside)",
      "isEnabled=false 时 action 是否触发？"),
    concept(
      "first-responder", "第一响应者", "当前接收键盘的人", "同一窗口中由 first responder 接收键盘输入，可主动申请或辞去。",
      "field.becomeFirstResponder()", "delegate 和 editingChanged 谁先收到一次字符变化？"),
    concept(
      "reuse", "复用与可见区域", "循环使用少量展示卡", "列表只为可见区域维护 cell；cell 身份不等于业务 item 身份。",
      "dequeueConfiguredReusableCell(...)", "为什么不能把状态只存在 cell 中？"),
    concept(
      "stable-identity", "稳定 identity", "货物身份证而非货架位置",
      "diffable data source 使用稳定且唯一的 Hashable id 计算插入、删除与移动。", "snapshot.appendItems(messageIDs)",
      "刷新时重新生成 UUID 会发生什么？"),
    concept(
      "dependency-injection", "依赖注入", "从配电箱接入实现", "调用者依赖协议，由组合根提供具体 Repository、Transport 和 Cache。",
      "DeliveryCoordinator(repository: repo, transport: mock)", "为什么测试不应创建真实网络 transport？"),
  ]

  public static let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

  private static func concept(
    _ id: String,
    _ name: String,
    _ analogy: String,
    _ definition: String,
    _ example: String,
    _ question: String
  ) -> LanguageConcept {
    LanguageConcept(
      id: id,
      name: name,
      analogy: analogy,
      definition: definition,
      minimalExample: example,
      experimentID: "concept.\(id)",
      retrievalQuestion: question
    )
  }
}

public enum ExperimentCatalog {
  /// Every published target is intentionally classified. Anything outside these sets is a
  /// related observation and cannot write an "operated" progress record.
  public static let directTypeIDs: Set<String> = [
    "PropertyBox", "MessageDraft", "ValueCounter", "ReferenceCounter", "DeliveryState",
    "MessageTransport", "CaptureOwner", "String", "Array", "Set", "Dictionary", "UUID",
    "Date", "URL", "Data", "FileManager", "Task", "UIView", "NSLayoutAnchor",
    "NSLayoutConstraint", "UIViewController", "UINavigationController", "UIControl", "UIButton",
    "UIButton.Configuration", "UITextField", "UITextFieldDelegate", "UICollectionView",
    "UICollectionViewCell", "UICollectionViewDataSource", "UICollectionViewDiffableDataSource",
    "NSDiffableDataSourceSnapshot", "MessageRepository", "JSONInboxCache", "MockMessageTransport",
    "Message", "InboxSnapshot",
  ]

  public static let directConceptIDs: Set<String> = [
    "stored-computed", "lazy-didset", "init-self-access", "value-reference",
    "switch-exhaustiveness", "delegate-closure-arc", "codable", "async-await-throws",
    "auto-layout", "view-controller-lifecycle", "target-action", "first-responder", "reuse",
    "stable-identity",
  ]

  public static let all: [LearningExperiment] =
    TypeCatalog.all.map(makeTypeExperiment) + LanguageConceptCatalog.all.map(makeConceptExperiment)

  public static let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

  public static func experiment(id: String) -> LearningExperiment? { byID[id] }

  private static func makeTypeExperiment(_ metadata: TypeMetadata) -> LearningExperiment {
    let control = control(for: metadata.id)
    let renderer = rendererContract(for: control)
    let evidenceKind: ExperimentEvidenceKind =
      directTypeIDs.contains(metadata.id) ? .directWorkload : .relatedObservation
    let evidenceToken = evidenceKind == .directWorkload ? "target-evidence:\(metadata.experimentID)" : nil
    let titleSuffix = evidenceKind == .directWorkload ? "Experiment" : "Related Observation"
    let targetEvidence = typeEvidenceDescription(
      metadata: metadata,
      kind: evidenceKind,
      token: evidenceToken,
      control: control
    )
    return LearningExperiment(
      id: metadata.experimentID,
      targetTypeID: metadata.id,
      title: "\(metadata.name) \(titleSuffix)",
      control: control,
      evidenceKind: evidenceKind,
      evidenceToken: evidenceToken,
      targetEvidence: targetEvidence,
      console: ExperimentConsoleDescriptor(
        goal: evidenceKind == .directWorkload
          ? "执行 \(metadata.name) workload：\(metadata.purpose)"
          : "关联观察 \(metadata.name)：共享控件只展示相邻机制，不写入已操作证据。",
        sourceCue: renderer.sourceCue,
        xcodeAction: renderer.xcodeAction,
        expectedResult: evidenceKind == .directWorkload
          ? "状态与日志出现 \(evidenceToken ?? "")，且能定位 \(metadata.name) 的真实调用。"
          : "只记录 shared interaction model；不能把结果当作 \(metadata.name) 的运行证据。",
        docsPath: "docs/experiment-cards.md"
      ),
      compilerSample: compilerSample(for: metadata.id)
    )
  }

  private static func makeConceptExperiment(_ concept: LanguageConcept) -> LearningExperiment {
    let control = conceptControl(for: concept.id)
    let renderer = rendererContract(for: control)
    let evidenceKind: ExperimentEvidenceKind =
      directConceptIDs.contains(concept.id) ? .directWorkload : .relatedObservation
    let evidenceToken = evidenceKind == .directWorkload ? "target-evidence:\(concept.experimentID)" : nil
    let titleSuffix = evidenceKind == .directWorkload ? "Experiment" : "Related Observation"
    let targetEvidence = conceptEvidenceDescription(
      concept: concept,
      kind: evidenceKind,
      token: evidenceToken,
      control: control
    )
    return LearningExperiment(
      id: concept.experimentID,
      targetConceptID: concept.id,
      title: "\(concept.name) \(titleSuffix)",
      control: control,
      evidenceKind: evidenceKind,
      evidenceToken: evidenceToken,
      targetEvidence: targetEvidence,
      console: ExperimentConsoleDescriptor(
        goal: evidenceKind == .directWorkload
          ? "执行 \(concept.name) workload，并先预测：\(concept.retrievalQuestion)"
          : "关联观察 \(concept.name)：共享控件只展示相邻机制，不写入已操作证据。",
        sourceCue: renderer.sourceCue,
        xcodeAction: renderer.xcodeAction,
        expectedResult: evidenceKind == .directWorkload
          ? "日志出现 \(evidenceToken ?? "")，并能回答：\(concept.retrievalQuestion)"
          : "只记录 shared interaction model；仍需用编译器样本或目标代码补证。",
        docsPath: "docs/experiment-cards.md"
      ),
      compilerSample: concept.id == "value-reference" ? "value-and-reference" : nil
    )
  }

  private static func control(for id: String) -> ExperimentControl {
    switch id {
    case "PropertyBox": return .propertyObserver
    case "ValueCounter", "ReferenceCounter": return .valueReference
    case "Optional", "DeliveryState", "Result": return .stateMachine
    case "MessageTransport": return .concurrency
    case "CaptureOwner": return .ownership
    case "UUID", "Date", "URL", "Data", "FileManager", "JSONInboxCache", "InboxSnapshot":
      return .foundation
    case "Task", "MockMessageTransport": return .concurrency
    case "UIResponder", "UIApplication", "UIScene", "UIWindow", "UIViewController",
      "UINavigationItem", "UINavigationController":
      return .navigation
    case "UIView", "NSLayoutAnchor", "NSLayoutConstraint", "UIStackView", "UILabel", "UIImageView":
      return .viewAppearance
    case "UIControl", "UIButton", "UIButton.Configuration": return .button
    case "UITextField", "UITextView", "UITextFieldDelegate", "UITextViewDelegate": return .textInput
    case "UIScrollView", "UICollectionView", "UICollectionViewCell", "UICollectionViewDataSource",
      "UICollectionViewDelegate", "UICollectionViewDiffableDataSource",
      "NSDiffableDataSourceSnapshot":
      return .collection
    case "MessageRepository": return .repository
    case "Message": return .concurrency
    case "AppEnvironment": return .stateMachine
    case "Dictionary": return .dictionary
    case "Array", "Set": return .collection
    case "MessageDraft", "String": return .text
    default: return .valueStepper
    }
  }

  private static func conceptControl(for id: String) -> ExperimentControl {
    switch id {
    case "stored-computed", "lazy-didset":
      return .propertyObserver
    case "init-self-access":
      return .text
    case "value-reference":
      return .valueReference
    case "switch-exhaustiveness":
      return .stateMachine
    case "delegate-closure-arc":
      return .ownership
    case "codable":
      return .foundation
    case "async-await-throws", "dependency-injection":
      return .concurrency
    case "responder-scene-chain", "view-controller-lifecycle":
      return .navigation
    case "auto-layout":
      return .viewAppearance
    case "target-action":
      return .button
    case "first-responder":
      return .textInput
    case "reuse", "stable-identity":
      return .collection
    default:
      return .valueStepper
    }
  }

  private struct RendererContract {
    let sourceCue: ExperimentSourceCue
    let xcodeAction: String
  }

  private static func typeEvidenceDescription(
    metadata: TypeMetadata,
    kind: ExperimentEvidenceKind,
    token: String?,
    control: ExperimentControl
  ) -> String {
    guard kind == .directWorkload else {
      return "`\(control.rawValue)` 只是 shared interaction model；未执行 \(metadata.name) 的专属 workload，不写入“已操作”证据。"
    }

    let detail: String
    switch metadata.id {
    case "PropertyBox":
      detail = "创建 PropertyBox，修改 stored，并读取 didSetCount、doubled 与 lazyText"
    case "MessageDraft":
      detail = "由文本输入创建 MessageDraft，并读取 trimmedText 与 isSendable"
    case "ValueCounter":
      detail = "复制 ValueCounter 后只修改副本"
    case "ReferenceCounter":
      detail = "让两个变量引用同一 ReferenceCounter，并用 === 与同步变值确认身份"
    case "DeliveryState":
      detail = "创建 DeliveryState 数组并用穷尽 switch 推进真实 enum case"
    case "MessageTransport":
      detail = "通过 `any MessageTransport` existential 调用 send(_:isRetry:)"
    case "CaptureOwner":
      detail = "创建 CaptureOwner、安装 weak closure 并释放最后一个强引用"
    case "String":
      detail = "修改 String，并执行 count、isEmpty 与 trimmingCharacters"
    case "Array":
      detail = "对 `[UUID]` 执行 reverse 与 append"
    case "Set":
      detail = "由 UUID 数组构造 Set 并读取去重后的 count"
    case "Dictionary":
      detail = "对 `[String: Int]` 执行 updateValue、default subscript、merge 与 removeValue"
    case "UUID":
      detail = "用 UUID 创建 probe identity 与唯一 fixture 目录"
    case "Date":
      detail = "用 Date 记录 round-trip 完成时间"
    case "URL":
      detail = "持有并读取临时目录 URL 与 inbox.json file URL"
    case "Data":
      detail = "从落盘 JSON URL 读取 Data 并检查 byte count"
    case "FileManager":
      detail = "创建、检查并在 Reset/deinit 删除临时 fixture 目录"
    case "Task":
      detail = "创建可取消 Task，跨 await 后回到 MainActor 更新状态"
    case "UIView":
      detail = "创建 preview UIView 并修改 alpha、backgroundColor 与 isHidden"
    case "NSLayoutAnchor":
      detail = "使用 center/width/height anchors 创建约束"
    case "NSLayoutConstraint":
      detail = "激活 preview 的 NSLayoutConstraint 集合"
    case "UIViewController":
      detail = "创建并 push NavigationProbeViewController，记录生命周期"
    case "UINavigationController":
      detail = "通过真实 navigationController 执行 push/pop"
    case "UIControl":
      detail = "修改 isEnabled 并发送 touchUpInside control event"
    case "UIButton":
      detail = "创建 UIButton 并触发 target-action"
    case "UIButton.Configuration":
      detail = "创建 filled/bordered UIButton.Configuration 并应用到按钮"
    case "UITextField":
      detail = "创建 UITextField，输入文本并改变 first responder"
    case "UITextFieldDelegate":
      detail = "安装 UITextFieldDelegate 并触发 shouldChange/shouldReturn 回调"
    case "UICollectionView":
      detail = "创建 UICollectionView 并应用 diffable snapshot"
    case "UICollectionViewCell":
      detail = "注册并 dequeue UICollectionViewListCell"
    case "UICollectionViewDataSource":
      detail = "让 diffable data source 为 collection view 提供 cell"
    case "UICollectionViewDiffableDataSource":
      detail = "创建 UICollectionViewDiffableDataSource 并 apply snapshot"
    case "NSDiffableDataSourceSnapshot":
      detail = "创建 snapshot，append section/items 后应用"
    case "MessageRepository":
      detail = "调用 enqueueOutgoing，验证消息 append、queued 状态与会话 preview 更新"
    case "JSONInboxCache":
      detail = "用 JSONInboxCache save/load 同一 InboxSnapshot"
    case "MockMessageTransport":
      detail = "创建 MockMessageTransport 并执行确定性 send"
    case "Message":
      detail = "创建 Message 并把它传入 transport.send"
    case "InboxSnapshot":
      detail = "把 InboxSnapshot 编码落盘后解码并逐值比对"
    default:
      preconditionFailure("Missing direct type evidence audit for \(metadata.id)")
    }
    return "\(detail)；成功后写入专属 token `\(token ?? "")`。"
  }

  private static func conceptEvidenceDescription(
    concept: LanguageConcept,
    kind: ExperimentEvidenceKind,
    token: String?,
    control: ExperimentControl
  ) -> String {
    guard kind == .directWorkload else {
      return "`\(control.rawValue)` 只是 shared interaction model；未执行 \(concept.name) 的专属 workload，不写入“已操作”证据。"
    }

    let detail: String
    switch concept.id {
    case "stored-computed":
      detail = "修改 PropertyBox.stored，并读取 computed doubled"
    case "lazy-didset":
      detail = "先触发 didSet，再首次读取并复验 lazyText"
    case "init-self-access":
      detail = "执行 MessageDraft.init(text:) 的 self.text 初始化"
    case "value-reference":
      detail = "对 struct copy 与 class alias 执行同一次 increment"
    case "switch-exhaustiveness":
      detail = "用穷尽 switch 处理 DeliveryState"
    case "delegate-closure-arc":
      detail = "触发 weak closure，再释放 owner 观察 weak 归零"
    case "codable":
      detail = "用 JSONEncoder/JSONDecoder round-trip Codable InboxSnapshot"
    case "async-await-throws":
      detail = "在可取消 Task 中 try await MessageTransport.send"
    case "auto-layout":
      detail = "用 anchors 创建并激活 preview 约束"
    case "view-controller-lifecycle":
      detail = "push/pop probe 并记录 viewDidLoad、appear、disappear 与 deinit"
    case "target-action":
      detail = "发送 touchUpInside 并验证禁用 UIControl 不触发 action"
    case "first-responder":
      detail = "执行 become/resignFirstResponder 并记录 delegate 顺序"
    case "reuse":
      detail = "注册并 dequeue 可复用 collection cell"
    case "stable-identity":
      detail = "用固定 UUID 更新 diffable snapshot 并检查唯一性"
    default:
      preconditionFailure("Missing direct concept evidence audit for \(concept.id)")
    }
    return "\(detail)；成功后写入专属 token `\(token ?? "")`。"
  }

  private static func rendererContract(for control: ExperimentControl) -> RendererContract {
    let file = "SwiftMessengerLab/Learning/InteractiveExperimentViewController.swift"

    switch control {
    case .valueStepper:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "recordOperation(_:)"),
        xcodeAction: "在 recordOperation(_:) 设置断点，操作 Stepper 后查看 event 与 Call Stack。"
      )
    case .propertyObserver:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "incrementPropertyProbe()"),
        xcodeAction:
          "在 incrementPropertyProbe() 设置断点，点击 Increment stored 后检查 didSetCount 与 doubled。"
      )
    case .valueReference:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "mutateValueReferenceProbes()"),
        xcodeAction: "在 mutateValueReferenceProbes() 设置断点，点击 Mutate 后比较 struct copy 与 class alias。"
      )
    case .text:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "applyTextProbe()"),
        xcodeAction: "在 applyTextProbe() 设置断点，点击 Apply Text 后检查 MessageDraft 与 String 状态。"
      )
    case .ownership:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "recordOperation(_:)"),
        xcodeAction: "在 recordOperation(_:) 设置断点，释放 owner 后观察 weak 引用与 Call Stack。"
      )
    case .foundation:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "runFoundationRoundTrip()"),
        xcodeAction: "在 runFoundationRoundTrip() 设置断点，执行 Save + Load 后核对 URL、Data 与磁盘 fixture。"
      )
    case .concurrency:
      return RendererContract(
        sourceCue: ExperimentSourceCue(
          file: "SwiftMessengerLab/Core/MessageTransport.swift",
          symbol: "send(_:isRetry:)"
        ),
        xcodeAction: "在 MockMessageTransport.send(_:isRetry:) 设置断点，运行异步实验后查看线程与 Call Stack。"
      )
    case .navigation:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "recordOperation(_:)"),
        xcodeAction: "在 recordOperation(_:) 设置断点，点击 Push 后查看 probe id 与 Call Stack。"
      )
    case .viewAppearance:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "applyViewState()"),
        xcodeAction: "运行实验后使用 Debug View Hierarchy 定位 experiment-preview。"
      )
    case .button:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "actionButtonTapped()"),
        xcodeAction: "在 actionButtonTapped() 设置断点，点击 Send Action 后查看调用来源。"
      )
    case .textInput:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "textFieldShouldReturn(_:)"),
        xcodeAction: "在 textFieldShouldReturn(_:) 设置断点，按 Return 后查看 delegate Call Stack。"
      )
    case .collection:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "applyCollectionSnapshot()"),
        xcodeAction: "在 applyCollectionSnapshot() 设置断点，刷新后检查稳定 item id。"
      )
    case .dictionary:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "runDictionaryWorkload()"),
        xcodeAction: "在 runDictionaryWorkload() 设置断点，执行后检查 key 的更新、合并与删除。"
      )
    case .repository:
      return RendererContract(
        sourceCue: ExperimentSourceCue(
          file: "SwiftMessengerLab/Core/MessageRepository.swift",
          symbol: "enqueueOutgoing(text:conversationID:id:date:)"
        ),
        xcodeAction: "在 enqueueOutgoing(...) 设置断点，执行后检查消息数、queued 状态与会话预览。"
      )
    case .stateMachine:
      return RendererContract(
        sourceCue: ExperimentSourceCue(file: file, symbol: "advanceDeliveryState()"),
        xcodeAction: "在 advanceDeliveryState() 设置断点，点击 Advance 后检查 DeliveryState 与 stateIndex。"
      )
    }
  }

  private static func compilerSample(for id: String) -> String? {
    switch id {
    case "PropertyBox": return "property-access"
    case "ValueCounter", "ReferenceCounter": return "value-and-reference"
    case "MessageTransport": return "method-dispatch"
    case "CaptureOwner": return "closure-capture"
    case "Optional", "DeliveryState", "Result", "Message": return "enum-state-machine"
    default: return nil
    }
  }
}

public enum LearningCatalog {
  public static let lessons: [LessonDefinition] = [
    lesson(1, "let / var 与类型推断", [], "能预测一次赋值是否被编译器允许", [], ["let-var", "type-inference"]),
    lesson(
      2, "存储、计算、lazy 与 didSet", [1], "能区分值存在哪里与何时计算", ["PropertyBox"],
      ["stored-computed", "lazy-didset"]),
    lesson(3, "方法、init、self 与访问控制", [2], "能从签名说清输入、输出和副作用", ["MessageDraft"], ["init-self-access"]),
    lesson(
      4, "struct 与 class：复制和共享", [3], "能用 === 证明两个变量是否指向同一实例",
      ["ValueCounter", "ReferenceCounter"], ["value-reference"]),
    lesson(
      5, "Optional、enum、switch 与错误状态", [1], "能穷尽处理消息的每一种状态", ["Optional", "DeliveryState"],
      ["switch-exhaustiveness"]),
    lesson(
      6, "protocol、delegate、closure、weak 与 ARC", [4, 5], "能画出回调关系和强弱引用",
      ["MessageTransport", "CaptureOwner"], ["delegate-closure-arc"]),
    lesson(
      7, "String 与集合", [1], "能选择 Array、Set、Dictionary 并使用高频 API",
      ["String", "Array", "Set", "Dictionary"], []),
    lesson(
      8, "Foundation 常用值与持久化", [7], "能把业务值编码为 Data 并写入 URL",
      ["UUID", "Date", "URL", "Data", "FileManager"], ["codable"]),
    lesson(
      9, "Task、async/await、throws 与 Result", [5, 6], "能追踪成功和失败两条异步控制流", ["Task", "Result"],
      ["async-await-throws"]),
    lesson(
      10, "UIResponder → UIApplication → UIScene → UIWindow", [3], "能从进程入口追到首个可见页面",
      ["UIResponder", "UIApplication", "UIScene", "UIWindow"], ["responder-scene-chain"]),
    lesson(11, "UIView 几何、外观与层级", [10], "能解释 frame 与 bounds，并用三种方式改外观", ["UIView"], []),
    lesson(
      12, "Auto Layout、anchor 与 UIStackView", [11], "能写出一组不冲突的约束",
      ["NSLayoutAnchor", "NSLayoutConstraint", "UIStackView"], ["auto-layout"]),
    lesson(
      13, "UIViewController 与生命周期", [10, 11], "能区分创建、加载、出现和离开",
      ["UIViewController", "UINavigationItem"], ["view-controller-lifecycle"]),
    lesson(
      14, "UINavigationController 与页面身份", [13], "能解释 push/pop 后实例是否仍存在", ["UINavigationController"],
      ["view-controller-lifecycle"]),
    lesson(
      15, "UILabel 与 UIImageView", [11], "能配置常见展示属性并解释 contentMode", ["UILabel", "UIImageView"], []),
    lesson(
      16, "UIButton、UIControl 与 target-action", [11], "能证明禁用控件不会发送 action",
      ["UIControl", "UIButton", "UIButton.Configuration"], ["target-action"]),
    lesson(
      17, "UITextField、UITextView 与键盘", [6, 16], "能追踪 delegate、control event 和第一响应者顺序",
      ["UITextField", "UITextView", "UITextFieldDelegate", "UITextViewDelegate"],
      ["first-responder"]),
    lesson(
      18, "UIScrollView、UICollectionView 与复用", [11, 12], "能解释可见区域与 cell 复用",
      ["UIScrollView", "UICollectionView", "UICollectionViewCell"], ["reuse"]),
    lesson(
      19, "data source、delegate 与 diffable snapshot", [7, 18], "能用稳定 identity 更新列表且不重复 item",
      [
        "UICollectionViewDataSource", "UICollectionViewDelegate",
        "UICollectionViewDiffableDataSource", "NSDiffableDataSourceSnapshot",
      ], ["stable-identity"]),
    lesson(
      20, "映射回 IM：环境、仓库、传输与缓存", [8, 9, 19], "能从点击 Send 追到发送、落库、失败和重试",
      [
        "AppEnvironment", "MessageRepository", "MessageTransport", "JSONInboxCache",
        "MockMessageTransport", "Message", "InboxSnapshot", "DeliveryState",
      ], ["dependency-injection"]),
  ]

  public static func types(for lesson: LessonDefinition) -> [TypeMetadata] {
    lesson.typeIDs.compactMap(TypeCatalog.type)
  }

  public static func concepts(for lesson: LessonDefinition) -> [LanguageConcept] {
    lesson.conceptIDs.compactMap { LanguageConceptCatalog.byID[$0] }
  }

  public static func primaryExperiment(for lesson: LessonDefinition) -> LearningExperiment? {
    let candidates = lesson.typeIDs.map { "type.\($0)" } + lesson.conceptIDs.map { "concept.\($0)" }
    return candidates.compactMap(ExperimentCatalog.experiment).first(where: \.recordsOperationEvidence)
      ?? ExperimentCatalog.experiment(id: lesson.primaryExperimentID)
  }

  public static func lesson(containingTypeID id: String) -> LessonDefinition? {
    lessons.first { $0.typeIDs.contains(id) }
  }

  public static let legacyExperimentMapping: [String: String] = Dictionary(
    uniqueKeysWithValues: lessons.compactMap { lesson in
      guard let first = lesson.typeIDs.first else {
        return lesson.conceptIDs.first.map { ("lesson-\(lesson.id)", "concept.\($0)") }
      }
      return ("lesson-\(lesson.id)", "type.\(first)")
    }
  )

  private static func lesson(
    _ id: Int,
    _ title: String,
    _ prerequisites: [Int],
    _ ability: String,
    _ typeIDs: [String],
    _ conceptIDs: [String]
  ) -> LessonDefinition {
    let primaryExperimentID = typeIDs.first.map { "type.\($0)" } ?? "concept.\(conceptIDs[0])"
    return LessonDefinition(
      id: id,
      title: title,
      durationMinutes: 30...45,
      prerequisites: prerequisites,
      coreAbility: ability,
      typeIDs: typeIDs,
      conceptIDs: conceptIDs,
      primaryExperimentID: primaryExperimentID,
      misconceptions: [
        "看到 API 名字不等于理解它的状态、所有权与调用方。",
        "点过实验只表示已操作，仍需回答检索题并给出证据。",
      ],
      retrievalQuestions: [
        "指出本课一个名字属于 class、struct、enum、protocol 还是语言概念。",
        "解释一个属性的读写权限，以及一个方法的输入、输出和副作用。",
        "给出 App、LLDB 或 SIL/汇编中的一条观察证据。",
      ],
      nextStep: id == 20 ? "回到 Messenger，从 Send 断点追踪一次成功和一次失败重试。" : "进入第 \(id + 1) 课前，先口头回答本课 3 道题。"
    )
  }
}
