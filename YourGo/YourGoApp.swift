//
//  YourGoApp.swift
//  YourGo
//
//  Created by Andy Sadler on 17/10/2026.
//

import SwiftUI

@main
struct YourGoApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(YGTheme.navy)
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray3
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray3]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(YGTheme.gold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(YGTheme.gold)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
