import Foundation
import StoreKit

final class AppTransactionIDProvider: AppTransactionIDProviderProtocol {
    func fetchAppTransactionID() async -> String? {
        guard #available(iOS 16.0, *) else {
            return nil
        }

        do {
            let verificationResult = try await AppTransaction.shared
            switch verificationResult {
            case .verified(let appTransaction):
                return appTransaction.appTransactionID
            case .unverified(let appTransaction, _):
                return appTransaction.appTransactionID
            }
        } catch {
            return nil
        }
    }
}
