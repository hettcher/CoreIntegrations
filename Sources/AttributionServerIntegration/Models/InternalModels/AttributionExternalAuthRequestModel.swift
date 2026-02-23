import Foundation

struct AttributionExternalAuthRequestModel: Codable {
    let userId: String?
    let productUserId: String?
    
    init(userId: String?, productUserId: String?) {
        self.userId = userId
        self.productUserId = productUserId
    }
}
