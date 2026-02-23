//
//  AdPresenting.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation

@MainActor
protocol AdPresenting {
    /// 広告表示成功 or スキップ許可で true
    /// 広告失敗/キャンセルで false（必要なら）
    func presentRewardAd() async -> Bool
}

@MainActor
final class NoopAdPresenter: AdPresenting {
    func presentRewardAd() async -> Bool {
        // まだ広告SDK未導入なので常に通す
        true
    }
}
