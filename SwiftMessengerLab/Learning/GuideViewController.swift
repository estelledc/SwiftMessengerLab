import UIKit

final class GuideViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Guided Experiment"
        view.backgroundColor = .systemBackground

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.adjustsFontForContentSizeCategory = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = """
        Session 2 · Send Success

        1. Predict the order before tapping Send.
        2. Send normal text and watch sending -> sent.
        3. Open Logs and find UI -> Repository -> Transport -> Repository -> UI.

        Session 3 · Failure and Retry

        1. Send /fail.
        2. Wait for failed · tap to retry.
        3. Tap the failed message.
        4. Confirm the same message becomes sent without a duplicate row.

        Two observation rounds

        Round 1: Logs prove event order.
        Round 2: breakpoints and Call Stack prove who called whom.

        Full questions and breakpoints are in docs/guided-learning.md.
        """

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

