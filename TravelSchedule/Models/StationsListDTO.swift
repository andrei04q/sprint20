import Foundation

// MARK: - DTO for stations_list

struct StationsListDTO: Decodable {
    let countries: [CountryDTO]
}

struct CountryDTO: Decodable {
    let regions: [RegionDTO]?
}

struct RegionDTO: Decodable {
    let settlements: [SettlementDTO]?
}

struct SettlementDTO: Decodable {
    let title: String?
    let stations: [StationDTO]?
}

struct StationDTO: Decodable {
    let title: String?
    let codes: CodesDTO?
}

struct CodesDTO: Decodable {
    let yandexCode: String?

    enum CodingKeys: String, CodingKey {
        case yandexCode = "yandex_code"
    }
}
