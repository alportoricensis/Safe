import Foundation
import Combine

class RideStatusViewModel: ObservableObject {
    @Published var rideStatus: RideStatus?
    @Published var error: Error?
    
    private var timer: Timer?
    private let rideId: Int
    
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
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                    let response = try decoder.decode([String: RideStatus].self, from: data)
                    self?.rideStatus = response[String(self?.rideId ?? 0)]
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
}

// Model to match the API response
struct RideStatus: Codable {
    let ETA: Date
    let ETP: Date
    let driver: String
    let driverLat: Double
    let driverLong: Double
    let dropoff: [Double]
    let passenger: String
    let pickup: String
    let reqid: String
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
