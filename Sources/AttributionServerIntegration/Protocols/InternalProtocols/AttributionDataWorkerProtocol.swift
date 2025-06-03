
import Foundation

internal protocol AttributionDataWorkerProtocol {
    var idfa: String? { get }
    var idfv: String? { get }
    var sdkVersion: String { get }
    var osVersion: String { get }
    var appVersion: String { get }
    var isAdTrackingEnabled: Bool { get }
    var storeCountry: String { get }
    
    var receiptToken: String { get }
    
    func attributionDetails() async -> AttributionDetails?
    func generateUniqueToken() -> String
}

struct AttributionDetails {
    var details:[String: Any]?
    var attributionToken: String
}
