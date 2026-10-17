import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var store: GameStore
    @State private var newName = ""; @State private var adding = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) { Image(systemName: "person.2.fill").font(.largeTitle).foregroundStyle(YGTheme.orange); VStack(alignment: .leading) { Text("YOUR PEOPLE").font(.system(.title2, design: .rounded, weight: .black)); Text("Local demo friends on this device").font(.caption).foregroundStyle(.secondary) } }.padding(.vertical, 8)
                }
                Section("FRIENDS") {
                    ForEach(store.friends) { friend in Label(friend.name, systemImage: "person.crop.circle.fill").font(.headline).padding(.vertical, 7) }.onDelete(perform: store.removeFriends)
                }
                Section { Button { adding = true } label: { Label("Add a demo friend", systemImage: "person.badge.plus") }.fontWeight(.bold) } footer: { Text("Online friend requests and discovery are not part of BUILD 001.") }
            }.navigationTitle("Friends").alert("Add a demo friend", isPresented: $adding) { TextField("Name", text: $newName); Button("Cancel", role: .cancel) { newName = "" }; Button("Add") { store.addFriend(named: newName); newName = "" } } message: { Text("This friend exists only on this device.") }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: GameStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    BrandMark().padding(.top, 28)
                    ZStack { Circle().fill(YGTheme.gold); Text(String(store.localPlayer.name.prefix(1))).font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(YGTheme.navy) }.frame(width: 110, height: 110)
                    VStack(spacing: 5) { Text(store.localPlayer.name).font(.system(.title, design: .rounded, weight: .black)); Text("DEMO PLAYER").font(.caption.bold()).foregroundStyle(YGTheme.orange) }
                    Label("Local prototype · BUILD 001", systemImage: "iphone").font(.subheadline.bold()).padding(12).background(YGTheme.cream, in: Capsule())
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ABOUT YOUR GO").font(.system(.title3, design: .rounded, weight: .black))
                        Text("A playful collaborative storytelling game. Take your turn in 100 words or less—then pass the problem to your friends.")
                        Divider(); Text("This build stores stories, friends and contributions locally. It does not include accounts, cloud sync or online multiplayer.").font(.callout).foregroundStyle(.secondary)
                    }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 22)).shadow(color: YGTheme.navy.opacity(0.08), radius: 10, y: 4)
                }.padding(22).readableWidth(620).foregroundStyle(YGTheme.navy)
            }.background(YGTheme.gold.opacity(0.12)).navigationTitle("Me")
        }
    }
}
