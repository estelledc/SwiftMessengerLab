import UIKit

final class GuideViewController: UIViewController {
    private let environment: AppEnvironment
    private let resultLabel = ExperimentConsoleUI.label(
        "Status\n等待操作；发送结果见消息列表，调用顺序见 Logs。",
        style: .body,
        identifier: "guide-result"
    )

    private let descriptor = ExperimentConsoleDescriptor(
        goal: "用同一个 message id 观察 queued → sending → failed → retry → sent。",
        sourceCue: ExperimentSourceCue(
            file: "SwiftMessengerLab/Features/Chat/ChatViewController.swift",
            symbol: "submit(text:)"
        ),
        xcodeAction: "在 ChatViewController.submit(text:) 设置断点，发送 /fail 后查看 Call Stack。",
        expectedResult: "失败重试不新增消息；同一 id 最终从 failed 变为 sent。",
        docsPath: "docs/guided-learning.md"
    )

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messenger Experiment"
        view.backgroundColor = .systemBackground

        let stack = ExperimentConsoleUI.installScrollableStack(
            in: self,
            accessibilityIdentifier: "messenger-console"
        )
        stack.addArrangedSubview(ExperimentConsoleUI.descriptorView(descriptor))
        stack.addArrangedSubview(
            ExperimentConsoleUI.button(
                title: "Open Message Lab",
                identifier: "guide-open-message-lab",
                emphasized: true
            ) { [weak self] in
                guard let self else { return }
                navigationController?.pushViewController(
                    ChatViewController(
                        environment: environment,
                        conversationID: SampleInbox.designID
                    ),
                    animated: true
                )
            }
        )
        stack.addArrangedSubview(
            ExperimentConsoleUI.button(
                title: "View Logs",
                identifier: "guide-view-logs",
                emphasized: false
            ) { [weak self] in
                guard let self else { return }
                navigationController?.pushViewController(
                    LogViewController(log: environment.log),
                    animated: true
                )
            }
        )
        stack.addArrangedSubview(
            ExperimentConsoleUI.button(
                title: "Reset Messenger Data",
                identifier: "guide-reset-messenger",
                emphasized: false
            ) { [weak self] in
                self?.confirmReset()
            }
        )
        stack.addArrangedSubview(resultLabel)
    }

    private func confirmReset() {
        let alert = UIAlertController(
            title: "Reset Messenger Data?",
            message: "This replaces local conversations and messages with the public sample. Learning progress is unchanged.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self else { return }
            environment.resetMessengerData()
            resultLabel.text = "Status\nMessenger 已恢复为 public sample；学习进度未改变。"
        })
        present(alert, animated: true)
    }
}
