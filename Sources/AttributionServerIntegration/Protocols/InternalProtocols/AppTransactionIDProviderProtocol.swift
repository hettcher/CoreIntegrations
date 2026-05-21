import Foundation

internal protocol AppTransactionIDProviderProtocol {
    func fetchAppTransactionID() async -> String?
}
