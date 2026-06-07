//
//  GoogleRewardAdPresenter.swift
//  RustDrill
//
//  Created by Codex on 2026/05/23.
//

import Foundation
import GoogleMobileAds
import OSLog
import UIKit

@MainActor
final class GoogleRewardAdPresenter: NSObject, AdPresenting {
    private let logger = Logger(subsystem: "RustDrill", category: "RewardAd")
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
        guard !adUnitID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger.error("Reward ad unit ID is empty; skipping ad presentation.")
            return true
        }

        do {
            let ad = try await loadAdIfNeeded()
            rewardedAd = nil
            didEarnReward = false
            ad.fullScreenContentDelegate = self
            
            guard let viewController = Self.topViewController() else {
                logger.error("Reward ad presentation failed: root view controller not found")
                preload()
                return true
            }
            
            return await withCheckedContinuation { continuation in
                presentationContinuation = continuation
                ad.present(from: viewController) { [weak self, weak ad] in
                    self?.didEarnReward = true
                    _ = ad?.adReward
                }
            }
        } catch {
            logger.error("Reward ad load failed: \(error.localizedDescription, privacy: .public)")
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
    
    private static func topViewController() -> UIViewController? {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
        
        return topViewController(from: rootViewController)
    }
    
    private static func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }
        
        return viewController
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
