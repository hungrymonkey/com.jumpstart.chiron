import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var name = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSignUpMode = false
    @State private var existingUsers: [(id: Int, email: String, name: String)] = []
    @State private var selectedUserEmail = ""
    
    var body: some View {
        if authManager.isAuthenticated {
            HomeView()
                .environmentObject(authManager)
        } else {
        VStack(spacing: 20) {
            Text("Chiron")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            VStack(spacing: 16) {
                if isSignUpMode {
                    TextField("Email", text: $email)
                        .autocorrectionDisabled()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    // Sign in mode with dropdown
                    if !existingUsers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select User:")
                                .font(.headline)
                            
                            Picker("Select User", selection: $selectedUserEmail) {
                                Text("Choose a user").tag("")
                                ForEach(existingUsers, id: \.id) { user in
                                    Text("\(user.name) (\(user.email))").tag(user.email)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    } else {
                        Text("No existing users. Please sign up first.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: handleAuth) {
                Text(isSignUpMode ? "Sign Up" : "Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(isSignUpMode ? (email.isEmpty || name.isEmpty) : selectedUserEmail.isEmpty)
            
            Button(action: { isSignUpMode.toggle() }) {
                Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            
            // Debug button to clear all users
            Button(action: clearAllUsers) {
                Text("Clear All Users (Debug)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .onAppear {
            loadExistingUsers()
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        }
    }
    
    private func handleAuth() {
        if isSignUpMode {
            guard !email.isEmpty else {
                showAlert(message: "Please enter an email")
                return
            }
            
            guard !name.isEmpty else {
                showAlert(message: "Please enter a name")
                return
            }
            
            if authManager.userExists(email: email) {
                showAlert(message: "User already exists. Please sign in instead.")
            } else {
                if authManager.signUp(email: email, name: name) {
                    loadExistingUsers() // Refresh user list
                } else {
                    showAlert(message: "Failed to create account")
                }
            }
        } else {
            guard !selectedUserEmail.isEmpty else {
                showAlert(message: "Please select a user")
                return
            }
            
            if authManager.signIn(email: selectedUserEmail) {
                // Success handled by @Published property
            } else {
                showAlert(message: "Failed to sign in")
            }
        }
    }
    
    private func loadExistingUsers() {
        existingUsers = SQLiteManager.shared.getAllUsers()
        print("Loaded \(existingUsers.count) users: \(existingUsers)")
    }
    
    private func clearAllUsers() {
        if SQLiteManager.shared.clearAllUsers() {
            loadExistingUsers()
            showAlert(message: "All users cleared")
        } else {
            showAlert(message: "Failed to clear users")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

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
                    
                    // Add your main app content here
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Feature 1")
                                    .font(.headline)
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Feature 2")
                                    .font(.headline)
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                            .frame(height: 100)
                            .overlay(
                                Text("Feature 3")
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
    LoginView()
}