import UIKit
import Firebase
import GoogleSignIn
import Network

class AppDelegate: NSObject, UIApplicationDelegate {
    private var networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isNetworkAvailable = false
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase only if not already configured
        if FirebaseApp.app() == nil {
            guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: filePath) else {
                fatalError("Couldn't find or load GoogleService-Info.plist file")
            }
            
            // Configure Firebase with the loaded options
            FirebaseApp.configure(options: options)
            
            // Configure Google Sign In
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: options.clientID ?? "")
            
            print("Firebase configured successfully with options from: \(filePath)")
        }
        
        // Start monitoring network
        startNetworkMonitoring()
        
        return true
    }
    
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                if path.status == .satisfied {
                    print("Network connection established")
                } else {
                    print("No network connection")
                }
                
                let isWiFi = path.usesInterfaceType(.wifi)
                print("Is on WiFi: \(isWiFi)")
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    deinit {
        networkMonitor.cancel()
    }
} 