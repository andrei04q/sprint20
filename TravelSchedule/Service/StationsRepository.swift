import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class StationsRepository {

    enum RepositoryError: Error {
        case invalidServerURL
    }

    static let shared = StationsRepository()

    private let service: StationsListService?
    private var cached: [StationChoice]?

    private init() {
        guard let serverURL = try? Servers.Server1.url() else {
            service = nil
            return
        }

        let client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )

        service = StationsListService(
            client: client,
            apikey: APIKey.yandexRasp
        )
    }

    func loadStations() async throws -> [StationChoice] {
        if let cached {
            return cached
        }

        guard let service else {
            throw RepositoryError.invalidServerURL
        }

        let data = try await service.loadStationsData()
        let stations = parse(data: data)
        cached = stations
        return stations
    }

    private func parse(data: Data) -> [StationChoice] {
        guard let response = try? JSONDecoder().decode(StationsResponse.self, from: data) else {
            return []
        }

        var result: [StationChoice] = []

        for country in response.countries {
            for region in country.regions {
                for settlement in region.settlements {
                    for station in settlement.stations {
                        let item = StationChoice(
                            title: station.title,
                            yandexCode: station.codes.yandexCode,
                            settlementTitle: settlement.title,
                            stationType: station.stationType,
                            stationTypeName: station.stationTypeName
                        )
                        result.append(item)
                    }
                }
            }
        }

        return result.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
}

// MARK: - DTO

private struct StationsResponse: Decodable {
    let countries: [Country]
}

private struct Country: Decodable {
    let regions: [Region]
}

private struct Region: Decodable {
    let settlements: [Settlement]
}

private struct Settlement: Decodable {
    let title: String?
    let stations: [Station]
}

private struct Station: Decodable {
    let title: String
    let stationType: String?
    let stationTypeName: String?
    let codes: StationCodes

    enum CodingKeys: String, CodingKey {
        case title
        case stationType = "station_type"
        case stationTypeName = "station_type_name"
        case codes
    }
}

private struct StationCodes: Decodable {
    let yandexCode: String

    enum CodingKeys: String, CodingKey {
        case yandexCode = "yandex_code"
    }
}
