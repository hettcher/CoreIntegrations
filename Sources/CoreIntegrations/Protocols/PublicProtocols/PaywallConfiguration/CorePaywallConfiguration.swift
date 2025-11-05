
import Foundation

public protocol CorePaywallConfiguration: CaseIterable {
    associatedtype PurchaseIdentifier: CorePurchaseIdentifier
    
    var id: String { get }
    var purchases: [PurchaseIdentifier] { get }
}

public extension CorePaywallConfiguration {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func purchases() async -> CorePaywallPurchasesResult {
        let result = await CoreManager.internalShared.purchases(config: self)
        return result
    }
    
    var isTrialPaywall: Bool {
        get async {
            let result = await CoreManager.internalShared.purchases(config: self)
            
            if case .success(let purchases) = result {
                for purchase in purchases {
                    let mode = await purchase.paymentMode
                    if mode != .notTrial {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    var trialInfo: PaywallTrialInfo {
        get async {
            var containsOffers = false
            var isEligibleForOffer = false

            let result = await CoreManager.internalShared.purchases(config: self)

            if case .success(let purchases) = result {
                for purchase in purchases {
                    if await purchase.hasOffers {
                        containsOffers = true
                    }

                    let mode = await purchase.paymentMode
                    if mode != .notTrial {
                        isEligibleForOffer = true
                    }
                }
            }

            return PaywallTrialInfo(
                containsOffers: containsOffers,
                isEligibleForOffer: isEligibleForOffer
            )
        }
    }
}

extension CorePaywallConfiguration {
    static var allPurchasesIDs: [String] {
        return allPurchases.map({$0.id})
    }
    static var allProPurchasesIDs: [String] {
        return allProPurchases.map({$0.id})
    }
    
    static var allPurchases: [PurchaseIdentifier] {
        return PurchaseIdentifier.allCases as! [Self.PurchaseIdentifier]
    }
    
    static var allProPurchases: [PurchaseIdentifier] {
        return PurchaseIdentifier.allCases.filter({$0.purchaseGroup.isPro})
    }
    
    var activeForPaywallIDs: [String] {
        return purchases.map({$0.id})
    }
    
    var allPurchases: [PurchaseIdentifier] {
        return PurchaseIdentifier.allCases as! [Self.PurchaseIdentifier]
    }
}

public struct PaywallTrialInfo {
    public var containsOffers: Bool
    public var isEligibleForOffer: Bool
}
