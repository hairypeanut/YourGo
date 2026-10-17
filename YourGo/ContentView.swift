//
//  ContentView.swift
//  YourGo
//
//  Created by Andy Sadler on 17/10/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var hasEnteredApp = false
    @StateObject private var store = GameStore()
    var body: some View {
        Group {
            if hasEnteredApp { MainTabView().environmentObject(store) }
            else { WelcomeView { withAnimation(.spring) { hasEnteredApp = true } } }
        }.tint(YGTheme.orange)
    }
}

struct WelcomeView: View {
    let play: () -> Void
    var body: some View {
        ZStack {
            YGTheme.gold.ignoresSafeArea()
            Circle().fill(.white.opacity(0.25)).frame(width: 360).offset(x: 160, y: -260)
            VStack(spacing: 28) {
                Spacer()
                Image("YourGoWelcome").resizable().scaledToFit().frame(maxWidth: 430, maxHeight: 260).accessibilityLabel("Your Go welcome artwork")
                BrandMark()
                VStack(spacing: 4) {
                    Text("100 words or less.")
                    Text("Then it's their problem.").foregroundStyle(YGTheme.orange)
                }.font(.system(size: 30, weight: .black, design: .rounded)).multilineTextAlignment(.center).foregroundStyle(YGTheme.navy)
                Spacer()
                Button("LET'S PLAY", action: play).buttonStyle(PrimaryButtonStyle(color: YGTheme.navy)).readableWidth(480)
                Text("BUILD 001 · LOCAL PROTOTYPE").font(.caption.bold()).foregroundStyle(YGTheme.navy.opacity(0.65))
            }.padding(28)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            StoriesHomeView().tabItem { Label("Stories", systemImage: "book.pages.fill") }
            FriendsView().tabItem { Label("Friends", systemImage: "person.2.fill") }
            ProfileView().tabItem { Label("Me", systemImage: "person.crop.circle.fill") }
        }
    }
}

#Preview { ContentView() }
