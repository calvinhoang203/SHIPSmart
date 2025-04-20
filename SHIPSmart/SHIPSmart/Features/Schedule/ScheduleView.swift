//  ScheduleView.swift
//  SHIPSmart_Demo(2)
//
//  Created by Van Linh Huynh Nguyen on 4/20/25.
//

import SwiftUI

// Models
struct Doctor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let specialty: String
    let imageSystemName: String
}

struct Appointment: Identifiable {
    let id = UUID()
    let doctor: Doctor
    let date: Date
    let status: AppointmentStatus
    
    enum AppointmentStatus: String {
        case upcoming = "Upcoming"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
}

// Views
struct ScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedDoctor: Doctor?
    @State private var selectedDate = Date()
    @State private var selectedTime: Date?
    @State private var showingNewAppointment = false
    @State private var showConfirmation = false
    
    private let doctors = [
        Doctor(name: "Dr. Sarah Johnson", specialty: "Primary Care", imageSystemName: "person.circle.fill"),
        Doctor(name: "Dr. Michael Chen", specialty: "Internal Medicine", imageSystemName: "person.circle.fill"),
        Doctor(name: "Dr. Emily Williams", specialty: "Family Medicine", imageSystemName: "person.circle.fill"),
        Doctor(name: "Dr. David Kim", specialty: "General Practice", imageSystemName: "person.circle.fill")
    ]
    
    @State private var appointments: [Appointment] = [
        Appointment(
            doctor: Doctor(name: "Dr. Sarah Johnson", specialty: "Primary Care", imageSystemName: "person.circle.fill"),
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            status: .upcoming
        ),
        Appointment(
            doctor: Doctor(name: "Dr. Michael Chen", specialty: "Internal Medicine", imageSystemName: "person.circle.fill"),
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            status: .completed
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top bar with navigation
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                    Spacer()
                    Text("Schedule Appointment")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingNewAppointment = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Welcome + Search
                        Text("Welcome!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search doctors...", text: $searchText)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Appointment History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APPOINTMENT HISTORY")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                            
                            ForEach(appointments) { appointment in
                                AppointmentCardView(appointment: appointment)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Bottom navigation
                BottomNavBar()
            }
        }
        .sheet(isPresented: $showingNewAppointment) {
            NewAppointmentView(
                doctors: doctors,
                onAppointmentCreated: { doctor, date in
                    let newAppointment = Appointment(
                        doctor: doctor,
                        date: date,
                        status: .upcoming
                    )
                    appointments.append(newAppointment)
                    showingNewAppointment = false
                }
            )
        }
    }
}

struct AppointmentCardView: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: appointment.doctor.imageSystemName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(appointment.doctor.name)
                        .font(.headline)
                    Text(appointment.doctor.specialty)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(status: appointment.status)
            }
            
            Divider()
            
            HStack {
                Image(systemName: "calendar")
                Text(appointment.date.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: Appointment.AppointmentStatus
    
    var backgroundColor: Color {
        switch status {
        case .upcoming: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

struct BottomNavBar: View {
    var body: some View {
        HStack {
            Spacer()
            NavBarButton(imageName: "house.fill", text: "Home")
            Spacer()
            NavBarButton(imageName: "calendar", text: "Schedule")
            Spacer()
            NavBarButton(imageName: "person.fill", text: "Profile")
            Spacer()
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(radius: 2)
    }
}

struct NavBarButton: View {
    let imageName: String
    let text: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 20))
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.gray)
    }
}

struct NewAppointmentView: View {
    let doctors: [Doctor]
    let onAppointmentCreated: (Doctor, Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDoctor: Doctor?
    @State private var selectedDate = Date()
    @State private var selectedTime: Date?
    
    private let calendar = Calendar.current
    private let timeSlots: [Date] = {
        var slots: [Date] = []
        let calendar = Calendar.current
        let now = Date()
        
        for hour in 9...16 {
            if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) {
                slots.append(date)
            }
        }
        return slots
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Doctor Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select a Doctor")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(doctors) { doctor in
                                    DoctorCard(doctor: doctor, isSelected: selectedDoctor == doctor)
                                        .onTapGesture {
                                            selectedDoctor = doctor
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Date")
                            .font(.headline)
                        
                        DatePicker(
                            "Appointment Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    // Time Selection
                    if selectedDoctor != nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Time")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(timeSlots, id: \.self) { time in
                                        TimeSlotButton(
                                            time: time,
                                            isSelected: selectedTime == time
                                        ) {
                                            selectedTime = time
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Book Button
                    if let doctor = selectedDoctor, selectedTime != nil {
                        Button(action: {
                            let finalDate = calendar.date(bySettingHour: calendar.component(.hour, from: selectedTime!),
                                                        minute: 0,
                                                        second: 0,
                                                        of: selectedDate) ?? selectedDate
                            onAppointmentCreated(doctor, finalDate)
                        }) {
                            Text("Book Appointment")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct DoctorCard: View {
    let doctor: Doctor
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: doctor.imageSystemName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(doctor.name)
                .font(.headline)
            Text(doctor.specialty)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 200)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(time.formatted(date: .omitted, time: .shortened))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ScheduleView()
}
