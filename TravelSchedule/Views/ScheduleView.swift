import SwiftUI

struct ScheduleView: View {
    let from: StationChoice
    let to: StationChoice
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var showFilters = false
    
    private var isFailedState: Bool {
        if case .failed = viewModel.state {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack {
            Color("YPWhite")
                .ignoresSafeArea()
            
            if isFailedState {
                content
            } else {
                VStack(spacing: 0) {
                    header
                    content
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isFailedState ? .visible : .hidden, for: .tabBar)
        .toolbar {
            if !isFailedState {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("YPBlack"))
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showFilters) {
            FiltersView { filter in
                viewModel.applyFilter(filter)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if case .loaded = viewModel.state {
                filterButton
            }
        }
        .task {
            await viewModel.load(from: from, to: to)
        }
    }
    
    private var header: some View {
        Text("\(from.title) → \(to.title)")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Color("YPBlack"))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 12) {
                Spacer()
                ProgressView()
                Text("Ищем рейсы…")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("YPBlack"))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case let .failed(error):
            LoadErrorView(error: error)
            
        case .loaded:
            if viewModel.rides.isEmpty {
                VStack {
                    Spacer()
                    Text("Вариантов нет")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color("YPBlack"))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.rides) { ride in
                            if let carrierCode = ride.carrierCode {
                                NavigationLink {
                                    CarrierInfoView(carrierCode: carrierCode)
                                } label: {
                                    RideCardView(ride: ride)
                                        .frame(height: 104)
                                }
                                .buttonStyle(.plain)
                            } else {
                                RideCardView(ride: ride)
                                    .frame(height: 104)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
    private var filterButton: some View {
        Button {
            showFilters = true
        } label: {
            Text("Уточнить время")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color("YPWhiteUniversal"))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color("YPBlueUniversal"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

private struct RideCardView: View {
    let ride: ScheduleViewModel.Ride
    
    @State private var logoURL: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                carrierLogo
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ride.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color("YPBlackUniversal"))
                        .lineLimit(1)
                    
                    if let transferText = ride.transferText {
                        Text(transferText)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color("YPBlackUniversal"))
                            .lineLimit(1)
                    }
                }
                .padding(.top, ride.transferText == nil ? 9 : 0)
                
                Spacer()
                
                if let dateText = ride.dateText {
                    Text(dateText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color("YPBlackUniversal"))
                        .lineLimit(1)
                        .padding(.top, ride.transferText == nil ? 9 : 0)
                        .padding(.trailing, ride.transferText == nil ? 0 : 0)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            
            Spacer(minLength: 10)
            
            HStack(alignment: .center, spacing: 8) {
                Text(ride.departureTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color("YPBlackUniversal"))
                
                line
                
                if let durationText = ride.durationText {
                    Text(durationText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color("YPBlackUniversal"))
                        .fixedSize()
                }
                
                line
                
                Text(ride.arrivalTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color("YPBlackUniversal"))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .background(Color("YPLightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .task {
            logoURL = await CarrierLogoService.shared.logoURL(for: ride.carrierCode)
        }
    }
    
    private var carrierLogo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("YPWhiteUniversal"))
                .frame(width: 38, height: 38)
            
            if let logoURL {
                AsyncImage(url: logoURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                } placeholder: {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            } else {
                Text("—")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color("YPBlack"))
            }
        }
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color("YPBlackUniversal").opacity(0.3))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ScheduleView(
            from: StationChoice(
                title: "Москва (Ярославский вокзал)",
                yandexCode: "s2000002"
            ),
            to: StationChoice(
                title: "Санкт-Петербург (Балтийский вокзал)",
                yandexCode: "s9602496"
            )
        )
    }
}
