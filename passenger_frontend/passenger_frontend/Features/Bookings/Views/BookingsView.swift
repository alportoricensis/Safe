import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel = BookingsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.bookings.isEmpty {
                    Text("No bookings found")
                        .foregroundColor(.white)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.bookings) { booking in
                                BookingCard(booking: booking) {
                                    viewModel.deleteBooking(booking)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .withSafeTopBar()
        }
        .onAppear {
            viewModel.fetchBookings()
        }
    }
}

struct BookingCard: View {
    let booking: Booking
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ride #\(booking.id)")
                    .font(.headline)
                Spacer()
                Text(booking.status.capitalized)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text("Service: \(booking.serviceName)")
                .font(.subheadline)
            
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var statusColor: Color {
        switch booking.status.lowercased() {
        case "requested": return .blue
        case "accepted": return .green
        case "completed": return .gray
        default: return .orange
        }
    }
}
