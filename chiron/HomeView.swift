import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ProfileView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
            SettingsView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}