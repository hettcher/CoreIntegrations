
import Foundation

public protocol CoreAnalyticsDataSource {
    associatedtype AnalyticsEvents: CoreAnalyzableEvent
    associatedtype AnalyticsUserProperties: CoreAnalyzableUserProperty
    var allEvents: [AnalyticsEvents] { get }
    var allUserProperties: [AnalyticsUserProperties] { get }
    var customServerURL: String? { get }
    
    var sessionReplayStartOnLaunch: Bool { get }
    var sessionReplaySampleRate: Float { get }
    var sessionReplayEnableRemoteConfig: Bool { get }
}

public extension CoreAnalyticsDataSource {
    var allEvents: [AnalyticsEvents] {
        return AnalyticsEvents.allCases as! [Self.AnalyticsEvents]
    }

    var allUserProperties: [AnalyticsUserProperties] {
        return AnalyticsUserProperties.allCases as! [Self.AnalyticsUserProperties]
    }
    
    var customServerURL: String? {
        return nil
    }
    
    var sessionReplayStartOnLaunch: Bool {
        return false
    }
    
    var sessionReplaySampleRate: Float {
        return 0.0
    }
    
    var sessionReplayEnableRemoteConfig: Bool {
        return false
    }
}

