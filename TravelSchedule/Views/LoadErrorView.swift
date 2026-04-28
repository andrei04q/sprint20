import SwiftUI

struct LoadErrorView: View {

    let error: LoadError

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("YPBlack"))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("YPWhite"))
    }

    private var imageName: String {
        switch error {
        case .noInternet:
            return "NoInternet"
        case .server:
            return "ServerError"
        }
    }

    private var title: String {
        switch error {
        case .noInternet:
            return "Нет интернета"
        case .server:
            return "Ошибка сервера"
        }
    }
}

#Preview {
    LoadErrorView(error: .noInternet)
}
