import UIKit

@MainActor
enum ExperimentConsoleUI {
    static func installScrollableStack(
        in viewController: UIViewController,
        accessibilityIdentifier: String
    ) -> UIStackView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.accessibilityIdentifier = accessibilityIdentifier

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16

        viewController.view.addSubview(scrollView)
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
        return stack
    }

    static func descriptorView(_ descriptor: ExperimentConsoleDescriptor) -> UIStackView {
        let card = UIStackView(arrangedSubviews: [
            label(
                "Goal · \(descriptor.goal)",
                style: .headline,
                identifier: "console-goal"
            ),
            label(
                "Code · \(descriptor.sourceCue.displayText)",
                style: .subheadline,
                identifier: "console-source-cue"
            ),
            label(
                "Xcode · \(descriptor.xcodeAction)",
                style: .subheadline,
                identifier: "console-xcode-action"
            ),
            label(
                "Docs · \(descriptor.docsPath)",
                style: .footnote,
                color: .secondaryLabel,
                identifier: "console-docs-path"
            )
        ])
        card.axis = .vertical
        card.spacing = 8
        card.isLayoutMarginsRelativeArrangement = true
        card.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        return card
    }

    static func experimentButton(
        title: String,
        identifier: String,
        emphasized: Bool,
        action: @escaping () -> Void
    ) -> UIButton {
        var configuration: UIButton.Configuration = emphasized ? .filled() : .bordered()
        configuration.title = title
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 14,
            bottom: 12,
            trailing: 14
        )

        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { _ in action() }
        )
        button.accessibilityIdentifier = identifier
        button.accessibilityLabel = title
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        return button
    }

    static func button(
        title: String,
        identifier: String,
        emphasized: Bool,
        action: @escaping () -> Void
    ) -> UIButton {
        var configuration: UIButton.Configuration = emphasized ? .filled() : .bordered()
        configuration.title = title
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { _ in action() }
        )
        button.accessibilityIdentifier = identifier
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

    static func label(
        _ text: String,
        style: UIFont.TextStyle,
        color: UIColor = .label,
        identifier: String? = nil
    ) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = text
        label.accessibilityIdentifier = identifier
        return label
    }
}
