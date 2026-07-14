
import Foundation
import StoreKit
import LoggingIntegration

extension PurchasesManager {
    public func requestProducts(_ identifiers: [String]) async -> SKProductsResult {
        DebugLogger.log("🏦 requestProducts ⚈ ⚈ ⚈ Requesting products... ⚈ ⚈ ⚈")
        guard !identifiers.isEmpty else {
            DebugLogger.log("🏦 requestProducts ❌ Failed: identifiers are empty.")
            return .error(error: "empty identifiers")
        }
        
        do {
            let storeProducts = try await Product.products(for: identifiers)
            DebugLogger.log("🏦 requestProductsForPaywall ✅ Completed gathering Products.")
            
            guard !storeProducts.isEmpty else {
                return .error(error: "products for identifiers not found")
            }

            DebugLogger.log("🏦 requestProductsForPaywall ✅ Completed updating available Products.")
            return .success(products: storeProducts)
        } catch {
            DebugLogger.log("🏦 requestProductsForPaywall ❌ Failed product request from the App Store server: \(error).")
            return .error(error: error.localizedDescription)
        }
    }
    
    public func requestAllProducts(_ identifiers: [String]) async -> SKProductsResult {
        DebugLogger.log("🏦 requestAllProducts ⚈ ⚈ ⚈ Requesting products... ⚈ ⚈ ⚈")
        guard !identifiers.isEmpty else {
            DebugLogger.log("🏦 requestAllProducts ❌ Failed: identifiers are empty.")
            return .error(error: "empty identifiers")
        }
        
        do {
            let storeProducts = try await Product.products(for: identifiers)
            DebugLogger.log("🏦 requestAllProducts ✅ Completed gathering Products.")
            
            guard !storeProducts.isEmpty else {
                return .error(error: "products for identifiers not found")
            }
            
            allAvailableProducts = storeProducts
            
            mapProducts(storeProducts)

            DebugLogger.log("🏦 requestAllProducts ✅ Completed updating available Products.")
            return .success(products: storeProducts)
        } catch {
            DebugLogger.log("🏦 requestAllProducts ❌ Failed product request from the App Store server: \(error).")
            return .error(error: error.localizedDescription)
        }
    }
    
    private func mapProducts(_ storeProducts: [Product]) {
        var newConsumables: [Product] = []
        var newNonConsumables: [Product] = []
        var newSubscriptions: [Product] = []
        var newNonRenewables: [Product] = []

        for product in storeProducts {
            switch product.type {
            case .consumable:
                newConsumables.append(product)
                DebugLogger.log("🏦 mapProducts ✅ Found consumable : \(product).")
            case .nonConsumable:
                newNonConsumables.append(product)
                DebugLogger.log("🏦 mapProducts ✅ Found non-consumable : \(product).")
            case .autoRenewable:
                newSubscriptions.append(product)
                DebugLogger.log("🏦 mapProducts ✅ Found auto-renewable subscription : \(product).")
            case .nonRenewable:
                DebugLogger.log("🏦 mapProducts ✅ Found non-renewable subscription : \(product).")
                newNonRenewables.append(product)
            default:
                DebugLogger.log("🏦 mapProducts ❌ unknown product : \(product).")
            }
        }

        DebugLogger.log("🏦 mapProducts ✅ Completed ordering Products.")

        consumables = sortByPrice(newConsumables)
        nonConsumables = sortByPrice(newNonConsumables)
        subscriptions = sortByPrice(newSubscriptions)
        nonRenewables = sortByPrice(newNonRenewables)
    }

    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
