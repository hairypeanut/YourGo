import SwiftUI

struct StoryDetailView: View {
    @EnvironmentObject private var store: GameStore
    let storyID: UUID
    @State private var showWriter = false
    private var story: Story? { store.stories.first { $0.id == storyID } }
    var body: some View {
        Group {
            if let story {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(story.title).font(.system(.largeTitle, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
                        HStack { Label("\(story.players.count) players", systemImage: "person.2.fill"); Spacer(); Label("\(story.totalWords) words", systemImage: "text.word.spacing") }.font(.subheadline.bold()).foregroundStyle(.secondary)
                        statusCard(story)
                        NavigationLink { StoryReaderView(storyID: storyID) } label: { Label("READ THE STORY SO FAR", systemImage: "book.fill") }.buttonStyle(PrimaryButtonStyle(color: YGTheme.navy))
                        if store.canClaim(story) {
                            Button("CLAIM YOUR GO") { store.claim(storyID: storyID); showWriter = true }.buttonStyle(PrimaryButtonStyle())
                            Text("This claim is stored locally for the BUILD 001 demo; it is not a secure multiplayer lock.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxWidth: .infinity)
                        } else if story.claimedByLocalPlayer {
                            Button("CONTINUE YOUR GO") { showWriter = true }.buttonStyle(PrimaryButtonStyle())
                        }
                    }.padding(22).readableWidth(700)
                }.background(YGTheme.cream.opacity(0.38)).navigationTitle("Story").navigationBarTitleDisplayMode(.inline).fullScreenCover(isPresented: $showWriter) { WritingView(storyID: storyID) }
            } else { ContentUnavailableView("Story unavailable", systemImage: "book.closed") }
        }
    }

    private func statusCard(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("CURRENT TURN").font(.caption.bold()).foregroundStyle(.secondary)
            Text(story.currentWriterName.map { $0 == store.localPlayer.name ? "YOUR GO!" : "\($0.uppercased()) IS WRITING" } ?? (store.canClaim(story) ? "READY TO CLAIM" : "WAITING FOR A FRIEND"))
                .font(.system(.title2, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
            Text("\(store.remainingWords(for: story)) words remaining today").font(.subheadline.bold()).foregroundStyle(YGTheme.orange)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(20).background(YGTheme.gold, in: RoundedRectangle(cornerRadius: 22))
    }
}

struct StoryReaderView: View {
    @EnvironmentObject private var store: GameStore
    let storyID: UUID
    private var story: Story? { store.stories.first { $0.id == storyID } }
    var body: some View {
        ScrollView {
            if let story {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("THE STORY SO FAR").font(.caption.bold()).foregroundStyle(YGTheme.orange)
                        Text(story.title).font(.system(.largeTitle, design: .serif, weight: .bold)).foregroundStyle(YGTheme.navy)
                    }
                    Divider()
                    if story.contributions.isEmpty { Text("The first words are waiting to be written…").italic().foregroundStyle(.secondary) }
                    ForEach(story.contributions) { contribution in
                        VStack(alignment: .leading, spacing: 9) {
                            Text(contribution.playerName.uppercased()).font(.caption.bold()).tracking(1.5).foregroundStyle(YGTheme.orange)
                            Text(contribution.text).font(.system(size: 21, design: .serif)).lineSpacing(8).foregroundStyle(YGTheme.navy)
                        }
                    }
                }.padding(.horizontal, 28).padding(.vertical, 38).readableWidth(720).background(YGTheme.cream)
            }
        }.background(YGTheme.navy.opacity(0.08)).navigationTitle("Reader").navigationBarTitleDisplayMode(.inline)
    }
}

struct WritingView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss
    let storyID: UUID
    @State private var text = ""; @State private var confirm = false; @State private var submitted = false
    @State private var seconds = 600
    @FocusState private var editorFocused: Bool
    private var story: Story? { store.stories.first { $0.id == storyID } }
    private var limit: Int { story.map(store.remainingWords) ?? 0 }
    private var count: Int { WordCounter.count(text) }
    var body: some View {
        NavigationStack {
            Group {
                if submitted { successView }
                else { writerView }
            }.toolbar { if !submitted { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { store.release(storyID: storyID); dismiss() } } } }
        }.interactiveDismissDisabled(!submitted).alert("Submit your Go?", isPresented: $confirm) {
            Button("Keep Writing", role: .cancel) {}; Button("Submit") { store.submit(text, to: storyID); withAnimation { submitted = true } }
        } message: { Text("This adds \(count) words to the story. You won't be able to take the very next turn.") }
        .task { while seconds > 0 && !submitted { try? await Task.sleep(for: .seconds(1)); seconds -= 1 } }
    }

    private var writerView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack { VStack(alignment: .leading) { Text("YOUR GO!").font(.system(.largeTitle, design: .rounded, weight: .black)); Text(story?.title ?? "") }; Spacer(); Text(String(format: "%02d:%02d", seconds / 60, seconds % 60)).font(.headline.monospacedDigit()).padding(10).background(YGTheme.gold, in: Capsule()) }
                    Text("LOCAL DEMO CLAIM").font(.caption2.bold()).foregroundStyle(.secondary)
                    if let previous = story?.contributions.last {
                        VStack(alignment: .leading, spacing: 7) { Text("PREVIOUSLY · \(previous.playerName.uppercased())").font(.caption.bold()).foregroundStyle(YGTheme.orange); Text(previous.text).lineLimit(4).foregroundStyle(YGTheme.navy) }.padding(16).background(YGTheme.cream, in: RoundedRectangle(cornerRadius: 18))
                    }
                    TextEditor(text: $text).focused($editorFocused).frame(minHeight: 250).padding(10).scrollContentBackground(.hidden).background(.white, in: RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(YGTheme.gold, lineWidth: 3)).id("editor").onChange(of: text) { _, value in text = WordCounter.limited(value, to: limit) }
                    HStack { Text("\(count) / \(limit)").font(.headline.monospacedDigit()); Spacer(); Text("\(max(0, limit - count)) left today").font(.subheadline.bold()) }
                    ProgressView(value: Double(count), total: Double(max(1, limit))).tint(count == limit ? YGTheme.orange : YGTheme.gold).scaleEffect(y: 2)
                    Button { editorFocused = false } label: { Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down") }.frame(maxWidth: .infinity)
                    Button("SUBMIT MY GO") { editorFocused = false; confirm = true }.buttonStyle(PrimaryButtonStyle()).disabled(count < 1)
                }.padding(20).readableWidth(720).foregroundStyle(YGTheme.navy)
            }.scrollDismissesKeyboard(.interactively).background(YGTheme.gold.opacity(0.16)).onChange(of: editorFocused) { _, focused in if focused { withAnimation { proxy.scrollTo("editor", anchor: .center) } } }
        }
    }

    private var successView: some View {
        VStack(spacing: 22) {
            Spacer(); Image(systemName: "party.popper.fill").font(.system(size: 84)).foregroundStyle(YGTheme.orange).symbolEffect(.bounce)
            Text("GO SUBMITTED!").font(.system(.largeTitle, design: .rounded, weight: .black)).foregroundStyle(YGTheme.navy)
            Text("Now it's their problem.").font(.title2.bold()).foregroundStyle(YGTheme.orange)
            Text("Your words are safely stored on this device.").foregroundStyle(.secondary)
            Spacer(); Button("BACK TO THE STORY") { dismiss() }.buttonStyle(PrimaryButtonStyle(color: YGTheme.navy))
        }.padding(28).background(YGTheme.gold.ignoresSafeArea())
    }
}
