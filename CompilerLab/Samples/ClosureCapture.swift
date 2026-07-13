public final class CaptureOwner {
    public var value: Int
    public init(_ value: Int) { self.value = value }
    public func strongClosure() -> () -> Int { { self.value } }
    public func weakClosure() -> () -> Int { { [weak self] in self?.value ?? -1 } }
}

@inline(never) public func closureCapture(_ input: Int) -> Int {
    let owner = CaptureOwner(input)
    let strong = owner.strongClosure()
    let weak = owner.weakClosure()
    return strong() + weak()
}
