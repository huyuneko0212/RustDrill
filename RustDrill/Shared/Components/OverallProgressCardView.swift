//
//  OverallProgressCardView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/04/03.
//

import SwiftUI

struct OverallProgressCardView: View {
    let solvedCount: Int
    let totalCount: Int
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(solvedCount) / Double(totalCount)
    }
    
    private var percentageText: String {
        AppUIConstants.Strings.progressPercentage(progress)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("総合進捗")
                .font(.headline)
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AppUIConstants.Colors.accent,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text(percentageText)
                            .font(.title2.bold())
                        
                        Text(AppUIConstants.Strings.progressCount(solvedCount: solvedCount, totalCount: totalCount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 110, height: 110)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("解いた問題数")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(AppUIConstants.Strings.questionCount(solvedCount))
                        .font(.title3.bold())
                    
                    Text(Constants.Strings.totalQuestionCount(totalCount))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum Constants {
    enum Strings {
        static func totalQuestionCount(_ count: Int) -> String {
            "全 \(count) 問"
        }
    }
}
