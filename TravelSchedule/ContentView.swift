import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {

            NavigationStack {
                StartView()
            }
            .tabItem {
                Image(systemName: "arrow.up.message.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
            }

        }
        .background(Color("YPWhite"))
        .tint(Color("YPBlack"))
    }
}

#Preview {
    ContentView()
}
