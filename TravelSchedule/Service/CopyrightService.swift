import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias YandexRaspCopyright = Components.Schemas.CopyrightResponse

protocol CopyrightServiceProtocol {
    func getCopyright() async throws -> YandexRaspCopyright
}

final class CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getCopyright() async throws -> YandexRaspCopyright {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey
        ))
        return try response.ok.body.json
    }
}

