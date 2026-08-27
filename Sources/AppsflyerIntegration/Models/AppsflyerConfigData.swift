public struct AppsflyerConfigData {
    let appsFlyerDevKey: String
    let appleAppID: String

    public init(appsFlyerDevKey: String, appleAppID: String) {
        self.appsFlyerDevKey = appsFlyerDevKey
        self.appleAppID = appleAppID
    }
}
