import UIKit
import AppsFlyerLib

public class AppfslyerManager: NSObject {
    public var delegate: AppsflyerManagerDelegate?
    public var deeplinkError: Error? = nil
    public var deeplinkResult: [String: String]? {
        get {
            return UserDefaults.standard.object(forKey: deepLinkResultUDKey) as? [String: String]
        }
        set {
            guard deeplinkResult == nil, newValue != nil else {
                return
            }
            
            UserDefaults.standard.set(newValue, forKey: deepLinkResultUDKey)
        }
    }
    
    private var deepLinkResultUDKey = "coreintegrations_appsflyer_deeplinkResult"
    
    public init(config: AppsflyerConfigData) {
        super.init()
        AppsFlyerLib.shared().appsFlyerDevKey = config.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = config.appleAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 30)
#if DEBUG
        AppsFlyerLib.shared().isDebug = true
#else
        AppsFlyerLib.shared().isDebug = false
#endif
    }
    
    private func parseDeepLink(_ conversionInfo: [AnyHashable : Any]) -> [String: String] {
        var appsFlyerProperties = [String: String]()

        var parsingKeys = [
            "media_source": "network",
            "campaign": "campaignName",
            "af_adset": "adGroupName",
            "af_ad": "ad",
            "deep_link_value": "deep_link_value",
            "af_dp": "deep_link_value"
        ]

        for key in conversionInfo.keys {
            if let conversionKey = key as? String, let conversionValue = conversionInfo[key] as? String {
                let keyToSave: String
                if parsingKeys.keys.contains(conversionKey), let newKey = parsingKeys[conversionKey] {
                    keyToSave = newKey
                } else {
                    keyToSave = conversionKey
                }
                appsFlyerProperties[keyToSave] = conversionValue
            }
        }
        
        return appsFlyerProperties
    }
}

extension AppfslyerManager: AppfslyerManagerProtocol {
    public var appsflyerID: String {
        AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    public var customerUserID: String? {
        get {
            return AppsFlyerLib.shared().customerUserID
        }
        set {
            AppsFlyerLib.shared().customerUserID = newValue
        }
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                                   restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppsFlyerLib.shared().registerUninstall(deviceToken)
    }
    
    public func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] ) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    public func startAppsflyer() {
        AppsFlyerLib.shared().start()
    }
    
    public func logTrialPurchase() {
        AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [:])
    }
}

extension AppfslyerManager: AppsFlyerLibDelegate {
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        deeplinkError = nil
        let deepLinkInfo = parseDeepLink(conversionInfo)
        deeplinkResult = deepLinkInfo
        delegate?.handledDeeplink(deepLinkInfo)
        delegate?.coreConfiguration(didReceive: conversionInfo)
    }
    
    public func onConversionDataFail(_ error: Error) {
        self.deeplinkError = error
        delegate?.coreConfiguration(handleDeeplinkError: error)
    }
    
    public func onAppOpenAttributionFailure(_ error: any Error) {
        self.deeplinkError = error
        delegate?.coreConfiguration(handleDeeplinkError: error)
    }
}
