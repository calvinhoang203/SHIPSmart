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

@main
struct SHIPSmartApp: App {
    // Register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
            .onOpenURL { (url: URL) in
                print("Received URL: \(url)")
                if GIDSignIn.sharedInstance.handle(url) {
                    print("URL handled by Google Sign In")
                } else {
                    print("URL not handled by Google Sign In: \(url)")
                }
            }
        }
        .onChange(of: scenePhase) { (oldPhase: ScenePhase, newPhase: ScenePhase) in
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
