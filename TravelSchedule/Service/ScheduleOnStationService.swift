import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ScheduleOnStation = Components.Schemas.ScheduleResponse

protocol ScheduleOnStationServiceProtocol {
    func getSchedule(station: String, date: String?) async throws -> ScheduleOnStation
}

final class ScheduleOnStationService: ScheduleOnStationServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getSchedule(station: String, date: String?) async throws -> ScheduleOnStation {
        let response = try await client.getSchedule(query: .init(
            apikey: apikey,
            station: station,
            date: date
        ))
        return try response.ok.body.json
    }
}
