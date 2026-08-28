
import Foundation

public protocol AppsflyerManagerDelegate {
    func handledDeeplink(_ result: [String: String])
    
    func coreConfiguration(didReceive deepLinkResult: [AnyHashable : Any])
    func coreConfiguration(handleDeeplinkError error: Error)

    /// Called when the SDK failed to send the session. Without this a failed start is
    /// invisible: the SDK reports nothing and every install silently disappears.
    ///
    /// - Parameter shouldReport: `true` only for the first failure on an install where the
    ///   SDK has never started successfully. Crash/error reporting has to be skipped when
    ///   this is `false` - an outage on the AppsFlyer side would otherwise have every user
    ///   reporting on every launch. Everything else still has to run on every failure.
    func appsflyerSessionStartFailed(_ error: Error, shouldReport: Bool)
}

public extension AppsflyerManagerDelegate {
    func appsflyerSessionStartFailed(_ error: Error, shouldReport: Bool) {}
}
