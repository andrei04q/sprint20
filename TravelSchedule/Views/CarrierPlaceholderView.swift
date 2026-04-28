import SwiftUI

struct CarrierPlaceholderView: View {

    let title: String

    var body: some View {
        VStack(spacing: 16) {

            Text("Карточка перевозчика")
                .font(.title.bold())

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Перевозчик")
        .navigationBarTitleDisplayMode(.inline)
    }
}
