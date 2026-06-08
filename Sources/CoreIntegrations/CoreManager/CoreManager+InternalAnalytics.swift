
import Foundation
#if !COCOAPODS
import FirebaseIntegration
import AnalyticsIntegration
import AppsflyerIntegration
#endif
import StoreKit

extension CoreManager {
    func sendAppEnvironmentProperty() {
        InternalUserProperty.app_environment.identify(parameter: AppEnvironment.current.rawValue)
    }
    
    func sendFirstLaunchEvent() {
        InternalAnalyticsEvent.first_launch.log()
        analyticsManager?.forceEventsUpload()
    }
    
    func sendAttEvent(answer: Bool) {
        sendATTProperty(answer: answer)
        InternalAnalyticsEvent.att_permission.log(parameter: answer)
        analyticsManager?.forceEventsUpload()
    }
    
    func sendATTProperty(answer: Bool) {
        InternalUserProperty.att_status.identify(parameter: "\(answer)")
    }
    
    func sendDeepLinkUserProperties(deepLinkResult: [String: String]) {
        let userProperties = deepLinkResult
        InternalUserProperty.identify(userProperties)
    }

    private var internetStatus: [String: String] {
        return ["connection": "\(networkMonitor.isConnected)",
                "connection_type": networkMonitor.currentConnectionType?.description ?? "unexpected"]
    }

    func sendConfigurationStarted(status: [String: String]) {
        InternalAnalyticsEvent.framework_attribution_started.log(parameters: status + internetStatus)
        analyticsManager?.forceEventsUpload()
    }

    func sendUserAttribution(userAttribution: [String: String], status: [String: String]) {
        guard userAttribution.isEmpty == false else {
            InternalAnalyticsEvent.framework_attribution.log(parameters: status + internetStatus)
            analyticsManager?.forceEventsUpload()
            return
        }

        InternalUserProperty.identify(userAttribution)
        InternalAnalyticsEvent.framework_attribution.log(parameters: userAttribution + status + internetStatus)
        analyticsManager?.forceEventsUpload()
    }

    func sendUserAttributionUpdate(userAttribution: [String: String]) {
        guard userAttribution.isEmpty == false else { return }

        InternalUserProperty.identify(userAttribution)
        InternalAnalyticsEvent.framework_attribution_update.log(parameters: userAttribution + internetStatus)
        analyticsManager?.forceEventsUpload()
    }

    func sendConfigurationFinished(status: [String: String]) {
        InternalAnalyticsEvent.framework_finished.log(parameters: status + internetStatus)
        analyticsManager?.forceEventsUpload()
    }

    func sendAppsflyerStartError(_ error: Error) {
        let nserror = error as NSError
        let parameters = ["error": "\(nserror.code)",
                          "description": nserror.localizedDescription]
        InternalAnalyticsEvent.framework_appsflyer_start_error.log(parameters: parameters + internetStatus)
        analyticsManager?.forceEventsUpload()
    }

    func sendABTestsUserProperties(abTests: [any CoreRemoteABTestable], userSource: CoreUserSource) { // +
        let userProperties = abTests.reduce(into: [String:String]()) { partialResult, abtest in
            let shouldSend: Bool = abtest.activeForSources.contains(userSource)
            var value = abtest.value
            if !shouldSend {
                value = "none"
            } else if value.contains("none_") {
                value = "none"
            }
            partialResult[abtest.key] = value
        }
        InternalUserProperty.identify(userProperties)
    }
    
    func sendTestDistributionEvent(abTests: [any CoreRemoteABTestable], deepLinkResult: [String: String],
                                   userSource: CoreUserSource) { // +
        var parameters = abTests.reduce(into: [String:String]()) { partialResult, abtest in
            let shouldSend: Bool = abtest.activeForSources.contains(userSource)
            var value = abtest.value
            if !shouldSend {
                value = "none"
            } else if value.contains("none_") {
                value = "none"
            }
            partialResult[abtest.key] = value
        }
        
        parameters = parameters + deepLinkResult
        
        InternalAnalyticsEvent.test_distribution.log(parameters: parameters)
        analyticsManager?.forceEventsUpload()
    }
    
    func sendStoreCountryUserProperty() {
        Task {
            let country = await Storefront.current?.countryCode ?? ""
            InternalUserProperty.store_country.identify(parameter: country)
        }
    }
    
    func sendSubscriptionTypeUserProperty(identifier: String) {
        InternalUserProperty.subscription_type.identify(parameter: identifier)
    }
}

extension Dictionary {
    static func += (lhs: inout [Key:Value], rhs: [Key:Value]) {
        lhs.merge(rhs){$1}
    }
    static func + (lhs: [Key:Value], rhs: [Key:Value]) -> [Key:Value] {
        return lhs.merging(rhs){$1}
    }
}
