import Foundation

internal protocol AttributionUserDefaultsWorkerProtocol {
    var uuid: String { get }
    
    func getInstallData() -> AttributionInstallRequestModel?
    func saveInstallData(_ data: AttributionInstallRequestModel)
    func deleteSavedInstallData()
    
    func saveInstallResult(_ result: AttributionManagerResult?)
    func getInstallResult() -> AttributionManagerResult?

    func getGeneratedToken() -> String?
    func saveGeneratedToken(_ token: String)

    func getPurchaseData() -> AttributionPurchaseModel?
    func savePurchaseData(_ data: AttributionPurchaseModel)
    func deleteSavedPurchaseData()

    func getServerUserID() -> AttributionUserUUID?
    func saveServerUserID(_ id: AttributionUserUUID)
    
    func getFCMToken() -> String?
    func saveFCMToken(_ token: String)

    func getExternalAuthData() -> String?
    func saveExternalAuthData(_ externalAuthId: String)
    func deleteSavedExternalAuthData()
}
