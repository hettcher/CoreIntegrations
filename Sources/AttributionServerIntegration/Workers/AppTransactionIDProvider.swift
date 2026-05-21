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
    private let logger = Logger(
            subsystem: "com.coreintegrations.framework",
            category: "AppTransactionProvider"
        )
    
    func fetchAppTransactionID() async -> AppTransactionResult {
        logger.info("app transaction called")
        guard #available(iOS 16.0, *) else {
            logger.error("app transaction notAvailable")
            return .notAvailable
        }

        do {
            logger.info("app transaction fetch started")
            let verificationResult = try await AppTransaction.shared
            logger.info("app transaction fetch finished")
            switch verificationResult {
            case .verified(let appTransaction):
                logger.info("app transaction verified")
                return .success(appTransactionID: appTransaction.appTransactionID)
            case .unverified(let appTransaction, let verificationError):
                logger.error("app transaction unverified: \(verificationError.localizedDescription)")
                return .unverified
            }
        } catch {
            logger.error("app transaction error: \(error.localizedDescription)")
            return .unknownError(error: error)
        }
    }
}
