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
                    Label("ホーム", systemImage: "house")
                }
            
            ReviewListView()
                .tabItem {
                    Label("復習", systemImage: "arrow.clockwise.circle")
                }
        }
    }
}
