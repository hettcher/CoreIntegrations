import Foundation

public protocol RemoteTestingProcotol {
    var configurationCompletion: (() -> Void)? { get set }
    
    init(deploymentKey: String, userInfo: [String: String])
}

public protocol RemoteConfigManager {
    var allRemoteValues: [String: String] { get }
    var remoteError: Error? { get }
    
    func configure(_ appConfigurables: [any RemoteConfigurable], completion: @escaping () -> Void)
    
    func updateRemoteConfig(_ appConfigurables: [String: Any], completion: @escaping () -> Void)
    
    func getValue(forConfig config: any RemoteConfigurable) -> String?
    func exposure(forConfig config: RemoteConfigurable)
}
