import StoreKit
import Foundation

public typealias Transaction = StoreKit.Transaction
public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public class PurchasesManager: NSObject, PurchasesManagerProtocol {
    // MARK: Variables
    static let identifier: String = "🏦"
    static public let shared: PurchasesManagerProtocol = internalShared
    public var userId: String = ""
    static var internalShared = PurchasesManager()
    // A transaction listener to listen to transactions on init and through out the apps use.
    private var updateListenerTask: Task<Void, Error>?

    // MARK: Offering Arrays
    // Arrays are initially empty and are filled in when we gather the products
    var allAvailableProducts: [Product] = []
    public var consumables: [Product] = []
    public var nonConsumables: [Product] = []
    public var subscriptions: [Product] = []
    public var nonRenewables: [Product] = []
    // Arrays that hold the purchases products
    public var purchasedConsumables: [Product] = []
    public var purchasedNonConsumables: [Product] = []
    public var purchasedSubscriptions: [Product] = []
    public var purchasedNonRenewables: [Product] = []
    public var purchasedAllProducts: [Product] = []
    
    var allIdentifiers: [String] = []
    var proIdentifiers: [String] = []
    
    var purchasePendingCallback: ((Error?) -> Void)?
    
    // MARK: Lifecycle
    public func initialize(allIdentifiers: [String], proIdentifiers: [String]) {
        debugPrint("🏦 initialize ⚈ ⚈ ⚈ Initializing... ⚈ ⚈ ⚈")
        debugPrint("🏦 initialize ⚈ ⚈ ⚈ Starting Transaction Listener... ⚈ ⚈ ⚈")
        self.allIdentifiers = allIdentifiers
        self.proIdentifiers = proIdentifiers
        
        updateListenerTask = listenForTransactions()

        Task { [weak self] in
            guard let self = self else { return }
            debugPrint("🏦 initialize ⚈ ⚈ ⚈ Requesting products... ⚈ ⚈ ⚈")
            
            let _ = await self.requestAllProducts(allIdentifiers)

            debugPrint("🏦 initialize ⚈ ⚈ ⚈ Updating customer product status... ⚈ ⚈ ⚈")
            
            await self.updateProductStatus()
        }
        debugPrint("🏦 initialize ✅ initialized")
    }

    deinit {
        debugPrint("🏦 deinit ⚈ ⚈ ⚈ Deinitializing... ⚈ ⚈ ⚈")
        updateListenerTask?.cancel()
        debugPrint("🏦 deinit ✅ Deinitialized")
    }
    
    public func setUserID(_ id: String) {
        self.userId = id
    }
    
}


