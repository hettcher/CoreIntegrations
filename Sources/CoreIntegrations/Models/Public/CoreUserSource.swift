
import Foundation

public enum CoreUserSource: Hashable, Sendable, RawRepresentable, Codable {
    case organic
    case asa
    case test_premium
    case tiktok_full_access
    case other(String)

    public init(rawValue: String) {
        switch rawValue {
        case "organic": self = .organic
        case "Apple Search Ads": self = .asa
        case "Full_Access": self = .test_premium
        case "tiktok_full_access": self = .tiktok_full_access
        default: self = .other(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .organic: return "organic"
        case .asa: return "Apple Search Ads"
        case .test_premium: return "Full_Access"
        case .tiktok_full_access: return "tiktok_full_access"
        case .other(let rawValue): return rawValue
        }
    }
}
