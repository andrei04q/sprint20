import SwiftUI

@main
struct TravelScheduleApp: App {
    @AppStorage("is_dark_theme") private var isDarkTheme = false

    init() {
        configureTabBar()
        configureNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkTheme ? .dark : .light)
        }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "YPWhite")
        appearance.shadowColor = UIColor(named: "DropShadow")

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "YPWhite")
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "YPBlack") ?? .black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
