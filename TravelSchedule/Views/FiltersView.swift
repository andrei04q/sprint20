import SwiftUI

struct FiltersView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var morning = false
    @State private var day = false
    @State private var evening = false
    @State private var night = false
    @State private var allowTransfers = true

    let onApply: (DepartureFilter) -> Void

    private var hasSelection: Bool {
        morning || day || evening || night || !allowTransfers
    }

    var body: some View {
        ZStack {
            Color("YPWhite")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Время отправления")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("YPBlack"))
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                checkboxRow("Утро 06:00 - 12:00", isOn: $morning)
                checkboxRow("День 12:00 - 18:00", isOn: $day)
                checkboxRow("Вечер 18:00 - 00:00", isOn: $evening)
                checkboxRow("Ночь 00:00 - 06:00", isOn: $night)

                Text("Показывать варианты с\nпересадками")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("YPBlack"))
                    .padding(.top, 24)
                    .padding(.bottom, 24)

                radioRow("Да", selected: allowTransfers) {
                    allowTransfers = true
                }

                radioRow("Нет", selected: !allowTransfers) {
                    allowTransfers = false
                }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
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
        .safeAreaInset(edge: .bottom) {
            if hasSelection {
                applyButton
            }
        }
    }

    private func checkboxRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(Color("YPBlack"))

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color("YPBlack"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isOn.wrappedValue {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("YPBlack"))
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("YPWhite"))
                    }
                }
            }
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }

    private func radioRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(Color("YPBlack"))

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color("YPBlack"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if selected {
                        Circle()
                            .fill(Color("YPBlack"))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }

    private var applyButton: some View {
        Button {
            let filter = DepartureFilter(
                morning: morning,
                day: day,
                evening: evening,
                night: night,
                allowTransfers: allowTransfers
            )

            onApply(filter)
            dismiss()
        } label: {
            Text("Применить")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("YPWhite"))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color("YPBlueUniversal"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .background(Color("YPWhite"))
    }
}

#Preview {
    NavigationStack {
        FiltersView { _ in }
    }
}
