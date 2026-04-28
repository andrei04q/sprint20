import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@MainActor
final class ScheduleViewModel: ObservableObject {
    
    enum State {
        case idle
        case loading
        case loaded
        case failed(LoadError)
    }
    
    struct Ride: Identifiable {
        let id: UUID
        let title: String
        let departureTime: String
        let arrivalTime: String
        let durationText: String?
        let carrier: String?
        let transferText: String?
        let dateText: String?
        let departureDate: Date?
        let carrierCode: Int?
        
        init(
            id: UUID = UUID(),
            title: String,
            departureTime: String,
            arrivalTime: String,
            durationText: String?,
            carrier: String?,
            transferText: String?,
            dateText: String?,
            departureDate: Date?,
            carrierCode: Int?
        ) {
            self.id = id
            self.title = title
            self.departureTime = departureTime
            self.arrivalTime = arrivalTime
            self.durationText = durationText
            self.carrier = carrier
            self.transferText = transferText
            self.dateText = dateText
            self.departureDate = departureDate
            self.carrierCode = carrierCode
        }
    }
    
    @Published var state: State = .idle
    @Published var rides: [Ride] = []
    @Published var filter: DepartureFilter?
    
    private var allRides: [Ride] = []
    
    private let searchService: SearchBetweenStationsService?
    
    init() {
        guard let serverURL = try? Servers.Server1.url() else {
            self.searchService = nil
            return
        }
        
        let client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
        
        self.searchService = SearchBetweenStationsService(
            client: client,
            apikey: APIKey.yandexRasp
        )
    }
    
    private static let ymdFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
    
    private static let fallbackISOFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    func load(from: StationChoice, to: StationChoice) async {
        guard let searchService else {
            state = .failed(.server)
            return
        }
        
        state = .loading
        
        do {
            let dateString = Self.ymdFormatter.string(from: Date())
            
            let response = try await searchService.search(
                from: from.yandexCode,
                to: to.yandexCode,
                date: dateString
            )
            
            let segments = response.segments ?? []
            
            let loadedRides = segments.map { segment in
                let departureDate = parseAPIDate(segment.departure)
                let arrivalDate = parseAPIDate(segment.arrival)
                
                let transfersText: String? = {
                    if let hasTransfers = segment.has_transfers, hasTransfers {
                        return "С пересадкой"
                    }
                    return nil
                }()
                
                let carrierTitle = segment.thread?.carrier?.title?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let displayTitle: String
                if let carrierTitle, !carrierTitle.isEmpty {
                    displayTitle = carrierTitle
                } else {
                    displayTitle = "—"
                }
                
                return Ride(
                    title: displayTitle,
                    departureTime: formattedTime(from: segment.departure),
                    arrivalTime: formattedTime(from: segment.arrival),
                    durationText: formatDuration(segment.duration),
                    carrier: carrierTitle,
                    transferText: transfersText,
                    dateText: formattedDate(from: departureDate ?? arrivalDate),
                    departureDate: departureDate ?? arrivalDate,
                    carrierCode: segment.thread?.carrier?.code
                )
            }
            
            allRides = loadedRides
            applyCurrentFilters()
            state = .loaded
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                state = .failed(.noInternet)
            } else {
                state = .failed(.server)
            }
        } catch {
            state = .failed(.server)
        }
    }
    
    func applyFilter(_ filter: DepartureFilter) {
        self.filter = filter
        applyCurrentFilters()
    }
    
    private func applyCurrentFilters() {
        guard let filter else {
            rides = allRides
            return
        }
        
        let hasEnabledTimeFilter =
        filter.morning ||
        filter.day ||
        filter.evening ||
        filter.night
        
        rides = allRides.filter { ride in
            let timeMatches: Bool
            
            if hasEnabledTimeFilter {
                guard let departureDate = ride.departureDate else {
                    return false
                }
                
                let hour = Calendar.current.component(.hour, from: departureDate)
                timeMatches = matchesTimeFilter(hour: hour, filter: filter)
            } else {
                timeMatches = true
            }
            
            if filter.allowTransfers == false, ride.transferText != nil {
                return false
            }
            
            return timeMatches
        }
    }
    
    private func matchesTimeFilter(hour: Int, filter: DepartureFilter) -> Bool {
        if filter.morning, hour >= 6, hour < 12 { return true }
        if filter.day, hour >= 12, hour < 18 { return true }
        if filter.evening, hour >= 18, hour < 24 { return true }
        if filter.night, hour >= 0, hour < 6 { return true }
        return false
    }
    
    private func parseAPIDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: value) {
            return date
        }
        
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }
        
        return Self.fallbackISOFormatter.date(from: value)
    }
    
    private func formattedTime(from value: String?) -> String {
        guard let date = parseAPIDate(value) else { return "—" }
        return Self.timeFormatter.string(from: date)
    }
    
    private func formattedDate(from date: Date?) -> String? {
        guard let date else { return nil }
        return Self.dateFormatter.string(from: date)
    }
    
    private func formatDuration(_ duration: Int?) -> String? {
        guard let duration else { return nil }
        
        let totalMinutes = duration / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) ч \(minutes) мин"
        } else if hours > 0 {
            return "\(hours) ч"
        } else {
            return "\(minutes) мин"
        }
    }
}
