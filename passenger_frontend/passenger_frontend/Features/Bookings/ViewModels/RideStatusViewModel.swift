import Foundation
import Combine
import CoreLocation

class RideStatusViewModel: ObservableObject {
    @Published var rideStatus: RideStatus?
    @Published var error: Error?
    
    private var timer: Timer?
    private let rideId: Int
    
    private let geocoder = CLGeocoder()
    
    init(rideId: Int) {
        self.rideId = rideId
        startPolling()
    }
    
    deinit {
        stopPolling()
    }
    
    private func startPolling() {
        // Initial fetch
        fetchRideStatus()
        
        // Set up timer for polling every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchRideStatus()
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchRideStatus() {
        guard let url = URL(string: "http://35.2.2.224:5000/api/v1/rides/passengers/\(rideId)/") else {
            print("⚠️ Invalid URL constructed for rideId: \(rideId)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            print("🔄 Fetching ride status for ride #\(self?.rideId ?? 0)")
            
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from API")
                    return
                }
                
                print("📦 Received data: \(String(data: data, encoding: .utf8) ?? "Unable to stringify data")")
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                    var response = try decoder.decode([String: RideStatus].self, from: data)
                    print("🎯 Decoded response: \(response)")
                    
                    if var status = response[String(self?.rideId ?? 0)] {
                        print("📍 Starting reverse geocoding for coordinates: \(status.dropoff)")
                        self?.reverseGeocode(coordinates: status.dropoff) { address in
                            print("📍 Received address: \(address)")
                            status.updateDropoffAddress(address)
                            response[String(self?.rideId ?? 0)] = status
                            self?.rideStatus = status
                            print("✅ Updated ride status with address")
                        }
                    } else {
                        print("⚠️ No ride status found for ride #\(self?.rideId ?? 0)")
                    }
                } catch {
                    print("❌ Decoding error: \(error.localizedDescription)")
                    self?.error = error
                }
            }
        }.resume()
    }
    
    private func reverseGeocode(coordinates: [Double], completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    completion("Address unavailable")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea
                    ]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    completion(address)
                } else {
                    completion("Address unavailable")
                }
            }
        }
    }
}

// Model to match the API response
struct RideStatus: Codable, Identifiable {
    let ETA: Date
    let ETP: Date
    let driver: String
    let driverLat: Double
    let driverLong: Double
    let dropoff: [Double]
    let passenger: String
    let pickup: String
    let reqid: String
    
    var id: String { reqid }
    
    var dropoffFormatted: String {
        // This will be populated by the reverse geocoding
        return _dropoffAddress ?? "Loading address..."
    }
    
    // Private property to cache the geocoded address
    private var _dropoffAddress: String?
    
    mutating func updateDropoffAddress(_ address: String) {
        _dropoffAddress = address
    }
}

// Date formatter extension
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
