import Foundation
import OpenAPIRuntime

final class StationsListService {

    enum ServiceError: Error {
        case invalidRequestURL
    }

    private let apikey: String

    init(client: Client, apikey: String) {
        self.apikey = apikey
    }

    func loadStationsData() async throws -> Data {
        guard var components = URLComponents(string: "https://api.rasp.yandex-net.ru/v3.0/stations_list/") else {
            throw ServiceError.invalidRequestURL
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU")
        ]

        guard let requestURL = components.url else {
            throw ServiceError.invalidRequestURL
        }

        let (data, response) = try await URLSession.shared.data(from: requestURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
