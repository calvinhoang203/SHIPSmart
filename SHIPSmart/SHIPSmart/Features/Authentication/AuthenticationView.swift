import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Signing in...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if viewModel.isAuthenticated {
                // Show main app content
                Text("Signed in as \(viewModel.currentUser?.email ?? "Unknown")")
                Button("Sign Out") {
                    viewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
            } else {
                VStack(spacing: 20) {
                    Text("Welcome to SHIPSmart")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Please sign in to continue")
                        .foregroundColor(.secondary)
                    
                    Button {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .foregroundColor(.blue)
                            Text("Sign in with Google")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                    .buttonStyle(.plain)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding()
            }
        }
    }
} 