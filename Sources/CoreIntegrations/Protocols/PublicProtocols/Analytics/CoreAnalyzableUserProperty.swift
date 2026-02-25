
import Foundation
#if !COCOAPODS
import AnalyticsIntegration
#endif

public protocol CoreAnalyzableUserProperty: CaseIterable, AmplitudeAnalyzableUserProperty {
    
}

public extension CoreAnalyzableUserProperty {
    static func fetchFlags(numberOfTimes: Int = 1, userProperties: [String: Any] = [:],
                           flagKeys: [String] = [], completion: (() -> Void)?) {
        let group = DispatchGroup()
        
        for _ in 0..<numberOfTimes {
            group.enter()
            CoreManager.internalShared.remoteConfigManager?.updateRemoteConfig(userProperties, flagKeys: flagKeys) {
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            completion?()
        }
    }
}
