public struct ValueCounter { public var value: Int }
public final class ReferenceCounter {
    public var value: Int
    public init(_ value: Int) { self.value = value }
}

@inline(never) public func valueAndReference(_ input: Int) -> Int {
    let original = ValueCounter(value: input)
    var copy = original
    copy.value += 1
    let first = ReferenceCounter(input)
    let second = first
    second.value += 1
    return original.value + copy.value + first.value
}
