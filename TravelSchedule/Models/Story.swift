import Foundation

struct Story: Identifiable, Hashable {
    let id: UUID
    let imageName: String
    let pages: [String]
    let title: String
    let subtitle: String

    init(
        id: UUID = UUID(),
        imageName: String,
        pages: [String],
        title: String,
        subtitle: String
    ) {
        self.id = id
        self.imageName = imageName
        self.pages = pages
        self.title = title
        self.subtitle = subtitle
    }
}

extension Story {

    private static let text = "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"

    static let mock: [Story] = [
        Story(imageName: "story_1", pages: ["story_1", "story_2"], title: text, subtitle: text),
        Story(imageName: "story_3", pages: ["story_3", "story_4"], title: text, subtitle: text),
        Story(imageName: "story_5", pages: ["story_5", "story_6"], title: text, subtitle: text),
        Story(imageName: "story_7", pages: ["story_7", "story_8"], title: text, subtitle: text),
        Story(imageName: "story_9", pages: ["story_9", "story_10"], title: text, subtitle: text),
        Story(imageName: "story_11", pages: ["story_11", "story_12"], title: text, subtitle: text),
        Story(imageName: "story_13", pages: ["story_13", "story_14"], title: text, subtitle: text),
        Story(imageName: "story_15", pages: ["story_15", "story_16"], title: text, subtitle: text),
        Story(imageName: "story_17", pages: ["story_17", "story_18"], title: text, subtitle: text)
    ]
}
