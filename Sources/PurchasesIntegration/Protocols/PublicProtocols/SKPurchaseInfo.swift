
import Foundation
import StoreKit

public struct SKPurchaseInfo {
    public let transaction: Transaction
    public let jsonRepresentation: Data
    public let jwsRepresentation: String
    public let originalID: String
    
    public init(transaction: Transaction, jsonRepresentation: Data, jwsRepresentation: String, originalID: String) {
        self.transaction = transaction
        self.jsonRepresentation = jsonRepresentation
        self.jwsRepresentation = jwsRepresentation
        self.originalID = originalID
    }
}
