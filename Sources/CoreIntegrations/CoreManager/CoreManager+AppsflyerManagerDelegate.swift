
import Foundation
#if !COCOAPODS
import AppsflyerIntegration
#endif

extension CoreManager: AppsflyerManagerDelegate {
    public func coreConfiguration(didReceive deepLinkResult: [AnyHashable : Any]) {
        delegate?.coreConfiguration(didReceive: deepLinkResult)
    }
    
    public func coreConfiguration(handleDeeplinkError error: Error) {
        delegate?.coreConfiguration(handleDeeplinkError: error)
        InternalConfigurationEvent.appsflyerWeb2AppHandled.markAsCompleted(error: error)
    }
    
    public func handledDeeplink(_ result: [String : String]) {
        sendDeepLinkUserProperties(deepLinkResult: result)
        InternalConfigurationEvent.appsflyerWeb2AppHandled.markAsCompleted()

        handleConfigurationUpdate()
    }

    public func appsflyerStartCompleted(error: Error?) {
        guard let error else { return }
        sendAppsflyerStartError(error)
    }
}
