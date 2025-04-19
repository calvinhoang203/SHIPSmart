import SwiftUI

struct MainView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to SHIPSmart!")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    MainView()
} 