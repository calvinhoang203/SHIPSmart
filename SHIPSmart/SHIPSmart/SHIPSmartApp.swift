//
//  SHIPSmartApp.swift
//  SHIPSmart
//
//  Created by Hieu Hoang on 4/19/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAnalytics
import Network

class AppDelegate: NSObject, UIApplicationDelegate {
    private var networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        if let options = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!) {
            FirebaseApp.configure(options: options)
        }
        
        // Configure Analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        
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
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network connection established")
            } else {
                print("No network connection")
            }
        }
        networkMonitor.start(queue: queue)
    }
}

@main
struct SHIPSmartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            // Temporarily bypassing authentication
            // if authViewModel.isAuthenticated {
            //     HomeView()
            //         .environmentObject(authViewModel)
            // } else {
            //     LoginView()
            //         .environmentObject(authViewModel)
            // }
            
            // Direct to ChatbotView for testing
            ChatbotView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                print("App became active")
            case .inactive:
                print("App became inactive")
            case .background:
                print("App went to background")
            @unknown default:
                break
            }
        }
    }
}
