import SwiftUI

struct Appointment: Identifiable {
    let id = UUID()
    let date: Date
    let doctorName: String
    let specialty: String
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var appointments: [Appointment] = [
        Appointment(date: Date().addingTimeInterval(86400), doctorName: "Dr. Jane Doe", specialty: "Optometrist"),
        Appointment(date: Date().addingTimeInterval(86400 * 11), doctorName: "Dr. John Smith", specialty: "Wisdom teeth removal"),
        Appointment(date: Date().addingTimeInterval(86400 * 65), doctorName: "Dr. Isaiah Kim", specialty: "Medical Counseling")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image("Menu Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                    Image("Option Icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal)
                
                // Welcome Text
                Text("Welcome back, LINH!")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(red: 0.129, green: 0.588, blue: 0.952))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Search Bar
                TextField("Search conversation...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Appointment History
                VStack(alignment: .leading, spacing: 16) {
                    Text("APPOINTMENT HISTORY")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.129, green: 0.588, blue: 0.952))
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(appointments) { appointment in
                                AppointmentCard(appointment: appointment)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Navigation Bar
                HStack(spacing: 0) {
                    NavigationLink(destination: HomeView()) {
                        VStack {
                            Image("Home Icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    NavigationLink(destination: ChatbotView()) {
                        VStack {
                            Image("Mic Icon")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    NavigationLink(destination: Text("Profile View")) {
                        VStack {
                            Image("Profile Icon")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.white)
                .shadow(radius: 2)
            }
            .navigationBarHidden(true)
        }
    }
}

struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Appointment Date")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text(appointment.date, style: .date)
                Text(appointment.date, style: .time)
            }
            .font(.subheadline)
            
            Text(appointment.doctorName)
                .font(.headline)
            
            Text(appointment.specialty)
                .font(.subheadline)
                .italic()
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4)
    }
}

#Preview {
    HomeView()
} 