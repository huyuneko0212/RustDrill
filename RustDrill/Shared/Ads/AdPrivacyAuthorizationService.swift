//
//  AdPrivacyAuthorizationService.swift
//  RustDrill
//
//  Created by Codex on 2026/05/30.
//

import AppTrackingTransparency
import Foundation
import OSLog
import UserMessagingPlatform

@MainActor
enum AdPrivacyAuthorizationService {
    private static let logger = Logger(subsystem: "RustDrill", category: "AdPrivacy")

    static var canRequestAds: Bool {
        ConsentInformation.shared.canRequestAds
    }

    static var isPrivacyOptionsRequired: Bool {
        ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }

    static func gatherConsentIfNeeded() async -> Bool {
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters())
            try await ConsentForm.loadAndPresentIfRequired(from: nil)
        } catch {
            logger.error("Consent gathering failed: \(error.localizedDescription, privacy: .public)")
        }

        return ConsentInformation.shared.canRequestAds
    }

    static func presentPrivacyOptionsForm() async throws {
        try await ConsentForm.presentPrivacyOptionsForm(from: nil)
    }

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
