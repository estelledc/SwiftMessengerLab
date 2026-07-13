public protocol Scoring { func score(_ value: Int) -> Int }
public struct WitnessScore: Scoring { public func score(_ value: Int) -> Int { value + 1 } }
open class BaseScore { public init() {} ; open func score(_ value: Int) -> Int { value + 2 } }
public final class ChildScore: BaseScore { public override func score(_ value: Int) -> Int { value + 3 } }
public final class DirectScore { public init() {} ; public func score(_ value: Int) -> Int { value + 4 } }

@inline(never) public func methodDispatch(_ value: Int) -> Int {
    let witness: any Scoring = WitnessScore()
    let base: BaseScore = ChildScore()
    return witness.score(value) + base.score(value) + DirectScore().score(value)
}
