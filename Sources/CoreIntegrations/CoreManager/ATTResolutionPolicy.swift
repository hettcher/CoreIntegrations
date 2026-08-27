import Foundation

enum ATTResolutionSource: Equatable {
    case currentStatus
    case callback
    case poll
    case timeout
    case external
}

struct ATTResolutionPolicy<Status: Equatable> {
    let notDetermined: Status
    private(set) var isResolved = false

    mutating func receive(_ status: Status, source: ATTResolutionSource) -> Status? {
        guard isResolved == false else {
            return nil
        }
        guard status != notDetermined || source == .timeout else {
            return nil
        }

        isResolved = true
        return status
    }
}
