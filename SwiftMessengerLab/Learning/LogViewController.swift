import UIKit

final class LogViewController: UITableViewController {
    private let log: LabLogStore
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    init(log: LabLogStore) {
        self.log = log
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Experiment Logs"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearLogs)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if !log.events.isEmpty {
            tableView.scrollToRow(
                at: IndexPath(row: log.events.count - 1, section: 0),
                at: .bottom,
                animated: false
            )
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.events.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let event = log.events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = "\(formatter.string(from: event.date))  [\(event.category.rawValue)]"
        content.secondaryText = event.message
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    @objc private func clearLogs() {
        log.clear()
        tableView.reloadData()
    }
}

