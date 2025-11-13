import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 8) {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(user.email)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text("User ID: \(user.id)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Email")
                                Spacer()
                                Text(user.email)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "person")
                                Text("Name")
                                Spacer()
                                Text(user.name)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}