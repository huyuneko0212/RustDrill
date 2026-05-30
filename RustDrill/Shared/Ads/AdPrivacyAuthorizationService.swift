//
//  AdPrivacyAuthorizationService.swift
//  RustDrill
//
//  Created by Codex on 2026/05/30.
//

import AppTrackingTransparency
import Foundation

@MainActor
enum AdPrivacyAuthorizationService {
    static func requestTrackingAuthorizationIfNeeded() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            return
        }
        
        _ = await withCheckedContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}
