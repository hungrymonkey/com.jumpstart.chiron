import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Edit Profile")
                    }
                    
                    HStack {
                        Image(systemName: "lock")
                        Text("Privacy")
                    }
                }
                
                Section("App") {
                    HStack {
                        Image(systemName: "bell")
                        Text("Notifications")
                    }
                    
                    HStack {
                        Image(systemName: "paintbrush")
                        Text("Appearance")
                    }
                }
                
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Sign Out")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}