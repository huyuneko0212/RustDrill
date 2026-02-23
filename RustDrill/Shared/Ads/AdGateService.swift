//
//  AdGateService.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import Foundation

@MainActor
protocol AdGateService {
    /// 解説表示前に広告を挟む（将来実装）
    /// 今は何もせず成功扱い
    func showGateIfNeeded() async -> Bool
}

@MainActor
final class NoopAdGateService: AdGateService {
    func showGateIfNeeded() async -> Bool {
        // 将来: リワード広告などの表示処理
        true
    }
}
