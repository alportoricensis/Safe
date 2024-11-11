import SwiftUI
import MapKit

struct RideStatusView: View {
    let rideId: Int
    @StateObject private var viewModel: RideStatusViewModel
    
    init(rideId: Int) {
        self.rideId = rideId
        self._viewModel = StateObject(wrappedValue: RideStatusViewModel(rideId: rideId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Location header
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.rideStatus?.pickup ?? "Loading...")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .foregroundColor(.white)
                
                Text(viewModel.rideStatus?.dropoffFormatted ?? "Loading...")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .foregroundColor(.white)
            }
            .padding(.vertical)
            
            // Map
            if let status = viewModel.rideStatus {
                Map(coordinateRegion: .constant(region(for: status)),
                    annotationItems: [status]) { status in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: status.driverLat,
                        longitude: status.driverLong
                    )) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                            )
                    }
                }
            } else {
                ProgressView()
            }
            
            // Bottom status bar
            VStack(alignment: .leading, spacing: 4) {
                Text("YOUR DRIVER IS ON THEIR WAY")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                if let status = viewModel.rideStatus {
                    Text("ETA: \(status.ETA, formatter: DateFormatter.timeOnly)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("\(viewModel.rideStatus?.driver ?? "")'s")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .font(.subheadline)
                
                    .font(.caption)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
            }
            .padding()
            .background(Color(hex: "00274C"))
            .shadow(radius: 2)
        }
        .background(Color(hex: "00274C"))
    }
    
    private func region(for status: RideStatus) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: status.driverLat,
                longitude: status.driverLong
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// Add this extension to DateFormatter
extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

// Add this extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    RideStatusView(rideId: 1234)
}
