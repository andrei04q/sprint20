import Foundation

struct StationChoice: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let yandexCode: String
    let settlementTitle: String?
    let stationType: String?
    let stationTypeName: String?

    init(
        title: String,
        yandexCode: String,
        settlementTitle: String? = nil,
        stationType: String? = nil,
        stationTypeName: String? = nil
    ) {
        self.id = yandexCode
        self.title = title
        self.yandexCode = yandexCode
        self.settlementTitle = settlementTitle
        self.stationType = stationType
        self.stationTypeName = stationTypeName
    }

    var shortStationTitle: String {
        guard let settlementTitle else { return title }

        let prefix = settlementTitle + " ("
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedTitle.hasPrefix(prefix), trimmedTitle.hasSuffix(")") else {
            return title
        }

        let startIndex = trimmedTitle.index(trimmedTitle.startIndex, offsetBy: prefix.count)
        let endIndex = trimmedTitle.index(before: trimmedTitle.endIndex)

        let inner = trimmedTitle[startIndex..<endIndex]
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return inner.isEmpty ? title : inner
    }
}
