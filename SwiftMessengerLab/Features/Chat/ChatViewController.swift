import UIKit

final class ChatViewController: UIViewController, UICollectionViewDelegate {
    private enum Section {
        case messages
    }

    private let environment: AppEnvironment
    private let conversationID: UUID
    private let composer = MessageComposerView()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!
    private var inFlightMessageIDs: Set<UUID> = []

    init(environment: AppEnvironment, conversationID: UUID) {
        self.environment = environment
        self.conversationID = conversationID
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = environment.repository.conversation(id: conversationID)?.title ?? "Chat"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logs",
            style: .plain,
            target: self,
            action: #selector(showLogs)
        )

        configureCollectionView()
        configureComposer()
        configureDataSource()
        environment.repository.markConversationRead(id: conversationID)
        environment.persist()
        applySnapshot(animated: false)
        environment.log.record(.lifecycle, "Chat viewDidLoad conversation=\(conversationID.short)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        environment.log.record(.lifecycle, "Chat viewDidAppear conversation=\(conversationID.short)")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard
            let messageID = dataSource.itemIdentifier(for: indexPath),
            let message = environment.repository.message(id: messageID),
            message.deliveryState == .failed
        else { return }

        environment.log.record(.ui, "Chat retry tap id=\(messageID.short)")
        deliver(messageID: messageID, isRetry: true)
    }

    private func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.accessibilityIdentifier = "message-list"
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }

    private func configureComposer() {
        view.addSubview(composer)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: composer.topAnchor),

            composer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])

        composer.onSend = { [weak self] text in
            self?.submit(text: text)
        }
    }

    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> {
            [weak self] cell, _, messageID in
            guard let self, let message = environment.repository.message(id: messageID) else { return }

            var content = UIListContentConfiguration.subtitleCell()
            content.text = message.text
            content.textProperties.numberOfLines = 0
            let author = message.author == .me ? "You" : "Teammate"
            content.secondaryText = "\(author) · \(message.deliveryState.displayText) · id \(message.id.short)"
            content.secondaryTextProperties.color = message.deliveryState == .failed ? .systemRed : .secondaryLabel
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = message.author == .me
                ? UIColor.systemBlue.withAlphaComponent(0.10)
                : UIColor.secondarySystemBackground
            background.cornerRadius = 12
            background.backgroundInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
            cell.backgroundConfiguration = background
            cell.accessories = message.deliveryState == .failed ? [.disclosureIndicator()] : []
            cell.accessibilityIdentifier = message.deliveryState == .failed
                ? "failed-message"
                : "message-\(message.id.short)"
        }

        dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: itemIdentifier
            )
        }
    }

    private func submit(text: String) {
        environment.log.record(.ui, "Composer send text=\(text.debugDescription)")
        let message = environment.repository.enqueueOutgoing(text: text, conversationID: conversationID)
        environment.persist()
        applySnapshot(animated: true)
        deliver(messageID: message.id, isRetry: false)
    }

    private func deliver(messageID: UUID, isRetry: Bool) {
        guard !inFlightMessageIDs.contains(messageID) else { return }
        inFlightMessageIDs.insert(messageID)

        Task { [weak self] in
            guard let self else { return }
            await environment.delivery.deliver(
                messageID: messageID,
                isRetry: isRetry,
                stateDidChange: { [weak self] in
                    guard let self else { return }
                    environment.persist()
                    applySnapshot(animated: true)
                }
            )
            inFlightMessageIDs.remove(messageID)
        }
    }

    private func applySnapshot(animated: Bool) {
        let messages = environment.repository.messages(conversationID: conversationID)
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.messages])
        snapshot.appendItems(messages.map(\.id))
        snapshot.reconfigureItems(messages.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            guard let self, !messages.isEmpty else { return }
            collectionView.scrollToItem(
                at: IndexPath(item: messages.count - 1, section: 0),
                at: .bottom,
                animated: animated
            )
        }
        let lastState = messages.last?.deliveryState.rawValue ?? "empty"
        environment.log.record(.ui, "Chat apply snapshot count=\(messages.count) last=\(lastState)")
    }

    @objc private func showLogs() {
        navigationController?.pushViewController(LogViewController(log: environment.log), animated: true)
    }
}
