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


#Preview {
    LoginView()
}