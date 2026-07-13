//
//  DebugLogger.swift
//  CoreIntegrations
//
//  Created by Arteezy on 13.06.2026.
//

import Foundation

public enum DebugLogger {
    public static var isEnabled = true

    public static func log(_ message: @autoclosure () -> String) {
        guard isEnabled else { return }
        debugPrint(message())
    }
}
