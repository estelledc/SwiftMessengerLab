import UIKit

final class MessageComposerView: UIView, UITextFieldDelegate {
    var onSend: ((String) -> Void)?

    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderStyle = .roundedRect
        field.placeholder = "Message or /fail"
        field.returnKeyType = .send
        field.accessibilityIdentifier = "message-input"
        return field
    }()

    private lazy var sendButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Send"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "send-button"
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        textField.delegate = self

        addSubview(textField)
        addSubview(sendButton)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 42),

            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return false
    }

    @objc func sendTapped() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        textField.text = ""
        textField.resignFirstResponder()
        onSend?(text)
    }
}
