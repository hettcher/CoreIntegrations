public struct AmplitudeConfigData {
    let appKey: String
    let cnConfig: Bool
    let customURL: String?
    let sessionReplayConfig: SessionReplayConfig
    
    public init(appKey: String, cnConfig: Bool, customURL: String?, sessionReplayConfig: SessionReplayConfig) {
        self.appKey = appKey
        self.cnConfig = cnConfig
        self.customURL = customURL
        self.sessionReplayConfig = sessionReplayConfig
    }
}

public struct SessionReplayConfig {
    let startOnLaunch: Bool
    let sampleRate: Float
    let enableRemoteConfig: Bool
    
    public init(startOnLaunch: Bool, sampleRate: Float, enableRemoteConfig: Bool) {
        self.startOnLaunch = startOnLaunch
        self.sampleRate = sampleRate
        self.enableRemoteConfig = enableRemoteConfig
    }
}
