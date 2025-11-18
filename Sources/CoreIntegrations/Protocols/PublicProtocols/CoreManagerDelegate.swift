
import Foundation

public protocol CoreManagerDelegate: AnyObject {
    func coreConfigurationFinished(result: CoreManagerResult)
    func coreConfigurationUpdated()
    
    func coreConfiguration(didReceive deepLinkResult: [AnyHashable : Any])
    func coreConfiguration(handleDeeplinkError error: Error)
    func coreConfiguration(fcmTokenUpdated token: String)
}

public extension CoreManagerDelegate {
    func coreConfiguration(didReceive deepLinkResult: [AnyHashable : Any]) {
        
    }
}
