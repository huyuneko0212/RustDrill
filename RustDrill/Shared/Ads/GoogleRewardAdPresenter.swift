//
//  GoogleRewardAdPresenter.swift
//  RustDrill
//
//  Created by Codex on 2026/05/23.
//

import Foundation
import GoogleMobileAds

@MainActor
final class GoogleRewardAdPresenter: NSObject, AdPresenting {
    private let adUnitID: String
    private var rewardedAd: RewardedAd?
    private var isLoading = false
    private var didEarnReward = false
    private var presentationContinuation: CheckedContinuation<Bool, Never>?
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func preload() {
        Task { _ = try? await loadAdIfNeeded() }
    }
    
    func presentRewardAd() async -> Bool {
        do {
            let ad = try await loadAdIfNeeded()
            rewardedAd = nil
            didEarnReward = false
            ad.fullScreenContentDelegate = self
            
            return await withCheckedContinuation { continuation in
                presentationContinuation = continuation
                ad.present(from: nil) { [weak self, weak ad] in
                    self?.didEarnReward = true
                    _ = ad?.adReward
                }
            }
        } catch {
            return true
        }
    }
    
    private func loadAdIfNeeded() async throws -> RewardedAd {
        if let rewardedAd {
            return rewardedAd
        }
        
        while isLoading {
            try await Task.sleep(nanoseconds: 100_000_000)
            if let rewardedAd {
                return rewardedAd
            }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let ad = try await RewardedAd.load(
            with: adUnitID,
            request: Request()
        )
        rewardedAd = ad
        return ad
    }
    
    private func finishPresentation(canOpenExplanation: Bool) {
        presentationContinuation?.resume(returning: canOpenExplanation)
        presentationContinuation = nil
        didEarnReward = false
        preload()
    }
}

extension GoogleRewardAdPresenter: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finishPresentation(canOpenExplanation: didEarnReward)
    }
    
    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        finishPresentation(canOpenExplanation: true)
    }
}
