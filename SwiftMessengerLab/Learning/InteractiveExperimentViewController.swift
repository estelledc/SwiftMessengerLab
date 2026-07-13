import UIKit

private struct ExperimentSnapshot {
    let step = 1
    let text = "Hello, Swift"
    let alpha = 1.0
    let isHidden = false
    let colorIndex = 0
    let isEnabled = true
    let taps = 0
    let stateIndex = 0
    let itemIDs = [
        UUID(uuidString: "40000000-0000-0000-0000-000000000001")!,
        UUID(uuidString: "40000000-0000-0000-0000-000000000002")!,
        UUID(uuidString: "40000000-0000-0000-0000-000000000003")!
    ]
}

@objcMembers
final class ExperimentState: NSObject {
    dynamic var step = 1
    dynamic var text = "Hello, Swift"
    dynamic var alpha = 1.0
    dynamic var isHidden = false
    dynamic var colorIndex = 0
    dynamic var isEnabled = true
    dynamic var taps = 0
    dynamic var stateIndex = 0
    var itemIDs: [UUID] = []

    fileprivate func restore(_ snapshot: ExperimentSnapshot) {
        step = snapshot.step
        text = snapshot.text
        alpha = snapshot.alpha
        isHidden = snapshot.isHidden
        colorIndex = snapshot.colorIndex
        isEnabled = snapshot.isEnabled
        taps = snapshot.taps
        stateIndex = snapshot.stateIndex
        itemIDs = snapshot.itemIDs
    }
}

final class InteractiveExperimentViewController: UIViewController, UITextFieldDelegate {
    private let lesson: LessonDefinition
    private let experiment: LearningExperiment
    private let progressStore: PracticeProgressStore
    private let defaultState = ExperimentSnapshot()
    private let rootStack = UIStackView()
    private let experimentStack = UIStackView()
    private let logLabel = UILabel()
    private var previewView: UIView?
    private var viewStatusLabel: UILabel?
    private var actionButton: UIButton?
    private var actionCountLabel: UILabel?
    private var inputField: UITextField?
    private var collectionDataSource: UICollectionViewDiffableDataSource<Int, UUID>?
    private var collectionStatusLabel: UILabel?
    private var lastProbeIdentifier: String?
    private var events: [String] = []

    // 在此属性上打断点后可用：po experimentState / expr experimentState.step += 1
    private(set) var experimentState = ExperimentState()

    init(
        lesson: LessonDefinition,
        experiment: LearningExperiment,
        progressStore: PracticeProgressStore
    ) {
        self.lesson = lesson
        self.experiment = experiment
        self.progressStore = progressStore
        super.init(nibName: nil, bundle: nil)
        experimentState.restore(defaultState)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = experiment.title
        view.backgroundColor = .systemBackground
        configureLayout()
        rebuildExperiment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let lastProbeIdentifier else { return }
        appendEvent("returned from probe · same id \(lastProbeIdentifier)")
    }

    private func configureLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.axis = .vertical
        rootStack.spacing = 16
        experimentStack.axis = .vertical
        experimentStack.spacing = 12
        logLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        logLabel.numberOfLines = 0
        logLabel.textColor = .secondaryLabel
        logLabel.accessibilityIdentifier = "experiment-log"

