public enum SendState {
    case sending(attempt: Int)
    case sent(serverID: Int)
    case failed(code: Int)
}

@inline(never) public func enumStateMachine(_ state: SendState) -> Int {
    switch state {
    case let .sending(attempt): attempt
    case let .sent(serverID): serverID
    case let .failed(code): -code
    }
}
