//
//  AppContainer.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation
import Combine
import GoogleMobileAds

@MainActor
final class AppContainer: ObservableObject {
    let repository: QuizRepository
    let adGateService: AdGateService
    private let rewardAdPresenter: GoogleRewardAdPresenter?
    private var didStartAds = false
    
    init(repository: QuizRepository, adGateService: AdGateService? = nil) {
        self.repository = repository
        
        if let adGateService {
            self.adGateService = adGateService
            self.rewardAdPresenter = nil
        } else {
            let presenter = GoogleRewardAdPresenter(
                adUnitID: AdConfiguration.rewardAdUnitID
            )
            self.rewardAdPresenter = presenter
            self.adGateService = FrequencyControlledAdGateService(
                frequency: 1,
                presenter: presenter
            )
        }
    }
    
    func startAdsIfNeeded() async {
        guard !didStartAds else { return }
        didStartAds = true

        guard await AdPrivacyAuthorizationService.gatherConsentIfNeeded() else {
            return
        }

        await AdPrivacyAuthorizationService.requestTrackingAuthorizationIfNeeded()
        await MobileAds.shared.start()
        rewardAdPresenter?.preload()
    }
}
