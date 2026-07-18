import UIKit

final class LearningCatalogViewController: UITableViewController, UISearchResultsUpdating {
    private let progressStore: PracticeProgressStore
    private var typeResults: [TypeMetadata] = []

    init(progressStore: PracticeProgressStore) {
        self.progressStore = progressStore
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Learn"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        tableView.accessibilityIdentifier = "learning-catalog"

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "搜索类型、属性或方法"
        search.searchBar.searchTextField.accessibilityIdentifier = "type-search"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reset Progress",
            style: .plain,
            target: self,
            action: #selector(confirmResetProgress)
        )
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "reset-learning-progress"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private var isSearching: Bool {
        !(navigationItem.searchController?.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else {
            typeResults = []
            tableView.reloadData()
            return
        }

        typeResults = TypeCatalog.all.filter { metadata in
            let searchable = [
                metadata.name,
                metadata.module,
                metadata.kind.rawValue,
                metadata.purpose,
                metadata.properties.map(\.name).joined(separator: " "),
                metadata.methods.map(\.signature).joined(separator: " ")
            ].joined(separator: " ")
            return searchable.localizedCaseInsensitiveContains(query)
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? typeResults.count : LearningCatalog.lessons.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        var content = UIListContentConfiguration.cell()

        if isSearching {
            let metadata = typeResults[indexPath.row]
            content.text = metadata.name
            cell.accessibilityIdentifier = "type-search-result-\(metadata.id)"
        } else {
            let lesson = LearningCatalog.lessons[indexPath.row]
            content.text = String(format: "%02d · %@", lesson.id, lesson.title)
            cell.accessibilityIdentifier = "lesson-\(lesson.id)"
        }

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            let metadata = typeResults[indexPath.row]
            guard
                let lesson = LearningCatalog.lesson(containingTypeID: metadata.id),
                let experiment = ExperimentCatalog.experiment(id: metadata.experimentID)
            else { return }
            openExperiment(experiment, lesson: lesson)
        } else {
            let lesson = LearningCatalog.lessons[indexPath.row]
            navigationController?.pushViewController(
                LessonDetailViewController(lesson: lesson, progressStore: progressStore),
                animated: true
            )
        }
    }

    private func openExperiment(_ experiment: LearningExperiment, lesson: LessonDefinition) {
        navigationController?.pushViewController(
            InteractiveExperimentViewController(
                lesson: lesson,
                experiment: experiment,
                progressStore: progressStore
            ),
            animated: true
        )
    }

    @objc private func confirmResetProgress() {
        let alert = UIAlertController(
            title: "Reset Learning Progress?",
            message: "只清除 direct workload 的已操作记录与已回答记录；Messenger 消息不受影响。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.progressStore.resetLearningProgress()
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
}
