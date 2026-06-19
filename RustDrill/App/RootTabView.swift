//
//  RootTabView.swift
//  RustDrill
//
//  Created by huyuneko on 2026/02/23.
//

import SwiftUI

struct RootTabView: View {
    private enum Tab: Hashable {
        case home
        case review
        case vocabulary
        case settings
    }

    @State private var selectedTab: Tab = .home
    @State private var homeResetID = UUID()

    var body: some View {
        TabView(selection: tabSelection) {
            HomeView()
                .id(homeResetID)
                .tabItem {
                    Label(
                        AppUIConstants.Strings.homeTitle,
                        systemImage: AppUIConstants.Symbols.home
                    )
                }
                .tag(Tab.home)
            
            ReviewListView()
                .tabItem {
                    Label(
                        AppUIConstants.Strings.reviewTitle,
                        systemImage: AppUIConstants.Symbols.review
                    )
                }
                .tag(Tab.review)

            VocabularyView()
                .tabItem {
                    Label(
                        AppUIConstants.Strings.vocabularyTitle,
                        systemImage: AppUIConstants.Symbols.vocabulary
                    )
                }
                .tag(Tab.vocabulary)

            SettingsView()
                .tabItem {
                    Label(
                        AppUIConstants.Strings.settingsTitle,
                        systemImage: AppUIConstants.Symbols.settings
                    )
                }
                .tag(Tab.settings)
        }
    }

    private var tabSelection: Binding<Tab> {
        Binding {
            selectedTab
        } set: { newTab in
            if newTab == .home {
                homeResetID = UUID()
            }
            selectedTab = newTab
        }
    }
}
