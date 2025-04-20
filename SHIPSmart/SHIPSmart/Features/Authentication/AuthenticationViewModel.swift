import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published private(set) var isNetworkAvailable = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var networkObserver: NSObjectProtocol?
    private let maxRetries = 3
    
    init() {
        setupNetworkObserver()
        setupAuthStateListener()
        checkCurrentUser()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        if let observer = networkObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupNetworkObserver() {
        networkObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NetworkStatusChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let isAvailable = notification.userInfo?["isAvailable"] as? Bool {
                self?.isNetworkAvailable = isAvailable
                if isAvailable && self?.errorMessage?.contains("network") == true {
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            self.currentUser = user
            self.isAuthenticated = user != nil
            if user != nil {
                self.errorMessage = nil
            }
        }
    }
    
    private func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    func signInWithGoogle() async {
        do {
            isLoading = true
            errorMessage = nil
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthError.missingClientID
            }
            
            // Create Google Sign In configuration object
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                throw AuthError.noRootViewController
            }
            
            // Start the sign in flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingToken
            }
            
            // Create a Firebase credential with the Google ID token
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // Sign in to Firebase with the credential
            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            isAuthenticated = true
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            try GIDSignIn.sharedInstance.signOut()
            isAuthenticated = false
            currentUser = nil
            errorMessage = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            errorMessage = signOutError.localizedDescription
        }
    }
    
    private func handleError(_ error: Error) {
        print("Authentication error: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
    }
}

// MARK: - Error Handling
enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case missingToken
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Firebase configuration error: Client ID is missing"
        case .noRootViewController:
            return "Unable to present sign-in screen"
        case .missingToken:
            return "Failed to get authentication token"
        }
    }
} 