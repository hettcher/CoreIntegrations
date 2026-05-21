import Foundation

internal protocol AppTransactionIDProviderProtocol {
    func fetchAppTransactionID() async -> AppTransactionResult
}
