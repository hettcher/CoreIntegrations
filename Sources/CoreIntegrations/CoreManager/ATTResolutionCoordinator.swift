import Foundation

struct ATTResolution<Status> {
    let status: Status
    let source: ATTResolutionSource
}

struct ATTResolutionCancellation {
    private let cancelClosure: () -> Void

    init(cancel: @escaping () -> Void) {
        cancelClosure = cancel
    }

    func cancel() {
        cancelClosure()
    }
}

final class ATTResolutionCoordinator<Status: Equatable> {
    typealias StatusProvider = () -> Status
    typealias AuthorizationRequest = (@escaping (Status) -> Void) -> Void
    typealias Scheduler = (_ delay: TimeInterval,
                           _ action: @escaping () -> Void) -> ATTResolutionCancellation

    private let notDetermined: Status
    private let statusProvider: StatusProvider
    private let requestAuthorization: AuthorizationRequest
    private let schedule: Scheduler
    private let onTerminalStatusObserved: (Status) -> Void
    private let onResolved: (ATTResolution<Status>) -> Void

    private var policy: ATTResolutionPolicy<Status>
    private var isAuthorizationRequestInFlight = false
    private var pollingCancellation: ATTResolutionCancellation?
    private var fallbackCancellation: ATTResolutionCancellation?

    init(notDetermined: Status,
         statusProvider: @escaping StatusProvider,
         requestAuthorization: @escaping AuthorizationRequest,
         schedule: @escaping Scheduler,
         onTerminalStatusObserved: @escaping (Status) -> Void,
         onResolved: @escaping (ATTResolution<Status>) -> Void) {
        self.notDetermined = notDetermined
        self.statusProvider = statusProvider
        self.requestAuthorization = requestAuthorization
        self.schedule = schedule
        self.onTerminalStatusObserved = onTerminalStatusObserved
        self.onResolved = onResolved
        policy = ATTResolutionPolicy(notDetermined: notDetermined)
    }

    func startDefaultFlow() {
        MainQueueExecutor.perform { [weak self] in
            self?.startDefaultFlowOnMain()
        }
    }

    func resolveExternally(_ status: Status) {
        let source: ATTResolutionSource = status == notDetermined ? .timeout : .external
        receive(status, source: source)
    }

    private func startDefaultFlowOnMain() {
        let currentStatus = statusProvider()
        if currentStatus != notDetermined {
            onTerminalStatusObserved(currentStatus)
        }

        guard policy.isResolved == false else {
            return
        }

        if currentStatus != notDetermined {
            receiveOnMain(currentStatus, source: .currentStatus)
            return
        }

        guard isAuthorizationRequestInFlight == false else {
            return
        }
        isAuthorizationRequestInFlight = true

        schedulePoll()
        fallbackCancellation = schedule(5) { [weak self] in
            guard let self else { return }
            self.receive(self.statusProvider(), source: .timeout)
        }

        requestAuthorization { [weak self] status in
            self?.receive(status, source: .callback)
        }
    }

    private func schedulePoll() {
        pollingCancellation = schedule(0.5) { [weak self] in
            guard let self else { return }
            MainQueueExecutor.perform { [weak self] in
                guard let self, self.policy.isResolved == false else {
                    return
                }

                let status = self.statusProvider()
                if status == self.notDetermined {
                    self.pollingCancellation = nil
                    self.schedulePoll()
                } else {
                    self.receiveOnMain(status, source: .poll)
                }
            }
        }
    }

    private func receive(_ status: Status, source: ATTResolutionSource) {
        MainQueueExecutor.perform { [weak self] in
            self?.receiveOnMain(status, source: source)
        }
    }

    private func receiveOnMain(_ status: Status, source: ATTResolutionSource) {
        guard policy.receive(status, source: source) != nil else {
            return
        }

        pollingCancellation?.cancel()
        fallbackCancellation?.cancel()
        pollingCancellation = nil
        fallbackCancellation = nil
        isAuthorizationRequestInFlight = false
        onResolved(ATTResolution(status: status, source: source))
    }
}

extension ATTResolutionCoordinator {
    static func scheduleOnMain(after delay: TimeInterval,
                               action: @escaping () -> Void) -> ATTResolutionCancellation {
        let workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        return ATTResolutionCancellation(cancel: workItem.cancel)
    }
}
