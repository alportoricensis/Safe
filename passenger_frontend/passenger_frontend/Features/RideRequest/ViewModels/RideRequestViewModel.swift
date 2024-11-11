import Foundation
import CoreLocation
import Combine

enum RideRequestState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    // Implement Equatable manually because of associated value
    static func == (lhs: RideRequestState, rhs: RideRequestState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

class RideRequestViewModel: ObservableObject {
    @Published var state: RideRequestState = .idle
    @Published var authViewModel: AuthViewModel?
    @Published var currentRideId: Int?
    @Published var validPickupLocations: [PickupLocation] = []
    
    // Response model for the ride request
    struct RideRequestResponse: Codable {
        let msg: String
        let ride_id: [Int]
    }
    
    // Model for pickup locations
    struct PickupLocation: Codable, Identifiable {
        let name: String
        let lat: Double
        let long: Double
        let isPickup: Bool
        let isDropoff: Bool
        
        var id: String { name }
    }
    
    // Updated response model to match the API response structure
    struct PickupLocationsResponse: Codable {
        let allDay: [PickupLocation]
        var locations: [PickupLocation] { allDay }  // Computed property for convenience
        
        private enum CodingKeys: String, CodingKey {
            case allDay = "All-Day"
        }
        
        // Custom decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.allDay = try container.decode([PickupLocation].self, forKey: .allDay)
        }
        
        // Custom encoder
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(allDay, forKey: .allDay)
        }
    }
    
    // Request model for the ride request
    struct RideRequestBody: Codable {
        let uuid: String
        let serviceName: String
        let pickupLocation: String
        let dropoffLocation: String
        let dropoffLat: Double
        let dropoffLong: Double
        let rideOrigin: String
        let numPassengers: Int
    }
    
    init() {
        fetchPickupLocations()
    }
    
    func fetchPickupLocations() {
        guard let url = URL(string: "http://35.3.200.144:5000/api/v1/settings/pickups/") else {
            print("❌ Invalid URL for pickup locations")
            state = .error("Invalid URL")
            return
        }
        
        print("🔄 Fetching pickup locations...")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    self?.state = .error(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from server")
                    self?.state = .error("No data received")
                    return
                }
                
                // Print raw response for debugging
                print("📥 Raw response:", String(data: data, encoding: .utf8) ?? "Unable to print response")
                
                do {
                    let response = try JSONDecoder().decode(PickupLocationsResponse.self, from: data)
                    print("✅ Successfully decoded pickup locations:", response.locations)
                    self?.validPickupLocations = response.locations
                    self?.state = .success
                } catch {
                    print("❌ Decoding error:", error)
                    self?.state = .error("Failed to decode pickup locations: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func requestRide(
        service: Service,
        pickupLocation: String,
        dropoffLocationName: String,
        dropoffLocation: CLLocationCoordinate2D
    ) {
        state = .loading
        
        guard let userId = authViewModel?.user?.id else {
            state = .error("User not authenticated")
            return
        }
        
        let requestBody = RideRequestBody(
            uuid: userId,
            serviceName: service.serviceName,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocationName,
            dropoffLat: dropoffLocation.latitude,
            dropoffLong: dropoffLocation.longitude,
            rideOrigin: "passenger",
            numPassengers: 1
        )
        
        guard let url = URL(string: "http://35.3.200.144:5000/api/v1/rides/") else {
            state = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            print("📤 Sending request with body:", requestBody)
        } catch {
            state = .error("Failed to encode request body")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error:", error.localizedDescription)
                    self?.state = .error(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received from server")
                    self?.state = .error("No data received")
                    return
                }
                
                // Print raw response data for debugging
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📥 Raw server response:", rawResponse)
                }
                
                do {
                    let response = try JSONDecoder().decode(RideRequestResponse.self, from: data)
                    print("✅ Request successful! Response:", response)
                    self?.currentRideId = response.ride_id.first
                    self?.state = .success
                } catch {
                    print("❌ Decoding error:", error.localizedDescription)
                    self?.state = .error("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
