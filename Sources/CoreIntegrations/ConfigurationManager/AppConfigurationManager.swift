
import Foundation

class AppConfigurationManager {
    public static var shared: AppConfigurationManager?
    
    private var model: CoreConfigurationModel
    private var isFirstStart: Bool
    
    private var completedEvents = [any ConfigurationEvent]()
    private var completionErrors = [String: Error]()
    private var timout: Int = 6
    private var currentSecond = 0
    private var waitingCallbacks = [(ConfigurationResult) -> Void]()
    private var attributionCallback: (() -> Void)?
    private var isTimerFinished = false
    var configurationFinishHandled = false
    private var configurationAttFinishHandled = false
    
    private var configurationCompletelyFinished: Bool {
        return model.checkAllEventsFinished(completedEvents: completedEvents, isFirstStart: isFirstStart)
    }
    
    private var configurationRequiredFinished: Bool {
        return model.checkRequiredEventsFinished(completedEvents: completedEvents, isFirstStart: isFirstStart)
    }
    
    private var configurationAttAndConfigFinished: Bool {
        return model.checkAttAndConfigFinished(completedEvents: completedEvents, isFirstStart: isFirstStart)
    }
    
    private var isConfigurationFinished: Bool {
        return isTimerFinished || configurationCompletelyFinished
    }

    /// Per-event configuration status for diagnostic analytics:
    /// "finished" / "error: <code>" / "not finished".
    var statusForAnalytics: [String: String] {
        var result = [String: String]()
        completedEvents.forEach { event in
            let error = completionErrors.first(where: { $0.key == event.key })?.value
            if let nserror = error as? NSError {
                result[event.key] = "error: \(nserror.code)"
            } else {
                result[event.key] = "finished"
            }
        }
        let notCompleted = model.allConfigurationEvents.filter { event in
            !completedEvents.contains { completedEvent in
                completedEvent.key == event.key
            }
        }
        notCompleted.forEach { event in
            result[event.key] = "not finished"
        }
        return result
    }

    init(model: CoreConfigurationModel, isFirstStart: Bool, timeout: Int = 6) {
        self.model = model
        self.isFirstStart = isFirstStart
        self.timout = timeout
    }
    
    public func startTimoutTimer() {
        guard self.isConfigurationFinished == false else {
            return
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(timout)) {
            guard self.isConfigurationFinished == false else {
                return
            }
            
            self.isTimerFinished = true
            self.checkConfiguration()
        }
    }
    
    public func handleCompleted(event: any ConfigurationEvent) {
        handleCompleted(event: event, error: nil)
    }

    public func handleCompleted(event: any ConfigurationEvent, error: Error?) {
        if !completedEvents.contains(where: { $0.key == event.key }) {
            completedEvents.append(event)
        }
        if let error {
            completionErrors[event.key] = error
        } else {
            completionErrors.removeValue(forKey: event.key)
        }
        checkConfiguration()
        checkATTConfiguration()
    }
    
    public func signForConfigurationEnd(_ callback: @escaping (ConfigurationResult) -> Void) {
        guard !isConfigurationFinished else {
            let configurationResult: ConfigurationResult = configurationRequiredFinished ? .completed : .requiredFailed
            callback(configurationResult)
            return
        }
        waitingCallbacks.append(callback)
    }
    
    public func signForAttAndConfigLoaded(_ callback: @escaping () -> Void) {
        guard !configurationAttFinishHandled else {
            callback()
            return
        }
        attributionCallback = callback
    }
    
    private func checkATTConfiguration() {
        guard configurationAttAndConfigFinished else {
            return
        }
        
        guard configurationAttFinishHandled == false else {
            return
        }
        
        configurationAttFinishHandled = true
        attributionCallback?()
    }
    
    private func checkConfiguration() {
        guard isConfigurationFinished else {
            return
        }
        
        guard configurationFinishHandled == false else {
            return
        }
        configurationFinishHandled = true
        
        let configurationResult: ConfigurationResult = configurationRequiredFinished ? .completed : .requiredFailed
        waitingCallbacks.forEach { callback in
            callback(configurationResult)
        }
        waitingCallbacks.removeAll()
    }
}
