import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ThreadStations = Components.Schemas.ThreadResponse

protocol ThreadStationsServiceProtocol {
    func getThread(uid: String, date: String?) async throws -> ThreadStations
}

final class ThreadStationsService: ThreadStationsServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getThread(uid: String, date: String?) async throws -> ThreadStations {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            date: date
        ))
        return try response.ok.body.json
    }
}
