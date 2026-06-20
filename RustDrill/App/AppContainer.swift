//
//  AppContainer.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation
import Combine
import GoogleMobileAds
import OSLog

@MainActor
final class AppContainer: ObservableObject {
    private static let logger = Logger(subsystem: "RustDrill", category: "Ads")

    let repository: QuizRepository
    let adGateService: AdGateService
    private let rewardAdPresenter: GoogleRewardAdPresenter?
    private var didStartAds = false
    
    init(repository: QuizRepository, adGateService: AdGateService? = nil) {
        self.repository = repository

        if let adGateService {
            self.adGateService = adGateService
            self.rewardAdPresenter = nil
        } else if let rewardAdUnitID = AdConfiguration.rewardAdUnitID {
            let presenter = GoogleRewardAdPresenter(adUnitID: rewardAdUnitID)
            self.rewardAdPresenter = presenter
            self.adGateService = FrequencyControlledAdGateService(
                frequency: 3,
                presenter: presenter
            )
        } else {
            Self.logger.error("Reward ad unit ID is missing or invalid. Ads will be disabled for reward gate.")
            self.rewardAdPresenter = nil
            self.adGateService = FrequencyControlledAdGateService(
                frequency: 1,
                presenter: NoopAdPresenter()
            )
        }
    }
    
    func startAdsIfNeeded() async {
        guard !didStartAds else { return }

        guard await AdPrivacyAuthorizationService.gatherConsentIfNeeded() else {
            return
        }

        didStartAds = true
        await AdPrivacyAuthorizationService.requestTrackingAuthorizationIfNeeded()
        await MobileAds.shared.start()
        rewardAdPresenter?.preload()
    }
}
