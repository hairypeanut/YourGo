import SwiftUI

struct StoriesHomeView: View {
    @EnvironmentObject private var store: GameStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BrandMark().padding(.top, 10)
                    HStack(spacing: 12) {
                        NavigationLink { CreateStoryView() } label: { Label("CREATE A STORY", systemImage: "plus.circle.fill") }.buttonStyle(PrimaryButtonStyle())
                        NavigationLink { JoinStoryView() } label: { Label("JOIN A STORY", systemImage: "number") }.buttonStyle(PrimaryButtonStyle(color: YGTheme.navy))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Text("MY STORIES").font(.system(.title2, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
                    LazyVStack(spacing: 14) {
                        ForEach(store.stories) { story in NavigationLink(value: story.id) { StoryCard(story: story) }.buttonStyle(.plain) }
                    }
                }.padding(20).readableWidth(760)
            }.background(YGTheme.cream.opacity(0.35)).navigationDestination(for: UUID.self) { StoryDetailView(storyID: $0) }.toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct StoryCard: View {
    @EnvironmentObject private var store: GameStore
    let story: Story
    private var status: (String, Color, String) {
        if store.remainingWords(for: story) == 0 { return ("100/100 Today", .gray, "checkmark.circle.fill") }
        if let writer = story.currentWriterName { return (writer == store.localPlayer.name ? "Your Go!" : "\(writer)'s Writing", YGTheme.orange, "pencil.circle.fill") }
        if store.canClaim(story) { return ("Your Go!", YGTheme.orange, "bolt.circle.fill") }
        return ("Waiting for a friend", .gray, "clock.fill")
    }
    var body: some View {
        HStack(spacing: 16) {
            ZStack { RoundedRectangle(cornerRadius: 16).fill(status.1.opacity(0.14)); Image(systemName: status.2).font(.title).foregroundStyle(status.1) }.frame(width: 58, height: 70)
            VStack(alignment: .leading, spacing: 7) {
                Text(story.title).font(.system(.headline, design: .rounded, weight: .bold)).foregroundStyle(YGTheme.navy)
                Text(status.0).font(.subheadline.bold()).foregroundStyle(status.1)
                HStack { Label("\(story.players.count) players", systemImage: "person.2"); Label("\(story.totalWords) words", systemImage: "text.word.spacing") }.font(.caption).foregroundStyle(.secondary)
            }
            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }.padding(16).background(.background, in: RoundedRectangle(cornerRadius: 22)).shadow(color: YGTheme.navy.opacity(0.08), radius: 10, y: 5)
    }
}

struct CreateStoryView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""; @State private var opening = ""; @State private var selected = Set<UUID>()
    @State private var showInviteInfo = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("START SOMETHING").font(.system(.largeTitle, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
                TextField("Story title", text: $title).textFieldStyle(.roundedBorder).font(.title3.bold())
                VStack(alignment: .leading, spacing: 8) {
                    Text("OPTIONAL OPENING").font(.caption.bold()).foregroundStyle(.secondary)
                    TextEditor(text: $opening).frame(minHeight: 130).padding(8).scrollContentBackground(.hidden).background(.white, in: RoundedRectangle(cornerRadius: 16)).onChange(of: opening) { _, value in opening = WordCounter.limited(value, to: 100) }
                    Text("\(WordCounter.count(opening)) / 100 words").font(.caption.monospacedDigit()).frame(maxWidth: .infinity, alignment: .trailing)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("PICK YOUR PLAYERS").font(.caption.bold()).foregroundStyle(.secondary)
                    ForEach(store.friends) { friend in
                        Button { if selected.contains(friend.id) { selected.remove(friend.id) } else { selected.insert(friend.id) } } label: {
                            HStack { Image(systemName: selected.contains(friend.id) ? "checkmark.circle.fill" : "circle"); Text(friend.name).fontWeight(.semibold); Spacer() }.foregroundStyle(YGTheme.navy)
                        }
                    }
                    Button { showInviteInfo = true } label: { Label("Invite someone new", systemImage: "person.badge.plus") }.fontWeight(.bold)
                }.padding(18).background(YGTheme.gold.opacity(0.22), in: RoundedRectangle(cornerRadius: 20))
                Button("CREATE STORY") { _ = store.createStory(title: title, opening: opening, selectedFriendIDs: selected); dismiss() }.buttonStyle(PrimaryButtonStyle()).disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding(20).readableWidth()
        }.background(YGTheme.cream.opacity(0.4)).navigationTitle("New Story").navigationBarTitleDisplayMode(.inline)
            .alert("Invites are coming later", isPresented: $showInviteInfo) { Button("Got it") {} } message: { Text("BUILD 001 keeps everything on this device. Shareable invite codes will become active when secure multiplayer is added.") }
    }
}

struct JoinStoryView: View {
    @State private var code = ""; @State private var showDemo = false
    var body: some View {
        VStack(spacing: 26) {
            Spacer(); Image(systemName: "number.square.fill").font(.system(size: 70)).foregroundStyle(YGTheme.orange)
            Text("JOIN A STORY").font(.system(.largeTitle, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
            Text("ENTER INVITE CODE").font(.caption.bold()).foregroundStyle(.secondary)
            TextField("ABC123", text: $code).textInputAutocapitalization(.characters).autocorrectionDisabled().multilineTextAlignment(.center).font(.system(size: 32, weight: .black, design: .monospaced)).padding().background(.white, in: RoundedRectangle(cornerRadius: 18)).onChange(of: code) { _, value in code = String(value.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(6)) }
            Text("Invite codes are display-only in this local prototype. No connection to another device will be made.").font(.callout).multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button("TRY DEMO CODE") { showDemo = true }.buttonStyle(PrimaryButtonStyle()).disabled(code.count != 6)
            Spacer()
        }.padding(24).readableWidth(520).background(YGTheme.cream.opacity(0.4)).navigationTitle("Join Story").alert("Demo only", isPresented: $showDemo) { Button("OK") {} } message: { Text("That looks like a valid six-character code. Online joining arrives with multiplayer in a future build.") }
    }
}
