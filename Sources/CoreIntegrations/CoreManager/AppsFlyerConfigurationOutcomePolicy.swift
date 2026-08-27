struct AppsFlyerConfigurationOutcomePolicy {
    private(set) var shouldAcceptConversionResult = true

    mutating func recordSessionStartFailure() {
        shouldAcceptConversionResult = false
    }

    mutating func reset() {
        shouldAcceptConversionResult = true
    }
}
