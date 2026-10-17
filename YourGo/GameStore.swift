import Foundation
import SwiftUI
import Combine

@MainActor
final class GameStore: ObservableObject {
    @Published var friends: [Player] { didSet { save() } }
    @Published var stories: [Story] { didSet { save() } }
    @Published var dailyUsage: [String: Int] { didSet { save() } }
    let localPlayer = Player(id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!, name: "Andy")
    private let saveURL: URL
    private let encoder = JSONEncoder()

    init() {
        saveURL = URL.documentsDirectory.appending(path: "yourgo-build001.json")
        if let data = try? Data(contentsOf: saveURL), let saved = try? JSONDecoder().decode(SavedData.self, from: data) {
            friends = saved.friends; stories = saved.stories; dailyUsage = saved.dailyUsage
        } else {
            let demo = Self.demoData(); friends = demo.friends; stories = demo.stories
            dailyUsage = [Self.usageKey(storyID: demo.stories[2].id): 100]
        }
    }

    func remainingWords(for story: Story) -> Int { max(0, 100 - (dailyUsage[Self.usageKey(storyID: story.id)] ?? 0)) }
    func canClaim(_ story: Story) -> Bool { story.currentWriterName == nil && story.lastContributorID != localPlayer.id && remainingWords(for: story) > 0 }

    func claim(storyID: UUID) {
        guard let index = stories.firstIndex(where: { $0.id == storyID }), canClaim(stories[index]) else { return }
        stories[index].claimedByLocalPlayer = true; stories[index].currentWriterName = localPlayer.name
    }

    func release(storyID: UUID) {
        guard let index = stories.firstIndex(where: { $0.id == storyID }) else { return }
        stories[index].claimedByLocalPlayer = false; stories[index].currentWriterName = nil
    }

    func submit(_ text: String, to storyID: UUID) {
        guard let index = stories.firstIndex(where: { $0.id == storyID }) else { return }
        let permitted = WordCounter.limited(text, to: remainingWords(for: stories[index]))
        guard WordCounter.count(permitted) > 0 else { return }
        stories[index].contributions.append(Contribution(id: UUID(), playerID: localPlayer.id, playerName: localPlayer.name, text: permitted, createdAt: .now))
        dailyUsage[Self.usageKey(storyID: storyID), default: 0] += WordCounter.count(permitted)
        stories[index].claimedByLocalPlayer = false; stories[index].currentWriterName = nil
    }

    func createStory(title: String, opening: String, selectedFriendIDs: Set<UUID>) -> UUID {
        let id = UUID(); var contributions: [Contribution] = []
        let clean = WordCounter.limited(opening.trimmingCharacters(in: .whitespacesAndNewlines), to: 100)
        if !clean.isEmpty {
            contributions.append(Contribution(id: UUID(), playerID: localPlayer.id, playerName: localPlayer.name, text: clean, createdAt: .now))
            dailyUsage[Self.usageKey(storyID: id)] = WordCounter.count(clean)
        }
        stories.insert(Story(id: id, title: title.trimmingCharacters(in: .whitespacesAndNewlines), players: [localPlayer] + friends.filter { selectedFriendIDs.contains($0.id) }, contributions: contributions, currentWriterName: nil, claimedByLocalPlayer: false), at: 0)
        return id
    }

    func addFriend(named name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !friends.contains(where: { $0.name.caseInsensitiveCompare(clean) == .orderedSame }) else { return }
        friends.append(Player(id: UUID(), name: clean))
    }
    func removeFriends(at offsets: IndexSet) { friends.remove(atOffsets: offsets) }

    private func save() {
        if let data = try? encoder.encode(SavedData(friends: friends, stories: stories, dailyUsage: dailyUsage)) { try? data.write(to: saveURL, options: .atomic) }
    }
    private static func usageKey(storyID: UUID) -> String { "\(Calendar.current.startOfDay(for: .now).timeIntervalSince1970)-\(storyID.uuidString)" }
    private struct SavedData: Codable { let friends: [Player]; let stories: [Story]; let dailyUsage: [String: Int] }

    private static func demoData() -> (friends: [Player], stories: [Story]) {
        let local = Player(id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!, name: "Andy")
        let charlotte = Player(id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!, name: "Charlotte")
        let carole = Player(id: UUID(uuidString: "20000000-0000-0000-0000-000000000002")!, name: "Carole")
        let dave = Player(id: UUID(uuidString: "20000000-0000-0000-0000-000000000003")!, name: "Dave")
        let sophie = Player(id: UUID(uuidString: "20000000-0000-0000-0000-000000000004")!, name: "Sophie")
        func c(_ id: String, _ player: Player, _ text: String) -> Contribution { Contribution(id: UUID(uuidString: id)!, playerID: player.id, playerName: player.name, text: text, createdAt: .now) }
        let holiday = Story(id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!, title: "The Holiday From Hell", players: [local, charlotte, carole, dave, sophie], contributions: [
            c("40000000-0000-0000-0000-000000000001", charlotte, "It all began on a summer's night, with a suitcase that definitely wasn't ours and a taxi driver who refused to look us in the eye."),
            c("40000000-0000-0000-0000-000000000002", carole, "By sunrise we were stranded beside a suspiciously quiet theme park, holding three passports, a rubber duck and the keys to a room we'd never booked.")
        ], currentWriterName: nil, claimedByLocalPlayer: false)
        let murder = Story(id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!, title: "Murder at Number 6", players: [local, charlotte, carole, dave], contributions: [c("40000000-0000-0000-0000-000000000003", dave, "Nobody on Willow Lane admitted to hearing the crash. They did, however, all remember the clock stopping at precisely six minutes past midnight.")], currentWriterName: "Charlotte", claimedByLocalPlayer: false)
        let camping = Story(id: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!, title: "The Camping Trip", players: [local, sophie, dave], contributions: [c("40000000-0000-0000-0000-000000000004", local, "The tent instructions promised five easy steps. We were on step two when the wind stole the roof, Dave lost a boot, and something in the woods laughed.")], currentWriterName: nil, claimedByLocalPlayer: false)
        return ([charlotte, carole, dave, sophie], [holiday, murder, camping])
    }
}
