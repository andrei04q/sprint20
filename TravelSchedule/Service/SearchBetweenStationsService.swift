import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class SearchBetweenStationsService {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func search(from: String, to: String, date: String?) async throws -> Components.Schemas.SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            date: date
        ))
        return try response.ok.body.json
    }
    
    func searchRawData(from: String, to: String, date: String?) async throws -> Data {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            date: date
        ))
        
        let model = try response.ok.body.json
        
        return try JSONEncoder().encode(model)
    }
}
