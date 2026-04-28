import Foundation

struct StorySeenStore {
    private static let key = "seen_story_ids"

    static func seenIDs() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(array)
    }

    static func isSeen(_ story: Story) -> Bool {
        seenIDs().contains(story.id.uuidString)
    }

    static func markSeen(_ story: Story) {
        var ids = seenIDs()
        ids.insert(story.id.uuidString)
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
