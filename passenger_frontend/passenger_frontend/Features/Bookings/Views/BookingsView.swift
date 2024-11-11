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
    @State private var pickupAddress: String = "Loading..."
    @State private var dropoffAddress: String = "Loading..."
    
    var body: some View {
        Group {
            if booking.status.lowercased() == "requested" {
                NavigationLink(destination: RideStatusView(rideId: booking.id)) {
                    bookingContent
                }
            } else {
                bookingContent
            }
        }
    }
    
    private var bookingContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booking.serviceName)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text(booking.status.capitalized)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pickup Location:")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(pickupAddress)
                    .font(.body)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Dropoff Location:")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(dropoffAddress)
                    .font(.body)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Requested:")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(formatDateTime(booking.requestTime))
                    .font(.body)
                    .foregroundColor(.black)
            }
            
            if let pickupTime = booking.pickupTime {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pickup Time:")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text(formatDateTime(pickupTime))
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            
            if let dropoffTime = booking.dropoffTime {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dropoff Time:")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text(formatDateTime(dropoffTime))
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            
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
        .background(Color.yellow)
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            // Convert coordinates to addresses
            let viewModel = BookingsViewModel()
            viewModel.getAddressFromCoordinates(
                latitude: booking.pickupLat,
                longitude: booking.pickupLong
            ) { address in
                pickupAddress = address
            }
            
            viewModel.getAddressFromCoordinates(
                latitude: booking.dropoffLat,
                longitude: booking.dropoffLong
            ) { address in
                dropoffAddress = address
            }
        }
    }
    
    private var statusColor: Color {
        switch booking.status.lowercased() {
        case "requested": return .blue
        case "accepted": return .green
        case "completed": return .gray
        default: return .orange
        }
    }
    
    private func formatDateTime(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
