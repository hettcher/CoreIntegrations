import Foundation

internal struct AttributionTokenRequestModel: Codable {
    let userId: String
    let fcmToken: String
    let localization: String
    let environment: String?
    
    init(userId: String, fcmToken: String, localization: String, environment: String?) {
        self.userId = userId
        self.fcmToken = fcmToken
        self.localization = localization
        self.environment = environment
    }
}
