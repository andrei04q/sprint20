import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@MainActor
final class CarrierLogoService: ObservableObject {

    static let shared = CarrierLogoService()

    private let client: Client?
    private var cache: [Int: URL] = [:]

    private init() {
        guard let serverURL = try? Servers.Server1.url() else {
            self.client = nil
            return
        }

        self.client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }

    func logoURL(for carrierCode: Int?) async -> URL? {
        guard let carrierCode else { return nil }
        guard let client else { return nil }

        if let cached = cache[carrierCode] {
            return cached
        }

        do {
            let response = try await client.getCarrier(
                query: .init(
                    apikey: APIKey.yandexRasp,
                    code: carrierCode
                )
            )

            let rawLogo = try response.ok.body.json.carrier?.logo
            guard let rawLogo, !rawLogo.isEmpty else {
                return nil
            }

            let normalizedLogo: String
            if rawLogo.hasPrefix("//") {
                normalizedLogo = "https:" + rawLogo
            } else {
                normalizedLogo = rawLogo
            }

            guard let url = URL(string: normalizedLogo) else {
                return nil
            }

            cache[carrierCode] = url
            return url
        } catch {
            return nil
        }
    }
}
