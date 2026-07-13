import UIKit

final class LessonDetailViewController: UIViewController {
    private let lesson: LessonDefinition
    private let progressStore: PracticeProgressStore
    private let stack = UIStackView()
    private let answerButton = UIButton(type: .system)

    init(lesson: LessonDefinition, progressStore: PracticeProgressStore) {
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
        title = "Lesson \(lesson.id)"
        view.backgroundColor = .systemBackground
        configureLayout()
        renderLesson()
    }

    private func configureLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.accessibilityIdentifier = "lesson-scroll"
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func renderLesson() {
        addLabel(lesson.title, style: .title1, color: .label)
        addLabel("30–45 分钟 · 核心验收：\(lesson.coreAbility)", style: .headline, color: .secondaryLabel)

        for concept in LearningCatalog.concepts(for: lesson) {
            addSection("语言概念 · \(concept.name)", "日常类比：\(concept.analogy)\n\n技术定义：\(concept.definition)\n\n最小代码：\n\(concept.minimalExample)\n\n检索：\(concept.retrievalQuestion)")
            addExperimentButton(title: "练习 \(concept.name)", experimentID: concept.experimentID, identifier: "concept-\(concept.id)")
        }

        let types = LearningCatalog.types(for: lesson)
        if !types.isEmpty {
            addSection("本课类型卡", "点击类型进入属性、方法、所有权及 App / LLDB / 源码三层实验。")
            for (index, metadata) in types.enumerated() {
                let button = UIButton(configuration: index == 0 ? .filled() : .bordered(), primaryAction: UIAction(title: "\(metadata.name) · \(metadata.kind.rawValue)") { [weak self] _ in
                    guard let self else { return }
                    self.navigationController?.pushViewController(
                        TypeDetailViewController(metadata: metadata, lesson: self.lesson, progressStore: self.progressStore),
                        animated: true
                    )
                })
                button.accessibilityIdentifier = "type-card-\(metadata.id)"
                stack.addArrangedSubview(button)
            }
        }

        if let primary = LearningCatalog.primaryExperiment(for: lesson) {
            addSection("先预测", primary.predictionPrompt)
            addExperimentButton(title: "Open Interactive Experiment", experimentID: primary.id, identifier: "open-experiment")
        }

        addSection("常见误区", lesson.misconceptions.map { "• \($0)" }.joined(separator: "\n"))
        addSection("检索题", lesson.retrievalQuestions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

        var configuration = UIButton.Configuration.borderedProminent()
        configuration.title = answerTitle
        answerButton.configuration = configuration
        answerButton.accessibilityIdentifier = "mark-answered"
        answerButton.addTarget(self, action: #selector(markAnswered), for: .touchUpInside)
        stack.addArrangedSubview(answerButton)
        addSection("唯一下一步", lesson.nextStep)
    }

    private func addExperimentButton(title: String, experimentID: String, identifier: String) {
        let button = UIButton(configuration: .bordered(), primaryAction: UIAction(title: title) { [weak self] _ in
            guard let self, let experiment = ExperimentCatalog.experiment(id: experimentID) else { return }
            self.navigationController?.pushViewController(
                InteractiveExperimentViewController(lesson: self.lesson, experiment: experiment, progressStore: self.progressStore),
                animated: true
            )
        })
        button.accessibilityIdentifier = identifier
        stack.addArrangedSubview(button)
    }

    private var answerTitle: String {
        progressStore.progress.hasAnswered(lesson.id) ? "已记录回答（不等于掌握）" : "我已口头回答 3 道题"
    }

    @objc private func markAnswered() {
        progressStore.recordAnswers(lessonID: lesson.id)
        answerButton.configuration?.title = answerTitle
    }

    private func addSection(_ title: String, _ body: String) {
        addLabel(title, style: .title3, color: .label)
        addLabel(body, style: .body, color: .secondaryLabel)
    }

    private func addLabel(_ text: String, style: UIFont.TextStyle, color: UIColor) {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = text
        stack.addArrangedSubview(label)
    }
}
