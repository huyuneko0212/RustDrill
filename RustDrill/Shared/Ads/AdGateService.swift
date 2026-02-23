//
//  AdGateService.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation

@MainActor
protocol AdGateService {
    /// 解説表示前の広告ゲート
    /// true: 解説へ進める / false: キャンセル
    func showGateIfNeeded() async -> Bool
}

/// 広告をまだ実装していない間のダミー
/// ただし「何回に1回出すか」の判定だけ先に実装しておく
@MainActor
final class FrequencyControlledAdGateService: AdGateService {
    private let frequency: Int
    private let counterStore: AdGateCounterStore
    private let presenter: AdPresenting
    
    /// - parameter frequency: 何回に1回広告を出すか（例: 3）
    init(
        frequency: Int = 3,
        counterStore: AdGateCounterStore? = nil,
        presenter: AdPresenting? = nil
    ) {
        self.frequency = max(1, frequency)
        self.counterStore = counterStore ?? UserDefaultsAdGateCounterStore()
        self.presenter = presenter ?? NoopAdPresenter()
    }
    
    func showGateIfNeeded() async -> Bool {
        let count = counterStore.incrementAndGetExplanationTapCount()
        
        // 例: frequency=3 のとき 3,6,9... 回目で広告表示
        let shouldShowAd = (count % frequency == 0)
        
        if shouldShowAd {
            return await presenter.presentRewardAd()
        } else {
            return true
        }
    }
}
