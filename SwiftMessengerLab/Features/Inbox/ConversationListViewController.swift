import UIKit

final class ConversationListViewController: UICollectionViewController {
    private enum Section {
        case main
    }

    private let environment: AppEnvironment
    private var dataSource: UICollectionViewDiffableDataSource<Section, UUID>!

    init(environment: AppEnvironment) {
        self.environment = environment
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .none
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Public Messenger Lab"
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.accessibilityIdentifier = "conversation-list"
        configureNavigationItems()
        configureDataSource()
        applySnapshot(animated: false)
        environment.log.record(.lifecycle, "Inbox viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot(animated: false)
        environment.log.record(.lifecycle, "Inbox viewWillAppear")
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let conversationID = dataSource.itemIdentifier(for: indexPath) else { return }
        environment.log.record(.ui, "Inbox didSelect conversation=\(conversationID.short)")
        let chat = ChatViewController(environment: environment, conversationID: conversationID)
        navigationController?.pushViewController(chat, animated: true)
    }

    private func configureNavigationItems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Logs", style: .plain, target: self, action: #selector(showLogs)),
            UIBarButtonItem(title: "Guide", style: .plain, target: self, action: #selector(showGuide))
        ]
    }

    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> {
            [weak self] cell, _, conversationID in
            guard let self, let conversation = environment.repository.conversation(id: conversationID) else { return }
            var content = UIListContentConfiguration.subtitleCell()
            content.text = conversation.title
            let unread = conversation.unreadCount > 0 ? " · \(conversation.unreadCount) unread" : ""
            content.secondaryText = conversation.lastMessagePreview + unread
            content.secondaryTextProperties.numberOfLines = 2
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
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

    private func applySnapshot(animated: Bool) {
        guard dataSource != nil else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(environment.repository.conversations.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: animated)
        environment.log.record(.ui, "Inbox apply snapshot conversations=\(snapshot.numberOfItems)")
    }

    @objc private func showLogs() {
        navigationController?.pushViewController(LogViewController(log: environment.log), animated: true)
    }

    @objc private func showGuide() {
        navigationController?.pushViewController(
            GuideViewController(environment: environment),
            animated: true
        )
    }
}
