
import Foundation
#if !COCOAPODS
import AnalyticsIntegration
#endif

public protocol CoreAnalyzableUserProperty: CaseIterable, AmplitudeAnalyzableUserProperty {
    
}

public extension CoreAnalyzableUserProperty {
    static func identify(_ userProperties: [String: Any], fetchFlags: Bool, numberOfTimes: Int = 1, completion: (() -> Void)?) {
        identify(userProperties)
        
        guard fetchFlags else {
            completion?()
            return
        }
        
        let group = DispatchGroup()
        
        for _ in 0..<numberOfTimes {
            group.enter()
            CoreManager.internalShared.remoteConfigManager?.updateRemoteConfig(userProperties) {
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            completion?()
        }
    }
    
    func identify(parameter: String, fetchFlags: Bool, numberOfTimes: Int = 1, completion: (() -> Void)?) {
        identify(parameter: parameter)
        
        guard fetchFlags else {
            completion?()
            return
        }
        
        let group = DispatchGroup()

        for _ in 0..<numberOfTimes {
            group.enter()
            CoreManager.internalShared.remoteConfigManager?.updateRemoteConfig([key: parameter]) {
                group.leave()
            }
        }
        
        group.notify(queue: .global()) {
            completion?()
        }
    }
}
