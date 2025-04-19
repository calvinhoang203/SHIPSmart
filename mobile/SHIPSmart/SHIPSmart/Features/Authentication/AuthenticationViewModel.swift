import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var currentUser: FirebaseAuth.User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.currentUser = user
            self.isAuthenticated = user != nil
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthenticationError.firebaseConfiguration
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                throw AuthenticationError.noRootViewController
            }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthenticationError.noIDToken
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            _ = try await Auth.auth().signIn(with: credential)
            // Note: The auth state listener will automatically update isAuthenticated
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func signOut() {
        isLoading = true
        errorMessage = nil
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            // Note: The auth state listener will automatically update isAuthenticated
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Error Handling
extension AuthenticationViewModel {
    enum AuthenticationError: LocalizedError {
        case firebaseConfiguration
        case noRootViewController
        case noIDToken
        
        var errorDescription: String? {
            switch self {
            case .firebaseConfiguration:
                return "Firebase configuration error. Please check your GoogleService-Info.plist file."
            case .noRootViewController:
                return "Unable to find root view controller for Google Sign-In."
            case .noIDToken:
                return "Failed to get ID token from Google Sign-In."
            }
        }
    }
} 