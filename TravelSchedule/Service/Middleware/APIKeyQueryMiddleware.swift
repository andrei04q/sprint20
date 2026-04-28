import Foundation
import OpenAPIRuntime
import HTTPTypes

struct APIKeyQueryMiddleware: ClientMiddleware {

    let apiKey: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {

        var request = request

        guard let path = request.path,
              let url = URL(string: path, relativeTo: baseURL),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            return try await next(request, body, baseURL)
        }

        var items = components.queryItems ?? []
        if items.contains(where: { $0.name == "apikey" }) == false {
            items.append(URLQueryItem(name: "apikey", value: apiKey))
            components.queryItems = items

            let newPath = components.percentEncodedPath.isEmpty ? "/" : components.percentEncodedPath
            let newQuery = components.percentEncodedQuery.map { "?\($0)" } ?? ""
            request.path = newPath + newQuery
        }

        return try await next(request, body, baseURL)
    }
}
