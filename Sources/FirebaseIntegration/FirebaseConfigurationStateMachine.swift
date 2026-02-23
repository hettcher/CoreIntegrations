
import FirebaseAnalytics
import FirebaseCore

public class FirebaseConfigurationStateMachine {
    enum State {
        case notSet
        case waitingForExternalConfiguration(id: String?)
        case configuredInternally
        case configuredExternally
        case finishedConfigurationWithID(id: String)
    }
      
    public enum Event {
        case configureInternallyIfNeeded
        case waitForExternalConfiguration
        case handleExternalConfigurationFinished
        case handleIDSetup(id: String)
    }
    
    private(set) var state: State = .notSet
    private var savedID: String?
    
    public init() {
        
    }
        
    public func handle(event: Event) {
        switch (state, event) {
            
        case (.notSet, .configureInternallyIfNeeded):
            configureFirebase()
            state = .configuredInternally
        case (_, .configureInternallyIfNeeded):
            break
            
        case (.notSet, .waitForExternalConfiguration):
            state = .waitingForExternalConfiguration(id: nil)
        case (.configuredInternally, .waitForExternalConfiguration):
            assertionFailure("Internal framework error, contact framework maintainer.")
            break
        case (_, .waitForExternalConfiguration):
            break
          
        case (.notSet, .handleExternalConfigurationFinished):
            state = .configuredExternally
        case (.waitingForExternalConfiguration(let id), .handleExternalConfigurationFinished):
            if let savedId = id {
                sendAnalyticsID(savedId)
                state = .finishedConfigurationWithID(id: savedId)
            } else {
                state = .configuredExternally
            }
        case (.configuredInternally, .handleExternalConfigurationFinished):
            assertionFailure("You forgot to configure framework to expect external configuration and it already configured internally. If not - contact framework maintainer.")
            break
        case (_, .handleExternalConfigurationFinished):
            break
            
        case (.notSet, .handleIDSetup(_)):
            assertionFailure("Internal framework error, contact framework maintainer.")
            break
        case (.waitingForExternalConfiguration, .handleIDSetup(let id)):
            state = .waitingForExternalConfiguration(id: id)
        case (.configuredInternally, .handleIDSetup(let id)),
             (.configuredExternally, .handleIDSetup(let id)):
            sendAnalyticsID(id)
            state  = .finishedConfigurationWithID(id: id)
        case (.finishedConfigurationWithID(let sentID), .handleIDSetup(let id)):
            guard sentID == id else {
                assertionFailure("Changing id after it's already set is unexpected. Contact framework maintainer if it was intended.")
                return
            }
            break
        }
    }
    
    private func configureFirebase() {
        FirebaseApp.configure()
        Analytics.logEvent("Firebase Init", parameters: nil)
    }
    
    private func sendAnalyticsID(_ id: String) {
        Analytics.setUserID(id)
    }
}
