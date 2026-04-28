import SwiftUI

struct StationSearchView: View {
    
    let city: StationChoice
    let onSelect: (StationChoice) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var viewState: StationSearchViewState = .loading
    
    private var filteredStations: [StationChoice] {
        guard case let .success(stations) = viewState else { return [] }
        guard !searchText.isEmpty else { return stations }
        
        return stations.filter { station in
            station.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            switch viewState {
            case .loading:
                loadingView
                
            case .error(let error):
                errorView(error)
                
            case .success:
                stationsListView
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadStations()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
            Text("Загружаем станции…")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private func errorView(_ error: LoadError) -> some View {
        LoadErrorView(error: error)
    }
    
    private var stationsListView: some View {
        List(filteredStations) { station in
            stationRow(station)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("YPWhite"))
        .searchable(text: $searchText, prompt: "Поиск станции")
        .overlay {
            if filteredStations.isEmpty {
                emptyResultView
            }
        }
    }
    
    private func stationRow(_ station: StationChoice) -> some View {
        Button {
            onSelect(station)
            dismiss()
        } label: {
            HStack {
                Text(station.title)
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
    
    private var emptyResultView: some View {
        VStack {
            Spacer()
            
            Text("Станция не найдена")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("YPBlack"))
            
            Spacer()
        }
    }
    
    private func loadStations() async {
        viewState = .loading
        
        do {
            let allStations = try await StationsRepository.shared.loadStations()
            
            let cityStations = allStations.filter { station in
                station.settlementTitle == city.title
            }
            
            let sortedStations = cityStations.sorted { lhs, rhs in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            
            viewState = .success(sortedStations)
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
}
