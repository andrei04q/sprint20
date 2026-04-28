import SwiftUI

struct SettingsView: View {
    @AppStorage("is_dark_theme") private var isDarkTheme = false
    @State private var showUserAgreement = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                settingsRow(height: 60) {
                    Text("Темная тема")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color("YPBlack"))

                    Spacer()

                    Toggle("", isOn: $isDarkTheme)
                        .labelsHidden()
                        .fixedSize()
                        .tint(Color("YPBlueUniversal"))
                }

                Button {
                    showUserAgreement = true
                } label: {
                    settingsRow(height: 60) {
                        Text("Пользовательское соглашение")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color("YPBlack"))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("YPBlack"))
                    }
                }
                .buttonStyle(.plain)
            }
            .background(Color("YPWhite"))
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                Text("Приложение использует API «Яндекс.Расписания»")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("YPBlack"))

                Text("Версия 1.0 (beta)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("YPBlack"))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color("YPWhite").ignoresSafeArea())
        .fullScreenCover(isPresented: $showUserAgreement) {
            UserAgreementView()
        }
    }

    private func settingsRow<Content: View>(height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .frame(height: height)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SettingsView()
}
