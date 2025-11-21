import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 10) {
                        Text("Welcome back, \(user.name)!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Dashboard")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Analytics")
                                    .font(.headline)
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Quick Actions")
                                    .font(.headline)
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Recent Activity")
                                    .font(.headline)
                            )
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthManager())
}
