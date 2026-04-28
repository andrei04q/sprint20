import SwiftUI

struct CitySearchView: View {
    
    let title: String
    let onSelect: (StationChoice) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var viewState: CitySearchViewState = .loading
    @State private var selectedCity: StationChoice?
    
    private let popularCitiesOrder: [String] = [
        "Москва",
        "Санкт-Петербург",
        "Казань",
        "Нижний Новгород",
        "Сочи",
        "Екатеринбург",
        "Краснодар",
        "Ростов-на-Дону",
        "Новосибирск",
        "Самара"
    ]
    
    private var filteredCities: [StationChoice] {
        guard case let .success(cities) = viewState else { return [] }
        guard !searchText.isEmpty else { return cities }
        
        return cities.filter { city in
            city.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            switch viewState {
            case .loading:
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("Загружаем города…")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
            case .error(let loadError):
                LoadErrorView(error: loadError)
                
            case .success:
                List(filteredCities) { city in
                    Button {
                        selectedCity = city
                    } label: {
                        HStack {
                            Text(city.title)
                                .font(.system(size: 17))
                                .foregroundStyle(Color("YPBlack"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color("YPBlack"))
                                .padding(.trailing, 16)
                        }
                        .frame(height: 60)
                        .padding(.leading, 16)
                        .background(Color("YPWhite"))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color("YPWhite"))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color("YPWhite"))
                .searchable(text: $searchText, prompt: "Поиск города")
                .overlay {
                    if filteredCities.isEmpty {
                        VStack {
                            Spacer()
                            Text("Город не найден")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedCity) { city in
            StationSearchView(city: city) { station in
                onSelect(station)
            }
        }
        .task {
            await loadCities()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    private func loadCities() async {
        viewState = .loading
        
        do {
            let allStations = try await StationsRepository.shared.loadStations()
            let preparedCities = prepareCities(from: allStations)
            viewState = .success(sortCitiesByPriority(preparedCities))
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                viewState = .error(.noInternet)
            } else {
                viewState = .error(.server)
            }
        } catch {
            viewState = .error(.server)
        }
    }
    
    private func prepareCities(from stations: [StationChoice]) -> [StationChoice] {
        let stationsWithSettlement = stations.filter { station in
            guard let settlementTitle = station.settlementTitle else {
                return false
            }
            return !settlementTitle.isEmpty
        }
        
        let groupedByCity = Dictionary(
            grouping: stationsWithSettlement,
            by: { station in
                station.settlementTitle ?? ""
            }
        )
        
        var resultCities: [StationChoice] = []
        
        for (cityTitle, stations) in groupedByCity {
            guard let firstStation = stations.first else { continue }
            
            let city = StationChoice(
                title: cityTitle,
                yandexCode: firstStation.yandexCode,
                settlementTitle: cityTitle
            )
            
            resultCities.append(city)
        }
        
        return resultCities
    }
    
    private func sortCitiesByPriority(_ cities: [StationChoice]) -> [StationChoice] {
        let priorities = Dictionary(
            uniqueKeysWithValues: popularCitiesOrder.enumerated().map { ($1, $0) }
        )
        
        return cities.sorted { lhs, rhs in
            let leftPriority = priorities[lhs.title]
            let rightPriority = priorities[rhs.title]
            
            switch (leftPriority, rightPriority) {
            case let (left?, right?):
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
        }
    }
}
