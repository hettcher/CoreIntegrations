import UIKit
import AppsflyerIntegration

private final class LegacyAppsflyerManagerMock: AppfslyerManagerProtocol {
    var appsflyerID = ""
    var customerUserID: String?
    var deeplinkResult: [String: String]?
    var delegate: AppsflyerManagerDelegate?
    var deeplinkError: Error?

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) {}

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        false
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}

    func startAppsflyer() {}
    func logTrialPurchase() {}
}

private final class LegacyAppsflyerDelegateMock: AppsflyerManagerDelegate {
    func handledDeeplink(_ result: [String: String]) {}

    func coreConfiguration(didReceive deepLinkResult: [AnyHashable: Any]) {}

    func coreConfiguration(handleDeeplinkError error: Error) {}
}

private func typecheckLegacyPublicCalls() {
    let config = AppsflyerConfigData(appsFlyerDevKey: "dev-key", appleAppID: "123456789")
    let manager = AppfslyerManager(config: config)
    _ = LegacyAppsflyerManagerMock()
    _ = LegacyAppsflyerDelegateMock()
    manager.onAppOpenAttributionFailure(NSError(domain: "legacy", code: 1))
}
