
import Foundation
import StoreKit

extension PurchasesManager {
    public func listenForPendingPurchases(_ result: @escaping ((any Error)?) -> Void) {
        purchasePendingCallback = result
    }
    
    public func listenForTransactions() -> Task<Void, Error> {
        debugPrint("🏦 listenForTransactions ✅ Setup listener")
        return Task.detached {
            debugPrint("🏦 listenForTransactions ⚈ ⚈ ⚈ Recieved updates... ⚈ ⚈ ⚈")
            for await result in Transaction.updates {
                do {
                    debugPrint("🏦 listenForTransactions ⚈ ⚈ ⚈ Checking verification for transaction \(result.debugDescription) ⚈ ⚈ ⚈")
                    let transaction = try self.checkVerified(result)
                    debugPrint("🏦 listenForTransactions ✅ Transaction Verified.")
                    await self.updateProductStatus()
                    debugPrint("🏦 listenForTransactions ✅ Updated Customer Product Status.")
                    await transaction.finish()
                    self.purchasePendingCallback?(nil)
                    debugPrint("🏦 listenForTransactions ✅ Finished Transaction.")
                } catch {
                    self.purchasePendingCallback?(error)
                    debugPrint("🏦 listenForTransactions ❌ Transaction verification failed.")
                }
            }
        }
    }
}
