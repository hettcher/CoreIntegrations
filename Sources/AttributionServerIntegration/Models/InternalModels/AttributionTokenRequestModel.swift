import Foundation

internal struct AttributionTokenRequestModel: Codable {
    let userId: String
    let fcmToken: String
    let localization: String
    
    init(userId: String, fcmToken: String, localization: String) {
        self.userId = userId
        self.fcmToken = fcmToken
        self.localization = localization
    }
}