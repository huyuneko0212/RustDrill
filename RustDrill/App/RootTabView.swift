//
//  RootTabView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(
                        AppUIConstants.Strings.homeTitle,
                        systemImage: AppUIConstants.Symbols.home
                    )
                }
            
            ReviewListView()
                .tabItem {
                    Label(
                        AppUIConstants.Strings.reviewTitle,
                        systemImage: AppUIConstants.Symbols.review
                    )
                }
        }
    }
}
