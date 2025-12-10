
import Foundation

public struct AttributionConfigData {
    let authToken: AttributionServerToken
    let installServerURLPath: String
    let purchaseServerURLPath: String
    let externalAuthServerURLPath: String
    let installPath: String
    let purchasePath: String
    let externalAuthPath: String
    let appsflyerID: String?
    let appEnvironment: String?
    let facebookData: AttributionFacebookModel?
    let hasExternalAuth: Bool?
    
    public init(authToken: AttributionServerToken, installServerURLPath: String, purchaseServerURLPath: String,
                externalAuthServerURLPath: String, installPath: String,
                purchasePath: String, externalAuthPath: String, appsflyerID: String?, appEnvironment: String?,
                facebookData: AttributionFacebookModel?, hasExternalAuth: Bool?) {
        self.authToken = authToken
        self.appsflyerID = appsflyerID
        self.facebookData = facebookData
        self.installServerURLPath = installServerURLPath
        self.purchaseServerURLPath = purchaseServerURLPath
        self.externalAuthServerURLPath = externalAuthServerURLPath
        self.installPath = installPath
        self.purchasePath = purchasePath
        self.externalAuthPath = externalAuthPath
        self.appEnvironment = appEnvironment
        self.hasExternalAuth = hasExternalAuth
    }
}

public struct AttributionConfigURLs {
    let installServerURLPath: String
    let purchaseServerURLPath: String
    let externalAuthServerURLPath: String
    let installPath: String
    let purchasePath: String
    let externalAuthPath: String
    
    public init(installServerURLPath: String, purchaseServerURLPath: String, externalAuthServerURLPath: String,
                installPath: String, purchasePath: String, externalAuthPath: String) {
        self.installServerURLPath = installServerURLPath
        self.purchaseServerURLPath = purchaseServerURLPath
        self.installPath = installPath
        self.purchasePath = purchasePath
        self.externalAuthServerURLPath = externalAuthServerURLPath
        self.externalAuthPath = externalAuthPath
    }
}
