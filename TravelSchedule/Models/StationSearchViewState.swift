import Foundation

enum StationSearchViewState: Equatable {
    case loading
    case success([StationChoice])
    case error(LoadError)
}
