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
    UUID(uuidString: "40000000-0000-0000-0000-000000000003")!,
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
  private var rootStack: UIStackView!
  private let experimentStack = UIStackView()
  private let logLabel = UILabel()
  private var previewView: UIView?
  private var viewStatusLabel: UILabel?
  private var propertyStatusLabel: UILabel?
  private var propertyBoxProbe: PropertyBox?
  private var propertyLazyWasRead = false
  private var valueReferenceStatusLabel: UILabel?
  private var originalValueCounterProbe: ValueCounter?
  private var copiedValueCounterProbe: ValueCounter?
  private var referenceCounterProbe: ReferenceCounter?
  private var referenceAliasProbe: ReferenceCounter?
  private var textValueField: UITextField?
  private var textValueStatusLabel: UILabel?
  private var messageDraftProbe: MessageDraft?
  private var stateStatusLabel: UILabel?
  private var dictionaryStatusLabel: UILabel?
  private var repositoryStatusLabel: UILabel?
  private var repositoryProbe: MessageRepository?
  private var foundationStatusLabel: UILabel?
  private var foundationProbe: FoundationRoundTripProbe?
  private var actionButton: UIButton?
  private var actionCountLabel: UILabel?
  private var inputField: UITextField?
  private var collectionDataSource: UICollectionViewDiffableDataSource<Int, UUID>?
  private var collectionStatusLabel: UILabel?
  private var lastProbeIdentifier: String?
  private var events: [String] = []
  private var ownershipProbe: CaptureOwner?
  private weak var weakOwnershipProbe: CaptureOwner?
  private var concurrencyTask: Task<Void, Never>?

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

  deinit {
    foundationProbe?.reset()
    concurrencyTask?.cancel()
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
    rootStack = ExperimentConsoleUI.installScrollableStack(
      in: self,
      accessibilityIdentifier: "experiment-console"
    )
    experimentStack.axis = .vertical
    experimentStack.spacing = 12
    logLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    logLabel.numberOfLines = 0
    logLabel.textColor = .secondaryLabel
    logLabel.accessibilityIdentifier = "experiment-log"

    let reset = ExperimentConsoleUI.button(
      title: "Reset Experiment",
      identifier: "experiment-reset",
      emphasized: false
    ) { [weak self] in
      self?.resetExperiment()
    }

    rootStack.addArrangedSubview(ExperimentConsoleUI.descriptorView(experiment.console))
    rootStack.addArrangedSubview(experimentStack)
    rootStack.addArrangedSubview(makeLabel("Live operation log", style: .title3))
    rootStack.addArrangedSubview(logLabel)
    rootStack.addArrangedSubview(reset)
  }

  private func rebuildExperiment() {
    concurrencyTask?.cancel()
    concurrencyTask = nil
    foundationProbe?.reset()
    foundationProbe = nil
    ownershipProbe = nil
    weakOwnershipProbe = nil
    for subview in experimentStack.arrangedSubviews {
      experimentStack.removeArrangedSubview(subview)
      subview.removeFromSuperview()
    }
    previewView = nil
    viewStatusLabel = nil
    propertyStatusLabel = nil
    propertyBoxProbe = nil
    propertyLazyWasRead = false
    valueReferenceStatusLabel = nil
    originalValueCounterProbe = nil
    copiedValueCounterProbe = nil
    referenceCounterProbe = nil
    referenceAliasProbe = nil
    textValueField = nil
    textValueStatusLabel = nil
    messageDraftProbe = nil
    stateStatusLabel = nil
    dictionaryStatusLabel = nil
    repositoryStatusLabel = nil
    repositoryProbe = nil
    foundationStatusLabel = nil
    actionButton = nil
    actionCountLabel = nil
    inputField = nil
    collectionDataSource = nil
    collectionStatusLabel = nil

    switch experiment.control {
    case .valueStepper:
      configureValueExperiment()
    case .propertyObserver:
      configurePropertyExperiment()
    case .valueReference:
      configureValueReferenceExperiment()
    case .text:
      configureTextExperiment()
    case .ownership:
      configureOwnershipExperiment()
    case .foundation:
      configureFoundationExperiment()
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
    case .dictionary:
      configureDictionaryExperiment()
    case .repository:
      configureRepositoryExperiment()
    case .stateMachine:
      configureStateMachineExperiment()
    case .concurrency:
      configureConcurrencyExperiment()
    }
    refreshLog()
  }

  private func configureValueExperiment() {
    let value = makeLabel(
      "value = \(experimentState.step)\ndoubled (get-only) = \(experimentState.step * 2)",
      style: .title2)
    value.accessibilityIdentifier = "experiment-status"
    let stepper = UIStepper()
    stepper.minimumValue = 0
    stepper.maximumValue = 10
    stepper.value = Double(experimentState.step)
    stepper.accessibilityIdentifier = "value-stepper"
    stepper.addAction(
      UIAction { [weak self, weak value] action in
        guard let self, let stepper = action.sender as? UIStepper else { return }
        self.experimentState.step = Int(stepper.value)
        value?.text =
          "value = \(self.experimentState.step)\ndoubled (get-only) = \(self.experimentState.step * 2)"
        self.recordOperation("set value -> didSet -> read doubled")
      }, for: .valueChanged)
    experimentStack.addArrangedSubview(value)
    experimentStack.addArrangedSubview(stepper)
  }

  private func configurePropertyExperiment() {
    let box = PropertyBox()
    propertyBoxProbe = box
    propertyLazyWasRead = false

    let status = makeLabel("", style: .title3)
    status.accessibilityIdentifier = "property-status"
    propertyStatusLabel = status

    let increment = UIButton(configuration: .filled())
    increment.configuration?.title = "Increment stored"
    increment.accessibilityIdentifier = "property-increment"
    increment.addTarget(self, action: #selector(incrementPropertyProbe), for: .touchUpInside)

    let readLazy = UIButton(configuration: .bordered())
    readLazy.configuration?.title = "Read lazyText"
    readLazy.accessibilityIdentifier = "property-read-lazy"
    readLazy.addTarget(self, action: #selector(readPropertyLazyText), for: .touchUpInside)

    refreshPropertyStatus()
    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(increment)
    experimentStack.addArrangedSubview(readLazy)
  }

  @objc private func incrementPropertyProbe() {
    guard let propertyBoxProbe else { return }
    propertyBoxProbe.stored += 1
    experimentState.step = propertyBoxProbe.stored
    refreshPropertyStatus()
    recordOperation("PropertyBox stored changed -> didSet -> doubled recalculated")
  }

  @objc private func readPropertyLazyText() {
    guard let propertyBoxProbe else { return }
    _ = propertyBoxProbe.lazyText
    propertyLazyWasRead = true
    refreshPropertyStatus()
    recordOperation("PropertyBox lazyText initialized once")
  }

  private func refreshPropertyStatus() {
    guard let propertyBoxProbe else { return }
    let lazyText = propertyLazyWasRead ? propertyBoxProbe.lazyText : "not read"
    propertyStatusLabel?.text = [
      "stored = \(propertyBoxProbe.stored) · doubled = \(propertyBoxProbe.doubled)",
      "didSet = \(propertyBoxProbe.didSetCount) · lazy = \(lazyText)",
    ].joined(separator: "\n")
  }

  private func configureValueReferenceExperiment() {
    originalValueCounterProbe = ValueCounter(value: 1)
    copiedValueCounterProbe = originalValueCounterProbe
    referenceCounterProbe = ReferenceCounter(value: 1)
    referenceAliasProbe = referenceCounterProbe

    let status = makeLabel("", style: .title3)
    status.accessibilityIdentifier = "value-reference-status"
    valueReferenceStatusLabel = status

    let mutate = UIButton(configuration: .filled())
    mutate.configuration?.title = "Mutate Copy + Alias"
    mutate.accessibilityIdentifier = "value-reference-mutate"
    mutate.addTarget(self, action: #selector(mutateValueReferenceProbes), for: .touchUpInside)

    refreshValueReferenceStatus()
    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(mutate)
  }

  @objc private func mutateValueReferenceProbes() {
    guard
      var copiedValueCounterProbe,
      let referenceAliasProbe
    else { return }

    copiedValueCounterProbe.increment()
    self.copiedValueCounterProbe = copiedValueCounterProbe
    referenceAliasProbe.increment()
    experimentState.step = copiedValueCounterProbe.value
    refreshValueReferenceStatus()
    recordOperation(
      "ValueCounter copy changed independently; ReferenceCounter alias shared one instance")
  }

  private func refreshValueReferenceStatus() {
    guard
      let originalValueCounterProbe,
      let copiedValueCounterProbe,
      let referenceCounterProbe,
      let referenceAliasProbe
    else { return }

    valueReferenceStatusLabel?.text = [
      "struct original = \(originalValueCounterProbe.value) · copy = \(copiedValueCounterProbe.value)",
      "class original = \(referenceCounterProbe.value) · alias = \(referenceAliasProbe.value)",
      "same class instance = \(referenceCounterProbe === referenceAliasProbe)",
    ].joined(separator: "\n")
  }

  private func configureTextExperiment() {
    let field = UITextField()
    field.borderStyle = .roundedRect
    field.text = experimentState.text
    field.placeholder = "Change a String"
    field.accessibilityIdentifier = "text-value-field"
    textValueField = field
    messageDraftProbe = MessageDraft(text: experimentState.text)

    let output = makeLabel("", style: .body)
    output.accessibilityIdentifier = "experiment-status"
    textValueStatusLabel = output

    let apply = UIButton(configuration: .filled())
    apply.configuration?.title = "Apply Text"
    apply.accessibilityIdentifier = "text-apply"
    apply.addTarget(self, action: #selector(applyTextProbe), for: .touchUpInside)

    refreshTextProbeStatus()
    experimentStack.addArrangedSubview(field)
    experimentStack.addArrangedSubview(apply)
    experimentStack.addArrangedSubview(output)
  }

  @objc private func applyTextProbe() {
    let text = textValueField?.text ?? ""
    experimentState.text = text
    messageDraftProbe = MessageDraft(text: text)
    view.endEditing(true)
    refreshTextProbeStatus()
    recordOperation("MessageDraft text changed; trimmedText and isSendable recalculated")
  }

  private func refreshTextProbeStatus() {
    guard let messageDraftProbe else { return }
    textValueStatusLabel?.text = [
      "count = \(messageDraftProbe.text.count) · isEmpty = \(messageDraftProbe.text.isEmpty)",
      "trimmed = \(messageDraftProbe.trimmedText) · isSendable = \(messageDraftProbe.isSendable)",
    ].joined(separator: "\n")
  }

  private func configureOwnershipExperiment() {
    let status = makeLabel("owner = nil · weak = nil", style: .body)
    status.accessibilityIdentifier = "ownership-status"

    let create = UIButton(
      configuration: .filled(),
      primaryAction: UIAction(title: "Create Owner + Weak Callback") { [weak self, weak status] _ in
        guard let self else { return }
        let owner = CaptureOwner()
        owner.installWeakCallback()
        ownershipProbe = owner
        weakOwnershipProbe = owner
        owner.callback?()
        status?.text = "owner.label = \(owner.label) · weak alive = \(weakOwnershipProbe != nil)"
        recordOperation("owner created; callback captured self weakly")
      }
    )
    create.accessibilityIdentifier = "ownership-create"

    let release = UIButton(
      configuration: .bordered(),
      primaryAction: UIAction(title: "Release Strong Owner") { [weak self, weak status] _ in
        guard let self else { return }
        ownershipProbe = nil
        status?.text = "strong owner released · weak nil = \(weakOwnershipProbe == nil)"
        recordOperation("strong owner released; weak reference became nil")
      }
    )
    release.accessibilityIdentifier = "ownership-release"

    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(create)
    experimentStack.addArrangedSubview(release)
  }

  private func configureFoundationExperiment() {
    let status = makeLabel("No cache probe has run.", style: .body)
    status.accessibilityIdentifier = "foundation-status"
    foundationStatusLabel = status
    foundationProbe = FoundationRoundTripProbe()

    let run = UIButton(
      configuration: .filled(),
      primaryAction: UIAction(title: "Save + Load JSON Snapshot") { [weak self] _ in
        self?.runFoundationRoundTrip()
      }
    )
    run.accessibilityIdentifier = "foundation-run"
    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(run)
  }

  private func runFoundationRoundTrip() {
    guard let foundationProbe else { return }

    do {
      let result = try foundationProbe.run(snapshot: SampleInbox.snapshot)
      foundationStatusLabel?.text = [
        "file = \(result.fileURL.lastPathComponent)",
        "bytes = \(result.byteCount)",
        "messages = \(result.restoredSnapshot.messages.count)",
      ].joined(separator: " · ")
      recordOperation("Foundation UUID/Date/URL/Data/FileManager/JSONInboxCache round-trip succeeded")
    } catch {
      foundationStatusLabel?.text = "Foundation probe failed: \(error)"
      appendEvent("foundation workload failed · no operated evidence")
    }
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
      preview.heightAnchor.constraint(equalToConstant: 80),
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
    alpha.addAction(
      UIAction { [weak self] action in
        guard let self, let slider = action.sender as? UISlider else { return }
        self.experimentState.alpha = Double(slider.value)
        self.applyViewState()
        self.recordOperation(String(format: "alpha = %.2f", slider.value))
      }, for: .valueChanged)

    let colors = UISegmentedControl(items: ["Blue", "Orange", "Green"])
    colors.selectedSegmentIndex = experimentState.colorIndex
    colors.accessibilityIdentifier = "color-control"
    colors.addAction(
      UIAction { [weak self] action in
        guard let self, let control = action.sender as? UISegmentedControl else { return }
        self.experimentState.colorIndex = control.selectedSegmentIndex
        self.applyViewState()
        self.recordOperation("backgroundColor changed")
      }, for: .valueChanged)

    let hidden = UISwitch()
    hidden.isOn = experimentState.isHidden
    hidden.accessibilityLabel = "isHidden"
    hidden.accessibilityIdentifier = "hidden-switch"
    hidden.addAction(
      UIAction { [weak self] action in
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
    let status = makeLabel(
      "stack depth = \(navigationController?.viewControllers.count ?? 0)\n尚未 push probe",
      style: .body)
    status.accessibilityIdentifier = "navigation-status"
    let push = UIButton(
      configuration: .filled(),
      primaryAction: UIAction(title: "Push Probe Page") { [weak self, weak status] _ in
        guard let self else { return }
        let probe = NavigationProbeViewController(log: { [weak self] event in
          self?.appendEvent(event)
        })
        let identifier = String(describing: ObjectIdentifier(probe))
        self.lastProbeIdentifier = identifier
        status?.text =
          "before push depth = \(self.navigationController?.viewControllers.count ?? 0)\nprobe id = \(identifier)"
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
    enabled.addAction(
      UIAction { [weak self] action in
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

    let focus = UIButton(
      configuration: .bordered(),
      primaryAction: UIAction(title: "Become First Responder") { [weak self] _ in
        let accepted = self?.inputField?.becomeFirstResponder() ?? false
        self?.recordOperation("becomeFirstResponder -> \(accepted)")
      })
    focus.accessibilityIdentifier = "focus-button"
    let resign = UIButton(
      configuration: .bordered(),
      primaryAction: UIAction(title: "Resign First Responder") { [weak self] _ in
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
    let layout = UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))
    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.heightAnchor.constraint(equalToConstant: 250).isActive = true
    collection.accessibilityIdentifier = "experiment-collection"
    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> {
      cell, _, id in
      var content = cell.defaultContentConfiguration()
      content.text = "item \(id.uuidString.suffix(4))"
      content.secondaryText = id.uuidString
      cell.contentConfiguration = content
    }
    collectionDataSource = UICollectionViewDiffableDataSource<Int, UUID>(collectionView: collection)
    { collection, indexPath, id in
      collection.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: id)
    }
    let status = makeLabel("", style: .body)
    status.accessibilityIdentifier = "collection-status"
    collectionStatusLabel = status
    let refresh = UIButton(
      configuration: .bordered(),
      primaryAction: UIAction(title: "Refresh Same IDs") { [weak self] _ in
        guard let self else { return }
        self.experimentState.itemIDs.reverse()
        self.applyCollectionSnapshot()
        self.recordOperation("snapshot refreshed; identity preserved")
      })
    refresh.accessibilityIdentifier = "collection-refresh"
    let add = UIButton(
      configuration: .bordered(),
      primaryAction: UIAction(title: "Add Unique Item") { [weak self] _ in
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
    collectionStatusLabel?.text =
      "items = \(experimentState.itemIDs.count) · unique ids = \(uniqueCount)"
  }

  private func configureDictionaryExperiment() {
    let status = makeLabel("Dictionary workload has not run.", style: .body)
    status.accessibilityIdentifier = "dictionary-status"
    dictionaryStatusLabel = status

    let run = UIButton(configuration: .filled())
    run.configuration?.title = "Run Key/Value Workload"
    run.accessibilityIdentifier = "dictionary-run"
    run.addTarget(self, action: #selector(runDictionaryWorkload), for: .touchUpInside)

    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(run)
  }

  @objc private func runDictionaryWorkload() {
    let result = DictionaryEvidenceWorkload.run()
    dictionaryStatusLabel?.text = [
      "update queued: \(result.previousQueuedCount ?? 0) -> \(result.removedQueuedCount ?? 0)",
      "sent = \(result.sentCount) · failed = \(result.failedCount)",
      "keys = \(result.sortedKeys.joined(separator: ", "))",
    ].joined(separator: "\n")
    recordOperation("Dictionary updateValue/default/merge/remove completed")
  }

  private func configureRepositoryExperiment() {
    let repository = MessageRepository(snapshot: SampleInbox.snapshot)
    repositoryProbe = repository

    let status = makeLabel(
      "messages = \(repository.snapshot.messages.count) · no outgoing probe",
      style: .body
    )
    status.accessibilityIdentifier = "repository-status"
    repositoryStatusLabel = status

    let run = UIButton(configuration: .filled())
    run.configuration?.title = "Enqueue Outgoing Message"
    run.accessibilityIdentifier = "repository-run"
    run.addTarget(self, action: #selector(runRepositoryWorkload), for: .touchUpInside)

    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(run)
  }

  @objc private func runRepositoryWorkload() {
    guard let repositoryProbe else { return }
    let beforeCount = repositoryProbe.snapshot.messages.count
    let text = "repository evidence \(beforeCount + 1)"
    let message = repositoryProbe.enqueueOutgoing(
      text: text,
      conversationID: SampleInbox.designID,
      date: Date(timeIntervalSince1970: 1_786_001_100 + Double(beforeCount))
    )
    let afterCount = repositoryProbe.snapshot.messages.count
    let preview = repositoryProbe.conversation(id: SampleInbox.designID)?.lastMessagePreview ?? "missing"
    repositoryStatusLabel?.text = [
      "messages = \(beforeCount) -> \(afterCount)",
      "id = \(message.id.short) · state = \(message.deliveryState.rawValue)",
      "preview = \(preview)",
    ].joined(separator: "\n")
    recordOperation("MessageRepository.enqueueOutgoing appended queued message and updated preview")
  }

  private func configureStateMachineExperiment() {
    let status = makeLabel("", style: .title2)
    status.accessibilityIdentifier = "experiment-status"
    stateStatusLabel = status

    let advance = UIButton(configuration: .filled())
    advance.configuration?.title = "Advance State"
    advance.accessibilityIdentifier = "state-advance"
    advance.addTarget(self, action: #selector(advanceDeliveryState), for: .touchUpInside)

    refreshDeliveryStateStatus()
    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(advance)
  }

  @objc private func advanceDeliveryState() {
    experimentState.stateIndex = (experimentState.stateIndex + 1) % deliveryStateCycle.count
    refreshDeliveryStateStatus()
    recordOperation("switch handled \(currentDeliveryState.rawValue)")
  }

  private var deliveryStateCycle: [DeliveryState] {
    [.sending, .sent, .failed]
  }

  private var currentDeliveryState: DeliveryState {
    deliveryStateCycle[experimentState.stateIndex]
  }

  private func refreshDeliveryStateStatus() {
    stateStatusLabel?.text = "state = \(currentDeliveryState.rawValue)"
  }

  private func configureConcurrencyExperiment() {
    let status = makeLabel("state = idle", style: .title2)
    status.accessibilityIdentifier = "concurrency-status"

    let run = UIButton(
      configuration: .filled(),
      primaryAction: UIAction(title: "Run Async Transport") { [weak self, weak status] _ in
        guard let self else { return }
        concurrencyTask?.cancel()
        status?.text = "state = sending"
        appendEvent("Task started; waiting for MessageTransport.send")

        let message = Message(
          id: UUID(uuidString: "50000000-0000-0000-0000-000000000001")!,
          conversationID: SampleInbox.designID,
          author: .me,
          text: "concurrency probe",
          createdAt: Date(timeIntervalSince1970: 1_786_001_000),
          deliveryState: .sending
        )
        let transport: any MessageTransport = MockMessageTransport(delayNanoseconds: 150_000_000)

        concurrencyTask = Task { @MainActor [weak self, weak status] in
          do {
            let receipt = try await transport.send(message, isRetry: false)
            guard !Task.isCancelled else { return }
            self?.experimentState.stateIndex = 1
            status?.text = "state = sent · \(receipt.serverID)"
            self?.recordOperation(
              "MessageTransport.send completed through protocol existential; resumed on MainActor")
          } catch {
            guard !Task.isCancelled else { return }
            self?.experimentState.stateIndex = 2
            status?.text = "state = failed · \(error)"
            self?.recordOperation("MessageTransport.send executed and threw \(error)")
          }
        }
      }
    )
    run.accessibilityIdentifier = "concurrency-run"
    experimentStack.addArrangedSubview(status)
    experimentStack.addArrangedSubview(run)
  }

  private func resetExperiment() {
    foundationProbe?.reset()
    experimentState.restore(defaultState)
    events = ["reset current experiment only"]
    lastProbeIdentifier = nil
    rebuildExperiment()
  }

  private func recordOperation(_ event: String) {
    let evidenceEvent: String
    if experiment.recordsOperationEvidence, let token = experiment.evidenceToken {
      progressStore.recordOperation(experimentID: experiment.id)
      evidenceEvent = "\(token) · \(event)"
    } else {
      evidenceEvent = "related-observation:\(experiment.id) · \(event) · no operated evidence"
    }
    appendEvent(evidenceEvent)
    LabLogStore.shared.record(
      .learning,
      "lesson=\(lesson.id) experiment=\(experiment.id) \(evidenceEvent)"
    )
  }

  private func appendEvent(_ event: String) {
    events.append(event)
    refreshLog()
  }

  private func refreshLog() {
    logLabel.text = events.isEmpty ? "日志会记录操作顺序。" : events.suffix(8).joined(separator: "\n")
  }

  private func makeLabel(_ text: String, style: UIFont.TextStyle) -> UILabel {
    ExperimentConsoleUI.label(text, style: style)
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
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
