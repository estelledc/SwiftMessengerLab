public struct PropertyBox {
    public var stored: Int { didSet { changes += 1 } }
    public private(set) var changes = 0
    public var doubled: Int {
        get { stored * 2 }
        set { stored = newValue / 2 }
    }
    public init(_ value: Int) { stored = value }
}

@inline(never) public func propertyAccess(_ input: Int) -> Int {
    var box = PropertyBox(input)
    box.doubled += 4
    return box.doubled + box.changes
}
