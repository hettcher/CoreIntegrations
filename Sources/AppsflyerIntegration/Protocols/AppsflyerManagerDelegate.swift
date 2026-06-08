
import Foundation

public protocol AppsflyerManagerDelegate {
    func handledDeeplink(_ result: [String: String])

    func coreConfiguration(didReceive deepLinkResult: [AnyHashable : Any])
    func coreConfiguration(handleDeeplinkError error: Error)

    /// Called when `AppsFlyerLib.start()` completes. `error` is non-nil when AppsFlyer
    /// failed to start at all (e.g. could not reach the SDK backend).
    func appsflyerStartCompleted(error: Error?)
}

public extension AppsflyerManagerDelegate {
    func appsflyerStartCompleted(error: Error?) {}
}
