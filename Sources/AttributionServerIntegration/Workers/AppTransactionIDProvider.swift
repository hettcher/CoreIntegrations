import Foundation
import StoreKit
import os

enum AppTransactionResult {
    case success(appTransactionID: String)
    case unverified
    case notAvailable
    case unknownError(error: Error?)
}

final class AppTransactionIDProvider: AppTransactionIDProviderProtocol {
    func fetchAppTransactionID() async -> AppTransactionResult {
        guard #available(iOS 16.0, *) else {
            return .notAvailable
        }

        do {
            let verificationResult = try await AppTransaction.shared
            switch verificationResult {
            case .verified(let appTransaction):
                return .success(appTransactionID: appTransaction.appTransactionID)
            case .unverified(_, _):
                return .unverified
            }
        } catch {
            return .unknownError(error: error)
        }
    }
}
