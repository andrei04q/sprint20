import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct CarrierInfoView: View {
    let carrierCode: Int

    @Environment(\.dismiss) private var dismiss
    @State private var carrier: Components.Schemas.CarrierInfo?
    @State private var isLoading = true
    @State private var hasError = false

    private var client: Client? {
        try? Client(
            serverURL: Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }

    var body: some View {
        ZStack {
            Color("YPWhite")
                .ignoresSafeArea()

            Group {
                if isLoading {
                    ProgressView()
                } else if hasError {
                    LoadErrorView(error: .server)
                } else if let carrier {
                    content(for: carrier)
                } else {
                    LoadErrorView(error: .server)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("YPBlack"))
                }
            }
        }
        .task {
            await loadCarrier()
        }
    }

    private func content(for carrier: Components.Schemas.CarrierInfo) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                carrierLogoView(logoPath: carrier.logo)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                Text(displayTitle(for: carrier.title))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("YPBlack"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)

                if let email = normalizedText(carrier.email) {
                    infoBlock(title: "E-mail", value: email)
                }

                if let phone = normalizedText(carrier.phone) {
                    infoBlock(title: "Телефон", value: phone)
                }

                if let address = normalizedText(carrier.address) {
                    infoBlock(title: "Адрес", value: address)
                }

                if let contacts = normalizedText(carrier.contacts) {
                    infoBlock(title: "Контакты", value: contacts)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func infoBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(Color("YPBlack"))

            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color("YPBlueUniversal"))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private func carrierLogoView(logoPath: String?) -> some View {
        if let logoURL = normalizedURL(from: logoPath) {
            AsyncImage(url: logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 104)
            } placeholder: {
                ProgressView()
                    .frame(width: 240, height: 104)
            }
        } else {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color("YPLightGray"))
                .frame(width: 240, height: 104)
                .overlay {
                    Text("Логотип")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color("YPBlack"))
                }
        }
    }

    private func loadCarrier() async {
        guard let client else {
            isLoading = false
            hasError = true
            return
        }

        do {
            let service = CarrierInfoService(client: client, apikey: APIKey.yandexRasp)
            let response = try await service.getCarrier(code: carrierCode)
            carrier = response.carrier
            hasError = carrier == nil
        } catch {
            hasError = true
        }

        isLoading = false
    }

    private func normalizedURL(from rawLogo: String?) -> URL? {
        guard let rawLogo = normalizedText(rawLogo) else { return nil }
        if rawLogo.hasPrefix("//") {
            return URL(string: "https:" + rawLogo)
        }
        return URL(string: rawLogo)
    }

    private func normalizedText(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func displayTitle(for value: String?) -> String {
        normalizedText(value) ?? "—"
    }
}

#Preview {
    NavigationStack {
        CarrierInfoView(carrierCode: 680)
    }
}
