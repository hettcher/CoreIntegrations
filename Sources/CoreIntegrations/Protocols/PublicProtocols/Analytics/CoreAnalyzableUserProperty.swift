
import Foundation
#if !COCOAPODS
import AnalyticsIntegration
#endif

public protocol CoreAnalyzableUserProperty: CaseIterable, AmplitudeAnalyzableUserProperty {
    
}

public extension CoreAnalyzableUserProperty {
    static func fetchFlags(userProperties: [String: Any] = [:], completion: (() -> Void)?) {
        CoreManager.internalShared.remoteConfigManager?.updateRemoteConfig(userProperties) {
            completion?()
        }
    }
}
