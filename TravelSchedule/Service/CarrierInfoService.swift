import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierInfo = Components.Schemas.CarrierResponse

protocol CarrierInfoServiceProtocol {
    func getCarrier(code: Int) async throws -> CarrierInfo
    func getCarrierLogoURL(code: Int) async throws -> URL?
}

final class CarrierInfoService: CarrierInfoServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getCarrier(code: Int) async throws -> CarrierInfo {
        let response = try await client.getCarrier(
            query: .init(
                apikey: apikey,
                code: code
            )
        )
        return try response.ok.body.json
    }

    func getCarrierLogoURL(code: Int) async throws -> URL? {
        let carrierResponse = try await getCarrier(code: code)

        guard
            let carrier = carrierResponse.carrier,
            let rawLogo = carrier.logo,
            !rawLogo.isEmpty
        else {
            return nil
        }

        if rawLogo.hasPrefix("//") {
            return URL(string: "https:" + rawLogo)
        }

        return URL(string: rawLogo)
    }
}
