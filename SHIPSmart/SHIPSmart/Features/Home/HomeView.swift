import SwiftUI

struct AppointmentCard: View {
    let date: Date
    let doctorName: String
    let specialty: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appointment Date")
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text(date.formatted(date: .complete, time: .shortened))
            }
            
            Text(doctorName)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(specialty)
                .italic()
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var showChatbot = false
    
    // Sample appointments - replace with real data
    let appointments = [
        (date: Date(timeIntervalSince1970: 1713570300), // Apr 18 5:45 PM
         doctor: "Dr. Jane Doe",
         specialty: "Optometrist"),
        (date: Date(timeIntervalSince1970: 1714503600), // Apr 30 3:20 PM
         doctor: "Dr. John Smith",
         specialty: "Wisdom teeth removal"),
        (date: Date(timeIntervalSince1970: 1719414600), // June 23 8:30 AM
         doctor: "Dr. Isaiah Kim",
         specialty: "Medical Counseling"),
        (date: Date(timeIntervalSince1970: 1724342400), // Aug 18 9:00 AM
         doctor: "Dr. Jane Doe",
         specialty: "Optometrist")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { /* Menu action */ }) {
                            Image("Menu Icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                        Button(action: { /* Options action */ }) {
                            Image("Option Icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                    
                    // Welcome Text
                    Text("Welcome, LINH!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.86))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search conversation...", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Appointment History Section
                    Text("APPOINTMENT HISTORY")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(appointments, id: \.date) { appointment in
                                AppointmentCard(
                                    date: appointment.date,
                                    doctorName: appointment.doctor,
                                    specialty: appointment.specialty
                                )
                            }
                        }
                        .padding(.bottom, 80) // Add padding for the bottom bar
                    }
                    
                    Spacer()
                }
                
                // Bottom Navigation Bar
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {}) {
                            VStack {
                                Image("Home Icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showChatbot = true }) {
                            Image("Chatbot Icon")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image("Profile Icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .shadow(radius: 5)
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showChatbot) {
            ChatbotView()
        }
    }
}

#Preview {
    HomeView()
} 