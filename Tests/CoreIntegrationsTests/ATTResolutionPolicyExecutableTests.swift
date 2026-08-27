import Foundation

private enum TestATTStatus: Equatable {
    case notDetermined
    case denied
    case authorized
}

private final class TestATTResolutionCancellation {
    private(set) var isCancelled = false

    func cancel() {
        isCancelled = true
    }
}

private func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fatalError(message)
    }
}

@main
private struct ATTResolutionPolicyExecutableTests {
    static func main() {
        var resolvedByPolling = ATTResolutionPolicy(notDetermined: TestATTStatus.notDetermined)

        require(resolvedByPolling.receive(.notDetermined, source: .poll) == nil,
                "Polling must keep waiting while ATT is not determined")
        require(resolvedByPolling.isResolved == false,
                "An unresolved poll must not release the ATT flow")
        require(resolvedByPolling.receive(.authorized, source: .poll) == .authorized,
                "Polling must preserve the terminal ATT status")
        require(resolvedByPolling.isResolved,
                "A terminal status must release the ATT flow")
        require(resolvedByPolling.receive(.denied, source: .callback) == nil,
                "Late callback must not release an already resolved flow twice")

        var resolvedByTimeout = ATTResolutionPolicy(notDetermined: TestATTStatus.notDetermined)
        require(resolvedByTimeout.receive(.notDetermined, source: .timeout) == .notDetermined,
                "The hard fallback must release an eternally not-determined flow")
        require(resolvedByTimeout.receive(.authorized, source: .callback) == nil,
                "A late Allow after fallback must not produce a second resolution")

        var currentATTStatus = TestATTStatus.notDetermined
        var authorizationRequestCount = 0
        var authorizationCallback: ((TestATTStatus) -> Void)?
        var scheduledActions: [(delay: TimeInterval, action: () -> Void)] = []
        var observedTerminalStatuses: [TestATTStatus] = []
        var acceptedResolutions: [ATTResolution<TestATTStatus>] = []

        let coordinator = ATTResolutionCoordinator(
            notDetermined: TestATTStatus.notDetermined,
            statusProvider: { currentATTStatus },
            requestAuthorization: { callback in
                authorizationRequestCount += 1
                authorizationCallback = callback
            },
            schedule: { delay, action in
                let cancellation = TestATTResolutionCancellation()
                scheduledActions.append((delay: delay, action: action))
                return ATTResolutionCancellation(cancel: cancellation.cancel)
            },
            onTerminalStatusObserved: { observedTerminalStatuses.append($0) },
            onResolved: { acceptedResolutions.append($0) }
        )

        coordinator.startDefaultFlow()
        require(authorizationRequestCount == 1,
                "The default ATT flow must request authorization once")
        require(scheduledActions.map(\.delay) == [0.5, 5.0],
                "The ATT flow must schedule 0.5-second polling and a 5-second fallback")

        scheduledActions[1].action()
        require(acceptedResolutions.count == 1,
                "The hard fallback must resolve the coordinator exactly once")
        require(acceptedResolutions[0].status == .notDetermined,
                "The hard fallback must preserve an eternally not-determined status")
        require(acceptedResolutions[0].source == .timeout,
                "The hard fallback must identify timeout as the resolution source")

        coordinator.startDefaultFlow()
        require(authorizationRequestCount == 1,
                "A configuration retry must not re-arm an already resolved ATT request")
        require(acceptedResolutions.count == 1,
                "A configuration retry must not produce a second ATT resolution")

        authorizationCallback?(.authorized)
        require(acceptedResolutions.count == 1,
                "A late authorization callback must not resolve after fallback")

        currentATTStatus = .authorized
        coordinator.startDefaultFlow()
        require(observedTerminalStatuses == [.authorized],
                "A late terminal OS status may refresh analytics without re-resolving ATT")
        require(acceptedResolutions.count == 1,
                "Observing a late terminal OS status must not restart downstream configuration")

        print("ATTResolutionPolicyExecutableTests: PASS")
    }
}
