import Foundation

/// Small public types used by the lessons so the learner can edit real source instead of metadata only.
public final class PropertyBox {
    public var stored: Int = 1 {
        didSet { didSetCount += 1 }
    }
    public var doubled: Int { stored * 2 }
    public lazy var lazyText = "created from stored=\(stored)"
    public private(set) var didSetCount = 0

    public init() {}
}

public struct MessageDraft: Equatable, Sendable {
    public var text: String
    public var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    public var isSendable: Bool { !trimmedText.isEmpty }

    public init(text: String) {
        self.text = text
    }

    public mutating func clear() {
        text = ""
    }
}

public struct ValueCounter: Equatable, Sendable {
    public var value: Int

    public init(value: Int = 0) {
        self.value = value
    }

    public mutating func increment() {
        value += 1
    }
}

public final class ReferenceCounter: @unchecked Sendable {
    public var value: Int

    public init(value: Int = 0) {
        self.value = value
    }

    public func increment() {
        value += 1
    }
}

public final class CaptureOwner {
    public var label = "alive"
    public var callback: (() -> Void)?

    public init() {}

    public func installWeakCallback() {
        callback = { [weak self] in
            self?.label = "called weakly"
        }
    }

    deinit {
        callback = nil
    }
}
