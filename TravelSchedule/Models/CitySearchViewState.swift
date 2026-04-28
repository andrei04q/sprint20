import Foundation

enum CitySearchViewState: Equatable {
    case loading
    case success([StationChoice])
    case error(LoadError)
}
