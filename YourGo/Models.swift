import Foundation

struct Player: Identifiable, Codable, Hashable { let id: UUID; var name: String }

struct Contribution: Identifiable, Codable, Hashable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    let text: String
    let createdAt: Date
    var wordCount: Int { WordCounter.count(text) }
}

struct Story: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var players: [Player]
    var contributions: [Contribution]
    var currentWriterName: String?
    var claimedByLocalPlayer: Bool
    var totalWords: Int { contributions.reduce(0) { $0 + $1.wordCount } }
    var lastContributorID: UUID? { contributions.last?.playerID }
}

enum WordCounter {
    static func words(in text: String) -> [Substring] { text.split(whereSeparator: { $0.isWhitespace }) }
    static func count(_ text: String) -> Int { words(in: text).count }
    static func limited(_ text: String, to limit: Int) -> String {
        guard count(text) > limit else { return text }
        return words(in: text).prefix(limit).joined(separator: " ")
    }
}
