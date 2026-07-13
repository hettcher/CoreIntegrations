
import Foundation
#if !COCOAPODS
import AnalyticsIntegration
#endif

public protocol CoreAnalyzableUserProperty: CaseIterable, AmplitudeAnalyzableUserProperty {
//    static var att_status: Self { get }
//    static var store_country: Self { get }
//    static var subscription_type: Self { get }
}

public extension CoreAnalyzableUserProperty {
    static func fetchFlags(userProperties: [String: Any] = [:], completion: (() -> Void)?) {
        CoreManager.internalShared.remoteConfigManager?.updateRemoteConfig(userProperties) {
            completion?()
        }
    }
}
