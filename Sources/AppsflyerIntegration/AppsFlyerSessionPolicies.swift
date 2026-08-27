struct AppsFlyerSessionStartPolicy {
    private var isReady = false
    private var didStart = false

    mutating func sessionBecameReady() {
        isReady = true
        didStart = false
    }

    mutating func sessionBecameUnavailable() {
        isReady = false
    }

    mutating func claimStart() -> Bool {
        guard isReady, didStart == false else {
            return false
        }

        didStart = true
        return true
    }
}

struct AppsFlyerStartOrderingPolicy<Result> {
    private var inFlightStartCount = 0
    private var pendingConversion: Result?

    mutating func beginStart() {
        inFlightStartCount += 1
    }

    mutating func receiveConversion(_ result: Result) -> Result? {
        guard inFlightStartCount > 0 else {
            return result
        }

        pendingConversion = result
        return nil
    }

    mutating func finishStart() -> Result? {
        guard inFlightStartCount > 0 else {
            return nil
        }

        inFlightStartCount -= 1
        guard inFlightStartCount == 0 else {
            return nil
        }

        defer { pendingConversion = nil }
        return pendingConversion
    }
}
