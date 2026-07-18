import UIKit

final class LessonDetailViewController: UIViewController {
    private let lesson: LessonDefinition
    private let progressStore: PracticeProgressStore
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
        title = lesson.title
        view.backgroundColor = .systemBackground
        render()
    }

    private func render() {
        let stack = ExperimentConsoleUI.installScrollableStack(
            in: self,
            accessibilityIdentifier: "lesson-console"
        )
        guard let primary = LearningCatalog.primaryExperiment(for: lesson) else { return }
        stack.addArrangedSubview(ExperimentConsoleUI.descriptorView(primary.console))
        stack.addArrangedSubview(
            ExperimentConsoleUI.experimentButton(
                title: "Open · \(primary.title)",
                identifier: "open-experiment",
                emphasized: true
            ) { [weak self] in
                self?.open(primary)
            }
        )

        let remaining = lessonExperiments().filter { $0.id != primary.id }
        if !remaining.isEmpty {
            stack.addArrangedSubview(
                ExperimentConsoleUI.label("More entries", style: .title3)
            )
        }
        for experiment in remaining {
            stack.addArrangedSubview(
                ExperimentConsoleUI.experimentButton(
                    title: experiment.title,
                    identifier: entryIdentifier(for: experiment),
                    emphasized: false
                ) { [weak self] in
                    self?.open(experiment)
                }
            )
        }

        var configuration = UIButton.Configuration.borderedProminent()
        configuration.title = answerTitle
        answerButton.configuration = configuration
        answerButton.accessibilityIdentifier = "mark-answered"
        answerButton.addTarget(self, action: #selector(markAnswered), for: .touchUpInside)
        stack.addArrangedSubview(answerButton)
    }

    private func lessonExperiments() -> [LearningExperiment] {
        let typeExperiments = LearningCatalog.types(for: lesson)
            .compactMap { ExperimentCatalog.experiment(id: $0.experimentID) }
        let conceptExperiments = LearningCatalog.concepts(for: lesson)
            .compactMap { ExperimentCatalog.experiment(id: $0.experimentID) }
        return typeExperiments + conceptExperiments
    }

    private func entryIdentifier(for experiment: LearningExperiment) -> String {
        if let typeID = experiment.targetTypeID {
            return "type-card-\(typeID)"
        }
        return "concept-\(experiment.targetConceptID ?? experiment.id)"
    }

    private func open(_ experiment: LearningExperiment) {
        navigationController?.pushViewController(
            InteractiveExperimentViewController(
                lesson: lesson,
                experiment: experiment,
                progressStore: progressStore
            ),
            animated: true
        )
    }

    private var answerTitle: String {
        progressStore.progress.hasAnswered(lesson.id)
            ? "已记录回答（不等于掌握）"
            : "我已口头回答 3 道题"
    }

    @objc private func markAnswered() {
        progressStore.recordAnswers(lessonID: lesson.id)
        answerButton.configuration?.title = answerTitle
    }
}