        let prediction = makeLabel("先预测\n\(experiment.predictionPrompt)", style: .headline)
        let reset = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Reset Experiment") { [weak self] _ in
            self?.resetExperiment()
        })
        reset.accessibilityIdentifier = "experiment-reset"

        view.addSubview(scrollView)
        scrollView.addSubview(rootStack)
        rootStack.addArrangedSubview(prediction)
        rootStack.addArrangedSubview(experimentStack)
        rootStack.addArrangedSubview(logLabel)
        rootStack.addArrangedSubview(reset)
        rootStack.addArrangedSubview(makeLabel(experiment.resetExpectation, style: .footnote))

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            rootStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            rootStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            rootStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func rebuildExperiment() {
        experimentStack.arrangedSubviews.forEach {
            experimentStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        previewView = nil
        viewStatusLabel = nil
        actionButton = nil
        actionCountLabel = nil
        inputField = nil
        collectionDataSource = nil
        collectionStatusLabel = nil

        switch experiment.control {
        case .valueStepper, .propertyObserver, .valueReference:
            configureValueExperiment()
        case .text, .ownership, .foundation:
            configureTextExperiment()
        case .viewAppearance:
            configureViewExperiment()
        case .navigation:
            configureNavigationExperiment()
        case .button:
            configureButtonExperiment()
        case .textInput:
            configureTextInputExperiment()
        case .collection:
            configureCollectionExperiment()
        case .stateMachine, .concurrency:
            configureStateMachineExperiment()
        }
        refreshLog()
    }

    private func configureValueExperiment() {
        let value = makeLabel("value = \(experimentState.step)\ndoubled (get-only) = \(experimentState.step * 2)", style: .title2)
        value.accessibilityIdentifier = "experiment-status"
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 10
        stepper.value = Double(experimentState.step)
        stepper.accessibilityIdentifier = "value-stepper"
        stepper.addAction(UIAction { [weak self, weak value] action in
            guard let self, let stepper = action.sender as? UIStepper else { return }
            self.experimentState.step = Int(stepper.value)
            value?.text = "value = \(self.experimentState.step)\ndoubled (get-only) = \(self.experimentState.step * 2)"
            self.recordOperation("set value -> didSet -> read doubled")
        }, for: .valueChanged)
        experimentStack.addArrangedSubview(value)
        experimentStack.addArrangedSubview(stepper)
    }

    private func configureTextExperiment() {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.text = experimentState.text
        field.placeholder = "Change a String"
        field.accessibilityIdentifier = "text-value-field"
        let output = makeLabel("isEmpty = \(experimentState.text.isEmpty)", style: .body)
        output.accessibilityIdentifier = "experiment-status"
        let apply = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Apply Text") { [weak self, weak field, weak output] _ in
            guard let self else { return }
            self.experimentState.text = field?.text ?? ""
            output?.text = "count = \(self.experimentState.text.count) · isEmpty = \(self.experimentState.text.isEmpty)"
            self.recordOperation("text changed; get-only count recalculated")
        })
        experimentStack.addArrangedSubview(field)
        experimentStack.addArrangedSubview(apply)
        experimentStack.addArrangedSubview(output)
    }

    private func configureViewExperiment() {
        let canvas = UIView()
        canvas.backgroundColor = .secondarySystemBackground
        canvas.layer.cornerRadius = 12
        canvas.heightAnchor.constraint(equalToConstant: 150).isActive = true
        let preview = UIView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.layer.cornerRadius = 12
        preview.accessibilityIdentifier = "experiment-preview"
        canvas.addSubview(preview)
        NSLayoutConstraint.activate([
            preview.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            preview.centerYAnchor.constraint(equalTo: canvas.centerYAnchor),
            preview.widthAnchor.constraint(equalToConstant: 110),
            preview.heightAnchor.constraint(equalToConstant: 80)
        ])
        previewView = preview
        let status = makeLabel("", style: .body)
        status.accessibilityIdentifier = "view-state-status"
        viewStatusLabel = status
        applyViewState()

        let alpha = UISlider()
        alpha.minimumValue = 0.1
        alpha.maximumValue = 1
        alpha.value = Float(experimentState.alpha)
        alpha.widthAnchor.constraint(equalToConstant: 220).isActive = true
        alpha.accessibilityLabel = "Alpha"
        alpha.accessibilityIdentifier = "alpha-slider"
        alpha.addAction(UIAction { [weak self] action in
            guard let self, let slider = action.sender as? UISlider else { return }
            self.experimentState.alpha = Double(slider.value)
            self.applyViewState()
            self.recordOperation(String(format: "alpha = %.2f", slider.value))
        }, for: .valueChanged)

        let colors = UISegmentedControl(items: ["Blue", "Orange", "Green"])
        colors.selectedSegmentIndex = experimentState.colorIndex
        colors.accessibilityIdentifier = "color-control"
        colors.addAction(UIAction { [weak self] action in
            guard let self, let control = action.sender as? UISegmentedControl else { return }
            self.experimentState.colorIndex = control.selectedSegmentIndex
            self.applyViewState()
            self.recordOperation("backgroundColor changed")
        }, for: .valueChanged)

        let hidden = UISwitch()
        hidden.isOn = experimentState.isHidden
        hidden.accessibilityLabel = "isHidden"
        hidden.accessibilityIdentifier = "hidden-switch"
        hidden.addAction(UIAction { [weak self] action in
            guard let self, let toggle = action.sender as? UISwitch else { return }
            self.experimentState.isHidden = toggle.isOn
            self.applyViewState()
            self.recordOperation("isHidden = \(toggle.isOn)")
        }, for: .valueChanged)

        experimentStack.addArrangedSubview(canvas)
        experimentStack.addArrangedSubview(status)
        experimentStack.addArrangedSubview(makeRow("alpha", alpha))
        experimentStack.addArrangedSubview(colors)
        experimentStack.addArrangedSubview(makeRow("isHidden", hidden))
    }

    private func applyViewState() {
        let colors: [UIColor] = [.systemBlue, .systemOrange, .systemGreen]
        previewView?.alpha = experimentState.alpha
        previewView?.isHidden = experimentState.isHidden
        previewView?.backgroundColor = colors[experimentState.colorIndex]
        viewStatusLabel?.text = String(
            format: "alpha = %.2f · color = %d · isHidden = %@",
            experimentState.alpha,
            experimentState.colorIndex,
            experimentState.isHidden.description
        )
    }

    private func configureNavigationExperiment() {
        let status = makeLabel("stack depth = \(navigationController?.viewControllers.count ?? 0)\n尚未 push probe", style: .body)
        status.accessibilityIdentifier = "navigation-status"
        let push = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Push Probe Page") { [weak self, weak status] _ in
            guard let self else { return }
            let probe = NavigationProbeViewController(log: { [weak self] event in
                self?.appendEvent(event)
            })
            let identifier = String(describing: ObjectIdentifier(probe))
            self.lastProbeIdentifier = identifier
            status?.text = "before push depth = \(self.navigationController?.viewControllers.count ?? 0)\nprobe id = \(identifier)"
            self.recordOperation("push probe id \(identifier)")
            self.navigationController?.pushViewController(probe, animated: true)
        })
        push.accessibilityIdentifier = "push-probe"
        experimentStack.addArrangedSubview(status)
        experimentStack.addArrangedSubview(push)
    }

    private func configureButtonExperiment() {
        let enabled = UISwitch()
        enabled.isOn = experimentState.isEnabled
        enabled.accessibilityLabel = "isEnabled"
        enabled.accessibilityIdentifier = "button-enabled-switch"
        let count = makeLabel("action count = \(experimentState.taps)", style: .title3)
        count.accessibilityIdentifier = "action-count"
        actionCountLabel = count
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Send Action"
        button.isEnabled = experimentState.isEnabled
        button.accessibilityIdentifier = "action-button"
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton = button
        enabled.addAction(UIAction { [weak self] action in
            guard let self, let toggle = action.sender as? UISwitch else { return }
            self.experimentState.isEnabled = toggle.isOn
            self.actionButton?.isEnabled = toggle.isOn
            self.recordOperation("isEnabled = \(toggle.isOn); state is get-only")
        }, for: .valueChanged)
        experimentStack.addArrangedSubview(makeRow("isEnabled", enabled))
        experimentStack.addArrangedSubview(button)
        experimentStack.addArrangedSubview(count)
    }

    @objc private func actionButtonTapped() {
        experimentState.taps += 1
        actionCountLabel?.text = "action count = \(experimentState.taps)"
        recordOperation("touchUpInside action fired")
    }

    private func configureTextInputExperiment() {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "Type, then press Return"
        field.text = experimentState.text
        field.returnKeyType = .done
        field.delegate = self
        field.accessibilityIdentifier = "input-field"
        field.addTarget(self, action: #selector(textEditingChanged(_:)), for: .editingChanged)
        inputField = field

        let focus = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Become First Responder") { [weak self] _ in
            let accepted = self?.inputField?.becomeFirstResponder() ?? false
            self?.recordOperation("becomeFirstResponder -> \(accepted)")
        })
        focus.accessibilityIdentifier = "focus-button"
        let resign = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Resign First Responder") { [weak self] _ in
            let accepted = self?.inputField?.resignFirstResponder() ?? false
            self?.recordOperation("resignFirstResponder -> \(accepted)")
        })
        resign.accessibilityIdentifier = "resign-button"
        experimentStack.addArrangedSubview(field)
        experimentStack.addArrangedSubview(focus)
        experimentStack.addArrangedSubview(resign)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        appendEvent("1 delegate shouldChange")
        return true
    }

    @objc private func textEditingChanged(_ sender: UITextField) {
        experimentState.text = sender.text ?? ""
        recordOperation("2 UIControl editingChanged")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        appendEvent("3 delegate shouldReturn")
        let result = textField.resignFirstResponder()
        appendEvent("4 resignFirstResponder -> \(result)")
        return true
    }

    private func configureCollectionExperiment() {
        let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.heightAnchor.constraint(equalToConstant: 250).isActive = true
        collection.accessibilityIdentifier = "experiment-collection"
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> { cell, _, id in
            var content = cell.defaultContentConfiguration()
            content.text = "item \(id.uuidString.suffix(4))"
            content.secondaryText = id.uuidString
            cell.contentConfiguration = content
        }
        collectionDataSource = UICollectionViewDiffableDataSource<Int, UUID>(collectionView: collection) { collection, indexPath, id in
            collection.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: id)
        }
        let status = makeLabel("", style: .body)
        status.accessibilityIdentifier = "collection-status"
        collectionStatusLabel = status
        let refresh = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Refresh Same IDs") { [weak self] _ in
            guard let self else { return }
            self.experimentState.itemIDs.reverse()
            self.applyCollectionSnapshot()
            self.recordOperation("snapshot refreshed; identity preserved")
        })
        refresh.accessibilityIdentifier = "collection-refresh"
        let add = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Add Unique Item") { [weak self] _ in
            guard let self else { return }
            self.experimentState.itemIDs.append(UUID())
            self.applyCollectionSnapshot()
            self.recordOperation("one unique id appended")
        })
        add.accessibilityIdentifier = "collection-add"
        experimentStack.addArrangedSubview(collection)
        experimentStack.addArrangedSubview(status)
        experimentStack.addArrangedSubview(refresh)
        experimentStack.addArrangedSubview(add)
        applyCollectionSnapshot()
    }

    private func applyCollectionSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(experimentState.itemIDs, toSection: 0)
        collectionDataSource?.apply(snapshot, animatingDifferences: false)
        let uniqueCount = Set(experimentState.itemIDs).count
        collectionStatusLabel?.text = "items = \(experimentState.itemIDs.count) · unique ids = \(uniqueCount)"
    }

    private func configureStateMachineExperiment() {
        let states = ["sending", "sent", "failed"]
        let status = makeLabel("state = \(states[experimentState.stateIndex])", style: .title2)
        status.accessibilityIdentifier = "experiment-status"
        let advance = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Advance State") { [weak self, weak status] _ in
            guard let self else { return }
            self.experimentState.stateIndex = (self.experimentState.stateIndex + 1) % states.count
            status?.text = "state = \(states[self.experimentState.stateIndex])"
            self.recordOperation("switch handled \(states[self.experimentState.stateIndex])")
        })
        experimentStack.addArrangedSubview(status)
        experimentStack.addArrangedSubview(advance)
    }

    private func resetExperiment() {
        experimentState.restore(defaultState)
        events = ["reset current experiment only"]
        lastProbeIdentifier = nil
        rebuildExperiment()
    }

    private func recordOperation(_ event: String) {
        progressStore.recordOperation(experimentID: experiment.id)
        appendEvent(event)
        LabLogStore.shared.record(.learning, "lesson=\(lesson.id) experiment=\(experiment.id) \(event)")
    }

    private func appendEvent(_ event: String) {
        events.append(event)
        refreshLog()
    }

    private func refreshLog() {
        logLabel.text = events.isEmpty ? "日志会记录操作顺序。" : events.suffix(8).joined(separator: "\n")
    }

    private func makeLabel(_ text: String, style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = text
        return label
    }

    private func makeRow(_ title: String, _ control: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [makeLabel(title, style: .body), control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }
}

private final class NavigationProbeViewController: UIViewController {
    private let log: (String) -> Void

    init(log: @escaping (String) -> Void) {
        self.log = log
        super.init(nibName: nil, bundle: nil)
        title = "Probe"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Probe object\n\(ObjectIdentifier(self))\nUse Back to pop the same instance."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.accessibilityIdentifier = "probe-screen"
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        log("probe viewDidLoad · \(ObjectIdentifier(self))")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log("probe viewWillAppear · \(ObjectIdentifier(self))")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log("probe viewDidDisappear · \(ObjectIdentifier(self))")
    }

    deinit {
        log("probe deinit")
    }
}
