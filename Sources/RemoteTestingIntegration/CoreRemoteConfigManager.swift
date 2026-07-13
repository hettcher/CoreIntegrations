
import Foundation

#if !COCOAPODS
import Experiment
#else
import AmplitudeExperiment
#endif

public class CoreRemoteConfigManager: RemoteConfigManager {
    private var remoteConfigManager: RemoteConfigManager
    
    private var isConfigFetched:Bool = false
    
    public var allRemoteValues: [String: String] {
        return remoteConfigManager.allRemoteValues
    }
    
    public var remoteError: Error? {
        return remoteConfigManager.remoteError
    }
     
    public init(deploymentKey: String, userInfo: [String: String], customServerURL: String? = nil) {
        remoteConfigManager = AmplitudeExperimentManager(deploymentKey: deploymentKey, userInfo: userInfo, customServerURL: customServerURL)
    }
    
    public func configure(_ appConfigurables: [any RemoteConfigurable], completion: @escaping () -> Void) {
        guard !isConfigFetched else {
            completion()
            return
        }
        
        remoteConfigManager.configure(appConfigurables) { [weak self] in
            guard let self = self else {return}

            isConfigFetched = true
            completion()
        }
    }
    
    public func updateRemoteConfig(_ userProperies: [String: Any], completion: @escaping () -> Void) {
        remoteConfigManager.updateRemoteConfig(userProperies, completion: completion)
    }
    
    public func getValue(forConfig config: RemoteConfigurable) -> String? {
        return remoteConfigManager.getValue(forConfig: config)
    }
    
    public func getPayload(forConfig config: any RemoteConfigurable) -> [String : Any]? {
        return remoteConfigManager.getPayload(forConfig: config)
    }
    
    public func exposure(forConfig config: RemoteConfigurable) {
        remoteConfigManager.exposure(forConfig: config)
    }
}
