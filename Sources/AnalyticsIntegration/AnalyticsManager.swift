
import UIKit
import AmplitudeSwift
import AmplitudeSwiftSessionReplayPlugin


public class AnalyticsManager {
    var printDebugAnalytics: Bool {
        return true
    }
    
    // MARK: - Properties
    public static var shared = AnalyticsManager()
    
    private var amplitude: Amplitude?
    
    private var sessionReplayPlugin:AmplitudeSwiftSessionReplayPlugin? = nil
    
    // MARK: - MethodsforceEventsUpload
    
    public func configure(data: AmplitudeConfigData) {
        sessionReplayPlugin = AmplitudeSwiftSessionReplayPlugin(sampleRate: data.sessionReplayConfig.sampleRate, enableRemoteConfig: data.sessionReplayConfig.enableRemoteConfig)
        
        if data.sessionReplayConfig.startOnLaunch {
            startSessionReplayRecord()
        }
        
        amplitude = Amplitude(configuration: Configuration(apiKey: data.appKey, autocapture: .all))
        amplitude?.configuration.minTimeBetweenSessionsMillis = 3000
        
        if let customURL = data.customURL, data.cnConfig == true {
            amplitude?.configuration.serverUrl = customURL
        }
    }
    
    
    public func startSessionReplayRecord() {
        if let sessionReplayPlugin = sessionReplayPlugin {
            amplitude?.add(plugin: sessionReplayPlugin)
        } else {
            assertionFailure()
        }
    }
    
    public func stopSessionReplayRecord() {
        if let sessionReplayPlugin = sessionReplayPlugin {
            amplitude?.remove(plugin: sessionReplayPlugin)
        } else {
            assertionFailure()
        }
    }
    
    public func forceEventsUpload() {
        amplitude?.flush()
    }
    
    public func setUserID(_ userID: String) {
        guard userID != amplitude?.getUserId() else {
            return
        }
        
        amplitude?.setUserId(userId: userID)
    }
    
    public func clearUserID() {
        amplitude?.reset()
    }
    
    internal func sendCohort() {
        let userDef = UserDefaults.standard
        guard !userDef.bool(forKey: "isCohortSended") else {
            print("COHORT SENDED")
            return
        }
        print("COHORT NOT SENDED")
        #if DEBUG
        return
        #endif
        userDef.set(true, forKey: "isCohortSended")
        
        let date:Date = Date()
        
        let calendar = Calendar.current
        let monthOfYear = calendar.component(.month, from: date) as Any
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)! as Any
        let weekOfYear = calendar.ordinality(of: .weekOfYear, in: .year, for: date)! as Any
        
        let identify = Identify()
        identify.setOnce(property: "cohort_date", value: dayOfYear)
        identify.setOnce(property: "cohort_week", value: weekOfYear)
        identify.setOnce(property: "cohort_month", value: monthOfYear)
        
        amplitude?.identify(identify: identify)
    }
    
    func saveAttributionDetails(_ attributionDetails: [String : NSObject]?) {
        guard let details = attributionDetails else {
            return
        }
        
        let identify = Identify()
        details.keys.forEach { key in
            identify.set(property: key, value: details[key])
        }
        amplitude?.identify(identify: identify)
    }
    
    func amplitudeLog(event: String, with properties: [String: Any] = [String: Any]()) {
        if properties.isEmpty {
            amplitude?.track(eventType: event)
        } else {
            amplitude?.track(
                eventType: event,
                eventProperties: properties
            )
        }
        
        if printDebugAnalytics {
            if properties.isEmpty {
                print("Amplitude logged \(event.uppercased())")
            } else {
                print("Amplitude logged \(event.uppercased()), properties \(properties)")
            }
        }
        
        amplitude?.flush()
    }
    
    func amplitudeIdentify(key: String, value: NSObject) {
        let identify = Identify().set(property: key, value: value)
        amplitude?.identify(identify: identify)
        
        if printDebugAnalytics {
            print("Amplitude identified property: \(key.uppercased()), value: \(value)")
        }
    }
    
    func amplitudeIncrement(key: String, value: NSObject) {
        let identify = Identify().add(property: key, value: value as? Int ?? 0)
        amplitude?.identify(identify: identify)
        
        if printDebugAnalytics {
            print("Analytics incremented property: \(key.uppercased()), value: \(value)")
        }
    }
    
    func setUserProperties(_ userProperties: [String: Any]) {
        amplitude?.identify(userProperties: userProperties)
    }
}
