
import Foundation
#if !COCOAPODS
import AnalyticsIntegration
#endif

enum InternalAnalyticsEvent: String, CaseIterable, AmplitudeAnalyzableEvent {
    case first_launch
    case test_distribution
    case att_permission
    case framework_attribution_started
    case framework_attribution
    case framework_attribution_update
    case framework_finished
    case framework_appsflyer_start_error

    public var key: String {
        return rawValue
    }
}
