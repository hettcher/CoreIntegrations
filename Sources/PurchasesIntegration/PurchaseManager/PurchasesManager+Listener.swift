
import Foundation
import StoreKit
import LoggingIntegration

extension PurchasesManager {
    public func listenForPendingPurchases(_ result: @escaping (Transaction?, (any Error)?) -> Void) {
        purchasePendingCallback = result
    }
    
    public func listenForTransactions() -> Task<Void, Error> {
        DebugLogger.log("🏦 listenForTransactions ✅ Setup listener")
        return Task.detached {
            DebugLogger.log("🏦 listenForTransactions ⚈ ⚈ ⚈ Recieved updates... ⚈ ⚈ ⚈")
            for await result in Transaction.updates {
                do {
                    DebugLogger.log("🏦 listenForTransactions ⚈ ⚈ ⚈ Checking verification for transaction \(result.debugDescription) ⚈ ⚈ ⚈")
                    let transaction = try await self.checkVerified(result)
                    DebugLogger.log("🏦 listenForTransactions ✅ Transaction Verified.")
                    await self.updateProductStatus()
                    DebugLogger.log("🏦 listenForTransactions ✅ Updated Customer Product Status.")
                    await transaction.finish()
                    await self.purchasePendingCallback?(transaction, nil)
                    DebugLogger.log("🏦 listenForTransactions ✅ Finished Transaction.")
                } catch {
                    await self.purchasePendingCallback?(nil, error)
                    DebugLogger.log("🏦 listenForTransactions ❌ Transaction verification failed.")
                }
            }
        }
    }
}
