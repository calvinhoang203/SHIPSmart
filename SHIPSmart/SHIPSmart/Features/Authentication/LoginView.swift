import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showGoogleAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 50)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Logo
                        Image("Log In Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .padding(.top, 40)
                            .padding(.bottom, 20)
                        
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .foregroundColor(.black)
                                .font(.headline)
                            TextField("", text: $username)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal, 25)
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.black)
                                .font(.headline)
                            SecureField("", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal, 25)
                        
                        // Sign In Button
                        Button(action: {
                            // Handle email/password sign in here
                        }) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color(red: 247/255, green: 172/255, blue: 80/255))
                                .cornerRadius(27.5)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        
                        // Or continue with text
                        Text("or continue with")
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                        
                        // Social login buttons
                        HStack(spacing: 25) {
                            // Facebook button (disabled)
                            SocialLoginButton(image: "facebook-logo-2019", action: {})
                                .disabled(true)
                            
                            // Google button
                            SocialLoginButton(image: "google_logo") {
                                showGoogleAlert = true
                            }
                            
                            // Apple button (disabled)
                            SocialLoginButton(systemImage: "apple.logo", action: {})
                                .disabled(true)
                        }
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 25)
                        }
                        
                        // Sign up link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            NavigationLink("Sign up") {
                                Text("Sign Up View") // Placeholder for now
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemBackground))
            .alert("\"SHIPSmart\" Wants to Use \"google.com\" to Sign In", isPresented: $showGoogleAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue") {
                    viewModel.isAuthenticated = true
                }
            } message: {
                Text("This allows the app and website to share information about you.")
            }
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                HomeView()
            }
        }
    }
}

// Custom text field style to match the design
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// Social login button component
struct SocialLoginButton: View {
    let image: String?
    let systemImage: String?
    let action: () -> Void
    
    init(image: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) {
        self.image = image
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let imageName = image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                } else if let systemImageName = systemImage {
                    Image(systemName: systemImageName)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 25, height: 25)
            .padding()
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    LoginView()
} 
