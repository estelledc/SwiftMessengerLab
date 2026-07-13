import UIKit

final class TypeDetailViewController: UIViewController {
    private let metadata: TypeMetadata
    private let lesson: LessonDefinition
    private let progressStore: PracticeProgressStore
    private let stack = UIStackView()

    init(metadata: TypeMetadata, lesson: LessonDefinition, progressStore: PracticeProgressStore) {
        self.metadata = metadata
        self.lesson = lesson
        self.progressStore = progressStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = metadata.name
        view.backgroundColor = .systemBackground
        configureLayout()
        render()
    }

    private func configureLayout() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func render() {
        addSection("\(metadata.module).\(metadata.name)", "类型：\(metadata.kind.rawValue)\n\n日常类比：\(metadata.analogy)\n\n技术定义：\(metadata.purpose)", style: .title1)
        let relations = (metadata.inheritance + metadata.conformances).joined(separator: " → ")
        let related = metadata.relatedTypeIDs.joined(separator: "、")
        addSection("关系与生命周期", "关系：\(relations.isEmpty ? "无继承或协议要求" : relations)\n关联类型：\(related.isEmpty ? "本卡独立观察" : related)\n谁创建：\(metadata.createdBy)\n谁持有：\(metadata.ownedBy)\n何时释放：\(metadata.releasedWhen)")

        if metadata.properties.isEmpty {
            addSection("常用属性", "这个 protocol / enum 没有可直接学习的实例属性要求；通过方法、case 或 conforming type 观察，不能虚构属性。")
        } else {
            let properties = metadata.properties.map {
                "\($0.name): \($0.type) [\($0.access.rawValue)]\n默认 \($0.defaultValue) · 范围 \($0.mutableRange)\n观察：\($0.observationQuestion)"
            }.joined(separator: "\n\n")
            addSection("常用属性", properties)
        }

        let methods = metadata.methods.map {
            "\($0.signature)\n输入 \($0.input) → 输出 \($0.output)\n副作用 \($0.sideEffect) · 触发方 \($0.triggeredBy)\n推荐断点 \($0.recommendedBreakpoint)"
        }.joined(separator: "\n\n")
        addSection("常用方法", methods)

        guard let experiment = ExperimentCatalog.experiment(id: metadata.experimentID) else { return }
        addSection("App 改值", experiment.appInstructions)
        let open = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Open \(metadata.name) Experiment") { [weak self] _ in
            guard let self else { return }
            self.navigationController?.pushViewController(
                InteractiveExperimentViewController(lesson: self.lesson, experiment: experiment, progressStore: self.progressStore),
                animated: true
            )
        })
        open.accessibilityIdentifier = "open-type-experiment"
        stack.addArrangedSubview(open)
        addSection("LLDB 改值", experiment.lldbCommand)
        addSection("源码改值", "文件：\(experiment.sourceFile)\n\n\(experiment.sourceChange)")
        if let sample = experiment.compilerSample {
            addSection("编译器显微镜", "make compiler-lab SAMPLE=\(sample)\nmake compiler-lab SAMPLE=\(sample) MODE=optimized")
        }
        addSection("唯一下一步", "完成一次 App 操作，再从 LLDB 或源码层重复同一变化并解释证据。")
    }

    private func addSection(_ title: String, _ body: String, style: UIFont.TextStyle = .title3) {
        let heading = UILabel()
        heading.font = .preferredFont(forTextStyle: style)
        heading.adjustsFontForContentSizeCategory = true
        heading.numberOfLines = 0
        heading.text = title
        stack.addArrangedSubview(heading)

        let text = UILabel()
        text.font = .preferredFont(forTextStyle: .body)
        text.textColor = .secondaryLabel
        text.adjustsFontForContentSizeCategory = true
        text.numberOfLines = 0
        text.text = body
        stack.addArrangedSubview(text)
    }
}
