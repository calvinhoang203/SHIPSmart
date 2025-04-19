//
//  SHIPSmartApp.swift
//  SHIPSmart
//
//  Created by Hieu Hoang on 4/19/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct SHIPSmartApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
